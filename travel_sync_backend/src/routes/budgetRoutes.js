const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  createBudget,
  getBudgets,
  getBudgetById,
  updateBudget,
  deleteBudget,
  getBudgetAnalytics,
  getBudgetsByTrip
} = require('../controllers/budgetController');

const router = express.Router();

// Budget CRUD operations
router.post('/', protect, createBudget);
router.get('/', protect, getBudgets);
router.get('/:id', protect, getBudgetById);
router.put('/:id', protect, updateBudget);
router.delete('/:id', protect, deleteBudget);

// Budget analytics
router.get('/:id/analytics', protect, getBudgetAnalytics);
router.get('/trip/:tripId', protect, getBudgetsByTrip);

module.exports = router;
