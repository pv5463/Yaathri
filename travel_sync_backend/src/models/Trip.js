const { Model } = require('objection');

class Trip extends Model {
  static get tableName() {
    return 'trips';
  }

  static get idColumn() {
    return 'id';
  }

  static get jsonSchema() {
    return {
      type: 'object',
      required: ['userId', 'origin', 'destination', 'startTime', 'travelMode', 'tripType', 'status'],
      properties: {
        id: { type: 'string' },
        userId: { type: 'string' },
        origin: { type: 'string' },
        destination: { type: 'string' },
        originLat: { type: 'number' },
        originLng: { type: 'number' },
        destinationLat: { type: 'number' },
        destinationLng: { type: 'number' },
        startTime: { type: 'string', format: 'date-time' },
        endTime: { type: 'string', format: 'date-time' },
        travelMode: { 
          type: 'string',
          enum: ['walking', 'cycling', 'driving', 'publicTransport', 'flight', 'train', 'bus', 'taxi', 'other']
        },
        companions: { type: 'array', items: { type: 'string' } },
        tripType: {
          type: 'string',
          enum: ['business', 'leisure', 'commute', 'shopping', 'medical', 'education', 'social', 'other']
        },
        status: {
          type: 'string',
          enum: ['planned', 'inProgress', 'completed', 'cancelled']
        },
        distance: { type: 'number' },
        duration: { type: 'integer' },
        route: { type: 'array' },
        mediaUrls: { type: 'array', items: { type: 'string' } },
        notes: { type: 'string' },
        isAutoDetected: { type: 'boolean' },
        metadata: { type: 'object' },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      },
    };
  }

  static get relationMappings() {
    const User = require('./User');
    const Expense = require('./Expense');
    const LocationPoint = require('./LocationPoint');

    return {
      user: {
        relation: Model.BelongsToOneRelation,
        modelClass: User,
        join: {
          from: 'trips.userId',
          to: 'users.id',
        },
      },
      expenses: {
        relation: Model.HasManyRelation,
        modelClass: Expense,
        join: {
          from: 'trips.id',
          to: 'expenses.tripId',
        },
      },
      locationPoints: {
        relation: Model.HasManyRelation,
        modelClass: LocationPoint,
        join: {
          from: 'trips.id',
          to: 'location_points.tripId',
        },
      },
    };
  }

  // Hooks
  $beforeInsert() {
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
    this.isAutoDetected = this.isAutoDetected || false;
    this.companions = this.companions || [];
    this.mediaUrls = this.mediaUrls || [];
    this.route = this.route || [];
  }

  $beforeUpdate() {
    this.updatedAt = new Date().toISOString();
  }

  // Instance methods
  get isActive() {
    return this.status === 'inProgress';
  }

  get isCompleted() {
    return this.status === 'completed';
  }

  get durationInMinutes() {
    if (!this.startTime || !this.endTime) return null;
    
    const start = new Date(this.startTime);
    const end = new Date(this.endTime);
    return Math.round((end - start) / (1000 * 60));
  }

  get distanceInKm() {
    if (!this.distance) return null;
    return Math.round(this.distance / 1000 * 100) / 100;
  }

  async addLocationPoint(locationData) {
    const LocationPoint = require('./LocationPoint');
    
    return LocationPoint.query().insert({
      tripId: this.id,
      ...locationData,
    });
  }

  async getLocationPoints() {
    return this.$relatedQuery('locationPoints')
      .orderBy('timestamp', 'asc');
  }

  async addMedia(mediaUrls) {
    const currentUrls = this.mediaUrls || [];
    const newUrls = Array.isArray(mediaUrls) ? mediaUrls : [mediaUrls];
    
    return this.$query().patch({
      mediaUrls: [...currentUrls, ...newUrls],
    });
  }

  async removeMedia(mediaUrl) {
    const currentUrls = this.mediaUrls || [];
    const updatedUrls = currentUrls.filter(url => url !== mediaUrl);
    
    return this.$query().patch({
      mediaUrls: updatedUrls,
    });
  }

  async calculateTotalExpenses() {
    const result = await this.$relatedQuery('expenses')
      .sum('amount as total')
      .first();
    
    return parseFloat(result.total) || 0;
  }

  // Static methods
  static async findActiveTrip(userId) {
    return this.query()
      .where('userId', userId)
      .where('status', 'inProgress')
      .first();
  }

  static async findUserTrips(userId, options = {}) {
    let query = this.query()
      .where('userId', userId)
      .orderBy('startTime', 'desc');

    if (options.status) {
      query = query.where('status', options.status);
    }

    if (options.travelMode) {
      query = query.where('travelMode', options.travelMode);
    }

    if (options.tripType) {
      query = query.where('tripType', options.tripType);
    }

    if (options.startDate && options.endDate) {
      query = query.whereBetween('startTime', [options.startDate, options.endDate]);
    }

    if (options.limit) {
      query = query.limit(options.limit);
    }

    if (options.offset) {
      query = query.offset(options.offset);
    }

    return query;
  }

  static async getTripStats(userId, period = '30d') {
    const startDate = new Date();
    
    switch (period) {
      case '7d':
        startDate.setDate(startDate.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(startDate.getDate() - 30);
        break;
      case '90d':
        startDate.setDate(startDate.getDate() - 90);
        break;
      case '1y':
        startDate.setFullYear(startDate.getFullYear() - 1);
        break;
      default:
        startDate.setDate(startDate.getDate() - 30);
    }

    const stats = await this.query()
      .where('userId', userId)
      .where('status', 'completed')
      .where('startTime', '>=', startDate.toISOString())
      .select(
        this.raw('COUNT(*) as totalTrips'),
        this.raw('SUM(distance) as totalDistance'),
        this.raw('SUM(duration) as totalDuration'),
        this.raw('COUNT(DISTINCT "travelMode") as uniqueModes')
      )
      .first();

    return {
      totalTrips: parseInt(stats.totalTrips) || 0,
      totalDistance: parseFloat(stats.totalDistance) || 0,
      totalDuration: parseInt(stats.totalDuration) || 0,
      uniqueModes: parseInt(stats.uniqueModes) || 0,
    };
  }

  static async getModeDistribution(userId, period = '30d') {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(period));

    return this.query()
      .where('userId', userId)
      .where('status', 'completed')
      .where('startTime', '>=', startDate.toISOString())
      .select('travelMode')
      .count('* as count')
      .groupBy('travelMode')
      .orderBy('count', 'desc');
  }

  // Validation methods
  static get modifiers() {
    return {
      active: (query) => query.where('status', 'inProgress'),
      completed: (query) => query.where('status', 'completed'),
      withUser: (query) => query.withGraphFetched('user(defaultSelects)'),
      withExpenses: (query) => query.withGraphFetched('expenses'),
      withLocationPoints: (query) => query.withGraphFetched('locationPoints'),
    };
  }

  // Named filters
  static get namedFilters() {
    return {
      byMode: (query, mode) => query.where('travelMode', mode),
      byType: (query, type) => query.where('tripType', type),
      byStatus: (query, status) => query.where('status', status),
      inDateRange: (query, startDate, endDate) => 
        query.whereBetween('startTime', [startDate, endDate]),
    };
  }
}

module.exports = Trip;
