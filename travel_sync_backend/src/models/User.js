const { Model } = require('objection');
const bcrypt = require('bcryptjs');

class User extends Model {
  static get tableName() {
    return 'users';
  }

  static get idColumn() {
    return 'id';
  }

  static get jsonSchema() {
    return {
      type: 'object',
      required: ['email'],
      properties: {
        id: { type: 'string' },
        email: { type: 'string', format: 'email' },
        password: { type: 'string', minLength: 6 },
        fullName: { type: 'string' },
        phoneNumber: { type: 'string' },
        profileImageUrl: { type: 'string' },
        travelPreferences: { type: 'array', items: { type: 'string' } },
        consentGiven: { type: 'boolean' },
        isVerified: { type: 'boolean' },
        isActive: { type: 'boolean' },
        lastLoginAt: { type: 'string', format: 'date-time' },
        settings: { type: 'object' },
        socialProviders: { type: 'object' },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      },
    };
  }

  static get relationMappings() {
    const Trip = require('./Trip');
    const Expense = require('./Expense');
    const Budget = require('./Budget');

    return {
      trips: {
        relation: Model.HasManyRelation,
        modelClass: Trip,
        join: {
          from: 'users.id',
          to: 'trips.userId',
        },
      },
      expenses: {
        relation: Model.HasManyRelation,
        modelClass: Expense,
        join: {
          from: 'users.id',
          to: 'expenses.userId',
        },
      },
      budgets: {
        relation: Model.HasManyRelation,
        modelClass: Budget,
        join: {
          from: 'users.id',
          to: 'budgets.userId',
        },
      },
    };
  }

  // Hooks
  $beforeInsert() {
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
    this.isActive = true;
    this.isVerified = false;
    this.consentGiven = false;
  }

  $beforeUpdate() {
    this.updatedAt = new Date().toISOString();
  }

  // Instance methods
  async $beforeInsert(context) {
    await super.$beforeInsert(context);
    
    if (this.password) {
      this.password = await this.hashPassword(this.password);
    }
  }

  async $beforeUpdate(opt, context) {
    await super.$beforeUpdate(opt, context);
    
    if (this.password) {
      this.password = await this.hashPassword(this.password);
    }
  }

  async hashPassword(password) {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  async verifyPassword(password) {
    if (!this.password) return false;
    return bcrypt.compare(password, this.password);
  }

  // Static methods
  static async findByEmail(email) {
    return this.query().findOne({ email: email.toLowerCase() });
  }

  static async findByPhoneNumber(phoneNumber) {
    return this.query().findOne({ phoneNumber });
  }

  static async createUser(userData) {
    const user = await this.query().insert({
      ...userData,
      email: userData.email.toLowerCase(),
    });
    
    // Remove password from response
    delete user.password;
    return user;
  }

  static async updateLastLogin(userId) {
    return this.query()
      .findById(userId)
      .patch({ lastLoginAt: new Date().toISOString() });
  }

  // Virtual properties
  get fullProfile() {
    return {
      id: this.id,
      email: this.email,
      fullName: this.fullName,
      phoneNumber: this.phoneNumber,
      profileImageUrl: this.profileImageUrl,
      travelPreferences: this.travelPreferences,
      isVerified: this.isVerified,
      isActive: this.isActive,
      lastLoginAt: this.lastLoginAt,
      createdAt: this.createdAt,
    };
  }

  // JSON serialization
  $formatJson(json) {
    json = super.$formatJson(json);
    
    // Remove sensitive fields
    delete json.password;
    
    return json;
  }

  // Validation methods
  static get modifiers() {
    return {
      defaultSelects(query) {
        query.select(
          'id',
          'email',
          'fullName',
          'phoneNumber',
          'profileImageUrl',
          'travelPreferences',
          'consentGiven',
          'isVerified',
          'isActive',
          'lastLoginAt',
          'settings',
          'createdAt',
          'updatedAt'
        );
      },
    };
  }

  // Search and filtering
  static get namedFilters() {
    return {
      active: (query) => query.where('isActive', true),
      verified: (query) => query.where('isVerified', true),
      byTravelPreference: (query, preference) => 
        query.whereJsonSupersetOf('travelPreferences', [preference]),
    };
  }
}

module.exports = User;
