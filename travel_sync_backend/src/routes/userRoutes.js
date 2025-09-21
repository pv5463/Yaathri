const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  getProfile,
  updateProfile,
  deleteAccount,
  uploadProfilePicture,
  getUserStats,
  getUsers,
  updateUserRole
} = require('../controllers/userController');
const { upload } = require('../middleware/uploadMiddleware');

const router = express.Router();

/**
 * @swagger
 * /api/v1/users/profile:
 *   get:
 *     summary: Get user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get('/profile', protect, getProfile);

/**
 * @swagger
 * /api/v1/users/profile:
 *   put:
 *     summary: Update user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile updated successfully
 *       401:
 *         description: Unauthorized
 */
router.put('/profile', protect, updateProfile);

/**
 * @swagger
 * /api/v1/users/profile/picture:
 *   post:
 *     summary: Upload profile picture
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile picture uploaded successfully
 *       401:
 *         description: Unauthorized
 */
router.post('/profile/picture', protect, upload.single('profilePicture'), uploadProfilePicture);

/**
 * @swagger
 * /api/v1/users/stats:
 *   get:
 *     summary: Get user statistics
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User statistics retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get('/stats', protect, getUserStats);

/**
 * @swagger
 * /api/v1/users:
 *   get:
 *     summary: Get all users (admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Users retrieved successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 */
router.get('/', protect, getUsers);

/**
 * @swagger
 * /api/v1/users/{id}/role:
 *   put:
 *     summary: Update user role (admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User role updated successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 */
router.put('/:id/role', protect, updateUserRole);

/**
 * @swagger
 * /api/v1/users/account:
 *   delete:
 *     summary: Delete user account
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Account deleted successfully
 *       401:
 *         description: Unauthorized
 */
router.delete('/account', protect, deleteAccount);

module.exports = router;
