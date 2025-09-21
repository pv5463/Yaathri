const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const { logger } = require('../utils/logger');

// @desc    Get user profile
// @route   GET /api/v1/users/profile
// @access  Private
const getProfile = asyncHandler(async (req, res) => {
  const user = await User.query().findById(req.user.id);
  
  if (!user) {
    res.status(404);
    throw new Error('User not found');
  }

  res.json({
    success: true,
    data: user
  });
});

// @desc    Update user profile
// @route   PUT /api/v1/users/profile
// @access  Private
const updateProfile = asyncHandler(async (req, res) => {
  const { firstName, lastName, email, phone, dateOfBirth, preferences } = req.body;

  const user = await User.query().patchAndFetchById(req.user.id, {
    firstName,
    lastName,
    email,
    phone,
    dateOfBirth,
    preferences,
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: user
  });
});

// @desc    Delete user account
// @route   DELETE /api/v1/users/account
// @access  Private
const deleteAccount = asyncHandler(async (req, res) => {
  await User.query().deleteById(req.user.id);

  res.json({
    success: true,
    message: 'Account deleted successfully'
  });
});

// @desc    Upload profile picture
// @route   POST /api/v1/users/profile/picture
// @access  Private
const uploadProfilePicture = asyncHandler(async (req, res) => {
  if (!req.file) {
    res.status(400);
    throw new Error('No file uploaded');
  }

  // Here you would typically upload to cloud storage (Cloudinary, AWS S3, etc.)
  const profilePictureUrl = req.file.path || req.file.filename;

  const user = await User.query().patchAndFetchById(req.user.id, {
    profilePicture: profilePictureUrl,
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'Profile picture uploaded successfully',
    data: { profilePicture: user.profilePicture }
  });
});

// @desc    Get user statistics
// @route   GET /api/v1/users/stats
// @access  Private
const getUserStats = asyncHandler(async (req, res) => {
  // This would typically involve complex queries to get user statistics
  const stats = {
    totalTrips: 0,
    totalExpenses: 0,
    totalDistance: 0,
    favoriteDestination: null
  };

  res.json({
    success: true,
    data: stats
  });
});

// @desc    Get all users (admin only)
// @route   GET /api/v1/users
// @access  Private/Admin
const getUsers = asyncHandler(async (req, res) => {
  const users = await User.query();

  res.json({
    success: true,
    count: users.length,
    data: users
  });
});

// @desc    Update user role (admin only)
// @route   PUT /api/v1/users/:id/role
// @access  Private/Admin
const updateUserRole = asyncHandler(async (req, res) => {
  const { role } = req.body;
  const { id } = req.params;

  const user = await User.query().patchAndFetchById(id, {
    role,
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'User role updated successfully',
    data: user
  });
});

module.exports = {
  getProfile,
  updateProfile,
  deleteAccount,
  uploadProfilePicture,
  getUserStats,
  getUsers,
  updateUserRole
};
