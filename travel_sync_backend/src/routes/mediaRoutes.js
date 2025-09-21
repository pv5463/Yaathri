const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  uploadMedia,
  getMedia,
  getMediaById,
  deleteMedia,
  getMediaByTrip,
  updateMediaMetadata
} = require('../controllers/mediaController');
const { upload } = require('../middleware/uploadMiddleware');

const router = express.Router();

// Media operations
router.post('/upload', protect, upload.array('media', 10), uploadMedia);
router.get('/', protect, getMedia);
router.get('/:id', protect, getMediaById);
router.put('/:id', protect, updateMediaMetadata);
router.delete('/:id', protect, deleteMedia);

// Media queries
router.get('/trip/:tripId', protect, getMediaByTrip);

module.exports = router;
