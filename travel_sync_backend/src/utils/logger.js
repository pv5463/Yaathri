const winston = require('winston');
const path = require('path');

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define colors for each level
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

// Tell winston that you want to link the colors
winston.addColors(colors);

// Define which level to log based on environment
const level = () => {
  const env = process.env.NODE_ENV || 'development';
  const isDevelopment = env === 'development';
  return isDevelopment ? 'debug' : 'warn';
};

// Define format for logs
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
);

// Define transports
const transports = [
  // Console transport
  new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    ),
  }),
];

// Add file transports in production
if (process.env.NODE_ENV === 'production') {
  // Ensure logs directory exists
  const fs = require('fs');
  const logsDir = path.join(__dirname, '../../logs');
  if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
  }

  transports.push(
    // Error log file
    new winston.transports.File({
      filename: path.join(logsDir, 'error.log'),
      level: 'error',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
    }),
    // Combined log file
    new winston.transports.File({
      filename: path.join(logsDir, 'combined.log'),
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
    })
  );
}

// Create the logger
const logger = winston.createLogger({
  level: level(),
  levels,
  format,
  transports,
  // Handle exceptions and rejections
  exceptionHandlers: [
    new winston.transports.Console(),
    ...(process.env.NODE_ENV === 'production' ? [
      new winston.transports.File({
        filename: path.join(__dirname, '../../logs/exceptions.log')
      })
    ] : [])
  ],
  rejectionHandlers: [
    new winston.transports.Console(),
    ...(process.env.NODE_ENV === 'production' ? [
      new winston.transports.File({
        filename: path.join(__dirname, '../../logs/rejections.log')
      })
    ] : [])
  ],
});

// Create a stream object for Morgan HTTP logging
logger.stream = {
  write: (message) => {
    logger.http(message.trim());
  },
};

// Helper methods for structured logging
logger.logRequest = (req, res, responseTime) => {
  const logData = {
    method: req.method,
    url: req.url,
    statusCode: res.statusCode,
    responseTime: `${responseTime}ms`,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    userId: req.user?.id,
  };

  if (res.statusCode >= 400) {
    logger.warn('HTTP Request', logData);
  } else {
    logger.info('HTTP Request', logData);
  }
};

logger.logError = (error, req = null) => {
  const logData = {
    message: error.message,
    stack: error.stack,
    ...(req && {
      method: req.method,
      url: req.url,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
      userId: req.user?.id,
    }),
  };

  logger.error('Application Error', logData);
};

logger.logAuth = (action, userId, email, success = true, details = {}) => {
  const logData = {
    action,
    userId,
    email,
    success,
    timestamp: new Date().toISOString(),
    ...details,
  };

  if (success) {
    logger.info('Auth Event', logData);
  } else {
    logger.warn('Auth Event Failed', logData);
  }
};

logger.logTrip = (action, tripId, userId, details = {}) => {
  const logData = {
    action,
    tripId,
    userId,
    timestamp: new Date().toISOString(),
    ...details,
  };

  logger.info('Trip Event', logData);
};

logger.logExpense = (action, expenseId, userId, amount, details = {}) => {
  const logData = {
    action,
    expenseId,
    userId,
    amount,
    timestamp: new Date().toISOString(),
    ...details,
  };

  logger.info('Expense Event', logData);
};

logger.logSync = (userId, dataType, recordCount, success = true, details = {}) => {
  const logData = {
    userId,
    dataType,
    recordCount,
    success,
    timestamp: new Date().toISOString(),
    ...details,
  };

  if (success) {
    logger.info('Data Sync', logData);
  } else {
    logger.warn('Data Sync Failed', logData);
  }
};

module.exports = { logger };
