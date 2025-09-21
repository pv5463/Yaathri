const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { AppError } = require('../utils/appError');
const { logger } = require('../utils/logger');

// Authenticate user with JWT token
const authenticate = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new AppError('Access token is required', 401));
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      if (jwtError.name === 'TokenExpiredError') {
        return next(new AppError('Access token has expired', 401));
      }
      return next(new AppError('Invalid access token', 401));
    }

    // Check token type
    if (decoded.type !== 'access') {
      return next(new AppError('Invalid token type', 401));
    }

    // Get user from database
    const user = await User.query()
      .findById(decoded.userId)
      .modify('defaultSelects');

    if (!user) {
      return next(new AppError('User not found', 401));
    }

    // Check if user is active
    if (!user.isActive) {
      return next(new AppError('Account has been deactivated', 401));
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    next(new AppError('Authentication failed', 401));
  }
};

// Optional authentication - doesn't fail if no token provided
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // Continue without user
    }

    const token = authHeader.substring(7);

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      if (decoded.type === 'access') {
        const user = await User.query()
          .findById(decoded.userId)
          .modify('defaultSelects');

        if (user && user.isActive) {
          req.user = user;
        }
      }
    } catch (jwtError) {
      // Ignore JWT errors for optional auth
    }

    next();
  } catch (error) {
    next(); // Continue without user on any error
  }
};

// Authorize user roles
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    const userRole = req.user.role || 'user';
    if (!roles.includes(userRole)) {
      return next(new AppError('Insufficient permissions', 403));
    }

    next();
  };
};

// Check if user owns the resource
const checkOwnership = (resourceUserIdField = 'userId') => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return next(new AppError('Authentication required', 401));
      }

      // Get resource ID from params
      const resourceId = req.params.id;
      if (!resourceId) {
        return next(new AppError('Resource ID is required', 400));
      }

      // This is a generic middleware, so we need to determine the model
      // based on the route. For now, we'll pass the check to the controller
      // and let it handle ownership verification.
      
      next();
    } catch (error) {
      next(error);
    }
  };
};

// Rate limiting per user
const userRateLimit = (maxRequests = 100, windowMs = 15 * 60 * 1000) => {
  const userRequests = new Map();

  return (req, res, next) => {
    if (!req.user) {
      return next();
    }

    const userId = req.user.id;
    const now = Date.now();
    const windowStart = now - windowMs;

    // Clean old entries
    if (userRequests.has(userId)) {
      const requests = userRequests.get(userId);
      const validRequests = requests.filter(time => time > windowStart);
      userRequests.set(userId, validRequests);
    }

    // Check current requests
    const currentRequests = userRequests.get(userId) || [];
    if (currentRequests.length >= maxRequests) {
      return next(new AppError('Too many requests, please try again later', 429));
    }

    // Add current request
    currentRequests.push(now);
    userRequests.set(userId, currentRequests);

    next();
  };
};

// Verify user email
const requireEmailVerification = (req, res, next) => {
  if (!req.user) {
    return next(new AppError('Authentication required', 401));
  }

  if (!req.user.isVerified) {
    return next(new AppError('Email verification required', 403));
  }

  next();
};

// Check user consent
const requireConsent = (req, res, next) => {
  if (!req.user) {
    return next(new AppError('Authentication required', 401));
  }

  if (!req.user.consentGiven) {
    return next(new AppError('User consent required', 403));
  }

  next();
};

// Aliases for common middleware
const protect = authenticate;
const adminOnly = authorize('admin');

module.exports = {
  authenticate,
  optionalAuth,
  authorize,
  checkOwnership,
  userRateLimit,
  requireEmailVerification,
  requireConsent,
  protect,
  adminOnly,
};
