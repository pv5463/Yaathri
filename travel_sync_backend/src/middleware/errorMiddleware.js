const { logger } = require('../utils/logger');
const { ApiResponse } = require('../utils/apiResponse');
const { AppError } = require('../utils/appError');

// Handle 404 errors
const notFound = (req, res, next) => {
  const error = new AppError(`Not found - ${req.originalUrl}`, 404);
  next(error);
};

// Global error handler
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.logError(error, req);

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new AppError(message, 404);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = new AppError(message, 400);
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message);
    error = new AppError(message, 400);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new AppError(message, 401);
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new AppError(message, 401);
  }

  // PostgreSQL errors
  if (err.code === '23505') { // Unique violation
    const message = 'Duplicate field value entered';
    error = new AppError(message, 400);
  }

  if (err.code === '23503') { // Foreign key violation
    const message = 'Referenced resource not found';
    error = new AppError(message, 400);
  }

  if (err.code === '23502') { // Not null violation
    const message = 'Required field is missing';
    error = new AppError(message, 400);
  }

  // Objection.js errors
  if (err.name === 'ValidationError' && err.type === 'ModelValidation') {
    const message = 'Validation failed';
    const errors = err.data;
    return res.status(400).json(ApiResponse.validationError(errors, message));
  }

  if (err.name === 'NotFoundError') {
    const message = 'Resource not found';
    error = new AppError(message, 404);
  }

  // Multer errors (file upload)
  if (err.code === 'LIMIT_FILE_SIZE') {
    const message = 'File too large';
    error = new AppError(message, 400);
  }

  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    const message = 'Unexpected file field';
    error = new AppError(message, 400);
  }

  // Rate limiting errors
  if (err.status === 429) {
    const message = 'Too many requests, please try again later';
    error = new AppError(message, 429);
  }

  // Default to 500 server error
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal server error';

  // Don't leak error details in production
  const errorResponse = process.env.NODE_ENV === 'production' 
    ? {
        success: false,
        message: statusCode === 500 ? 'Internal server error' : message,
        ...(statusCode !== 500 && { statusCode }),
        timestamp: new Date().toISOString(),
      }
    : {
        success: false,
        message,
        statusCode,
        stack: err.stack,
        timestamp: new Date().toISOString(),
      };

  res.status(statusCode).json(errorResponse);
};

// Async error handler wrapper
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Validation error handler
const handleValidationError = (errors) => {
  const formattedErrors = {};
  
  errors.forEach(error => {
    const field = error.param || error.path;
    if (!formattedErrors[field]) {
      formattedErrors[field] = [];
    }
    formattedErrors[field].push(error.msg || error.message);
  });

  return formattedErrors;
};

module.exports = {
  notFound,
  errorHandler,
  asyncHandler,
  handleValidationError,
};
