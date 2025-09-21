const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  createTrip,
  getTrips,
  getTripById,
  updateTrip,
  deleteTrip,
  addTripMember,
  removeTripMember,
  getTripMembers,
  startTrip,
  endTrip,
  addTripLocation,
  getTripLocations
} = require('../controllers/tripController');

const router = express.Router();

// Trip CRUD operations
router.post('/', protect, createTrip);
router.get('/', protect, getTrips);
router.get('/:id', protect, getTripById);
router.put('/:id', protect, updateTrip);
router.delete('/:id', protect, deleteTrip);

// Trip management
router.post('/:id/start', protect, startTrip);
router.post('/:id/end', protect, endTrip);

// Trip members
router.post('/:id/members', protect, addTripMember);
router.delete('/:id/members/:memberId', protect, removeTripMember);
router.get('/:id/members', protect, getTripMembers);

// Trip locations
router.post('/:id/locations', protect, addTripLocation);
router.get('/:id/locations', protect, getTripLocations);

module.exports = router;
