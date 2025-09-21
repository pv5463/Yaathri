exports.up = function(knex) {
  return knex.schema.createTable('trips', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('userId').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.string('origin').notNullable();
    table.string('destination').notNullable();
    table.decimal('originLat', 10, 8);
    table.decimal('originLng', 11, 8);
    table.decimal('destinationLat', 10, 8);
    table.decimal('destinationLng', 11, 8);
    table.timestamp('startTime').notNullable();
    table.timestamp('endTime');
    table.enum('travelMode', [
      'walking', 'cycling', 'driving', 'publicTransport', 
      'flight', 'train', 'bus', 'taxi', 'other'
    ]).notNullable();
    table.json('companions').defaultTo('[]');
    table.enum('tripType', [
      'business', 'leisure', 'commute', 'shopping', 
      'medical', 'education', 'social', 'other'
    ]).notNullable();
    table.enum('status', ['planned', 'inProgress', 'completed', 'cancelled']).notNullable();
    table.decimal('distance', 12, 2); // in meters
    table.integer('duration'); // in seconds
    table.json('route').defaultTo('[]');
    table.json('mediaUrls').defaultTo('[]');
    table.text('notes');
    table.boolean('isAutoDetected').defaultTo(false);
    table.json('metadata').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['userId']);
    table.index(['status']);
    table.index(['travelMode']);
    table.index(['tripType']);
    table.index(['startTime']);
    table.index(['created_at']);
    table.index(['userId', 'status']);
    table.index(['userId', 'startTime']);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('trips');
};
