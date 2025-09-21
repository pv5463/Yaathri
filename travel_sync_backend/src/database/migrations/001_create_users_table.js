exports.up = function(knex) {
  return knex.schema.createTable('users', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('email').unique().notNullable();
    table.string('password');
    table.string('fullName');
    table.string('phoneNumber').unique();
    table.string('profileImageUrl');
    table.json('travelPreferences').defaultTo('[]');
    table.boolean('consentGiven').defaultTo(false);
    table.boolean('isVerified').defaultTo(false);
    table.boolean('isActive').defaultTo(true);
    table.timestamp('lastLoginAt');
    table.json('settings').defaultTo('{}');
    table.json('socialProviders').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['email']);
    table.index(['phoneNumber']);
    table.index(['isActive']);
    table.index(['created_at']);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('users');
};
