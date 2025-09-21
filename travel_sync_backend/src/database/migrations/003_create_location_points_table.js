exports.up = function(knex) {
  return knex.schema.createTable('location_points', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tripId').notNullable().references('id').inTable('trips').onDelete('CASCADE');
    table.decimal('latitude', 10, 8).notNullable();
    table.decimal('longitude', 11, 8).notNullable();
    table.timestamp('timestamp').notNullable();
    table.decimal('accuracy', 8, 2);
    table.decimal('altitude', 8, 2);
    table.decimal('speed', 8, 2);
    table.decimal('heading', 6, 2);
    table.timestamps(true, true);
    
    // Indexes
    table.index(['tripId']);
    table.index(['timestamp']);
    table.index(['tripId', 'timestamp']);
    
    // Spatial index for location queries (if PostGIS is available)
    // table.index(['latitude', 'longitude']);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('location_points');
};
