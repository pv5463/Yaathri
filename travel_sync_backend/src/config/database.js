const { Model } = require('objection');
const Knex = require('knex');
const { logger } = require('../utils/logger');

const buildConnection = () => {
  if (process.env.DATABASE_URL) {
    return process.env.DATABASE_URL;
  }

  const required = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
  const missing = required.filter((k) => !process.env[k]);
  if (missing.length > 0) {
    logger.error(`Missing database environment variables: ${missing.join(', ')}`);
    throw new Error('Database configuration is incomplete. Set DATABASE_URL or all DB_* variables.');
  }

  const port = parseInt(process.env.DB_PORT, 10);
  return {
    host: process.env.DB_HOST,
    port: Number.isNaN(port) ? undefined : port,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  };
};

const knexConfig = {
  client: 'postgresql',
  connection: buildConnection(),
  pool: {
    min: parseInt(process.env.DB_POOL_MIN, 10) || 0,
    max: parseInt(process.env.DB_POOL_MAX, 10) || 3,
    acquireTimeoutMillis: parseInt(process.env.DB_POOL_ACQUIRE, 10) || 120000,
    createTimeoutMillis: parseInt(process.env.DB_CONNECT_TIMEOUT, 10) || 120000,
    destroyTimeoutMillis: 5000,
    idleTimeoutMillis: parseInt(process.env.DB_POOL_IDLE, 10) || 20000,
    reapIntervalMillis: 1000,
    createRetryIntervalMillis: 100,
  },
  migrations: {
    directory: './src/database/migrations',
    tableName: 'knex_migrations',
  },
  seeds: {
    directory: './src/database/seeds',
  },
};

let knex;

const connectDatabase = async () => {
  try {
    knex = Knex(knexConfig);

    // Test the connection
    await knex.raw('SELECT 1');

    // Give the knex instance to objection
    Model.knex(knex);

    logger.info('Database connected successfully');

    // Run migrations in production
    if (process.env.NODE_ENV === 'production') {
      await knex.migrate.latest();
      logger.info('Database migrations completed');
    }

    return knex;
  } catch (error) {
    logger.error('Database connection failed');
    throw error;
  }
};

const closeDatabase = async () => {
  if (knex) {
    await knex.destroy();
    logger.info('Database connection closed');
  }
};

module.exports = {
  connectDatabase,
  closeDatabase,
  knex: () => knex,
  knexConfig,
};
