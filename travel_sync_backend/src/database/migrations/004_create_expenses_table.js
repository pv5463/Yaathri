exports.up = function(knex) {
  return knex.schema.createTable('expenses', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('userId').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('tripId').references('id').inTable('trips').onDelete('SET NULL');
    table.string('title').notNullable();
    table.text('description');
    table.decimal('amount', 12, 2).notNullable();
    table.string('currency', 3).defaultTo('USD');
    table.enum('category', [
      'accommodation', 'transportation', 'food', 'entertainment', 
      'shopping', 'fuel', 'parking', 'tolls', 'tickets', 
      'insurance', 'medical', 'communication', 'miscellaneous'
    ]).notNullable();
    table.timestamp('date').notNullable();
    table.string('receiptUrl');
    table.json('sharedWith').defaultTo('[]');
    table.json('splitAmounts').defaultTo('{}');
    table.string('location');
    table.decimal('latitude', 10, 8);
    table.decimal('longitude', 11, 8);
    table.json('metadata').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['userId']);
    table.index(['tripId']);
    table.index(['category']);
    table.index(['date']);
    table.index(['created_at']);
    table.index(['userId', 'date']);
    table.index(['userId', 'category']);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('expenses');
};
