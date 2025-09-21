const asyncHandler = require('express-async-handler');

const createBudget = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Budget created successfully' });
});

const getBudgets = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const getBudgetById = asyncHandler(async (req, res) => {
  res.json({ success: true, data: {} });
});

const updateBudget = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Budget updated successfully' });
});

const deleteBudget = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Budget deleted successfully' });
});

const getBudgetAnalytics = asyncHandler(async (req, res) => {
  res.json({ success: true, data: {} });
});

const getBudgetsByTrip = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

module.exports = {
  createBudget,
  getBudgets,
  getBudgetById,
  updateBudget,
  deleteBudget,
  getBudgetAnalytics,
  getBudgetsByTrip
};
