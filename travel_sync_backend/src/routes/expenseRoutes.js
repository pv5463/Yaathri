const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  createExpense,
  getExpenses,
  getExpenseById,
  updateExpense,
  deleteExpense,
  splitExpense,
  getExpensesByTrip,
  getExpensesByCategory,
  uploadExpenseReceipt
} = require('../controllers/expenseController');
const { upload } = require('../middleware/uploadMiddleware');

const router = express.Router();

// Expense CRUD operations
router.post('/', protect, createExpense);
router.get('/', protect, getExpenses);
router.get('/:id', protect, getExpenseById);
router.put('/:id', protect, updateExpense);
router.delete('/:id', protect, deleteExpense);

// Expense management
router.post('/:id/split', protect, splitExpense);
router.post('/:id/receipt', protect, upload.single('receipt'), uploadExpenseReceipt);

// Expense queries
router.get('/trip/:tripId', protect, getExpensesByTrip);
router.get('/category/:category', protect, getExpensesByCategory);

module.exports = router;
