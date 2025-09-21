const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  getUserAnalytics,
  getTripAnalytics,
  getExpenseAnalytics,
  getTravelPatterns,
  getPopularDestinations,
  getSystemAnalytics
} = require('../controllers/analyticsController');

const router = express.Router();

// User analytics
router.get('/user', protect, getUserAnalytics);
router.get('/user/travel-patterns', protect, getTravelPatterns);

// Trip analytics
router.get('/trips', protect, getTripAnalytics);
router.get('/trips/popular-destinations', protect, getPopularDestinations);

// Expense analytics
router.get('/expenses', protect, getExpenseAnalytics);

// System analytics (admin only)
router.get('/system', protect, getSystemAnalytics);

module.exports = router;
