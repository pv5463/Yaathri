const express = require('express');
const { protect, adminOnly } = require('../middleware/authMiddleware');
const {
  getDashboardStats,
  getAllUsers,
  getUserDetails,
  updateUserStatus,
  getAllTrips,
  getTripDetails,
  getSystemLogs,
  exportData,
  getAnalyticsData,
  manageUserPermissions
} = require('../controllers/adminController');

const router = express.Router();

// Apply admin protection to all routes
router.use(protect);
router.use(adminOnly);

// Dashboard
router.get('/dashboard', getDashboardStats);
router.get('/analytics', getAnalyticsData);

// User management
router.get('/users', getAllUsers);
router.get('/users/:id', getUserDetails);
router.put('/users/:id/status', updateUserStatus);
router.put('/users/:id/permissions', manageUserPermissions);

// Trip management
router.get('/trips', getAllTrips);
router.get('/trips/:id', getTripDetails);

// System management
router.get('/logs', getSystemLogs);
router.post('/export', exportData);

module.exports = router;
