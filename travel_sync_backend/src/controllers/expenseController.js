const asyncHandler = require('express-async-handler');

const createExpense = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Expense created successfully' });
});

const getExpenses = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const getExpenseById = asyncHandler(async (req, res) => {
  res.json({ success: true, data: {} });
});

const updateExpense = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Expense updated successfully' });
});

const deleteExpense = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Expense deleted successfully' });
});

const splitExpense = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Expense split successfully' });
});

const getExpensesByTrip = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const getExpensesByCategory = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const uploadExpenseReceipt = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Receipt uploaded successfully' });
});

module.exports = {
  createExpense,
  getExpenses,
  getExpenseById,
  updateExpense,
  deleteExpense,
  splitExpense,
  getExpensesByTrip,
  getExpensesByCategory,
  uploadExpenseReceipt
};
