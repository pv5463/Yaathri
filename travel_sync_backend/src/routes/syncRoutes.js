const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  syncData,
  getSyncStatus,
  resolveSyncConflict,
  getConflicts,
  forceSyncData
} = require('../controllers/syncController');

const router = express.Router();

// Data synchronization
router.post('/sync', protect, syncData);
router.post('/force-sync', protect, forceSyncData);
router.get('/status', protect, getSyncStatus);

// Conflict resolution
router.get('/conflicts', protect, getConflicts);
router.post('/conflicts/:id/resolve', protect, resolveSyncConflict);

module.exports = router;
