const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { createServer } = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const { connectDatabase } = require('./config/database');
const { setupPassport } = require('./config/passport');
const { logger } = require('./utils/logger');
const { errorHandler, notFound } = require('./middleware/errorMiddleware');
const { setupSwagger } = require('./config/swagger');

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const tripRoutes = require('./routes/tripRoutes');
const expenseRoutes = require('./routes/expenseRoutes');
const budgetRoutes = require('./routes/budgetRoutes');
const mediaRoutes = require('./routes/mediaRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');
const syncRoutes = require('./routes/syncRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Database connection
connectDatabase();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// CORS configuration
app.use(cors({
  origin: process.env.CLIENT_URL || "http://localhost:3000",
  credentials: true,
}));

// Compression middleware
app.use(compression());

// Logging middleware
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Passport configuration
setupPassport(app);

// Socket.io setup
io.on('connection', (socket) => {
  logger.info(`User connected: ${socket.id}`);
  
  socket.on('join_trip', (tripId) => {
    socket.join(`trip_${tripId}`);
    logger.info(`User ${socket.id} joined trip ${tripId}`);
  });
  
  socket.on('leave_trip', (tripId) => {
    socket.leave(`trip_${tripId}`);
    logger.info(`User ${socket.id} left trip ${tripId}`);
  });
  
  socket.on('disconnect', () => {
    logger.info(`User disconnected: ${socket.id}`);
  });
});

// Make io available to routes
app.set('io', io);

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/trips', tripRoutes);
app.use('/api/v1/expenses', expenseRoutes);
app.use('/api/v1/budgets', budgetRoutes);
app.use('/api/v1/media', mediaRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/sync', syncRoutes);
app.use('/api/v1/admin', adminRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'TravelSync API is running',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// API documentation
setupSwagger(app);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to TravelSync API',
    version: '1.0.0',
    documentation: '/api-docs'
  });
});

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  logger.info(`TravelSync API server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`API Documentation: http://localhost:${PORT}/api-docs`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = { app, server, io };
