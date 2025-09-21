exports.up = function(knex) {
  return knex.schema.createTable('budgets', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('userId').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('tripId').references('id').inTable('trips').onDelete('CASCADE');
    table.string('title').notNullable();
    table.decimal('totalBudget', 12, 2).notNullable();
    table.string('currency', 3).defaultTo('USD');
    table.json('categoryBudgets').defaultTo('{}');
    table.timestamp('startDate').notNullable();
    table.timestamp('endDate').notNullable();
    table.json('metadata').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['userId']);
    table.index(['tripId']);
    table.index(['startDate', 'endDate']);
    table.index(['created_at']);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('budgets');
};
