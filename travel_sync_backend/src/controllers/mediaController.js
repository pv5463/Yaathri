const asyncHandler = require('express-async-handler');

const uploadMedia = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Media uploaded successfully' });
});

const getMedia = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const getMediaById = asyncHandler(async (req, res) => {
  res.json({ success: true, data: {} });
});

const deleteMedia = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Media deleted successfully' });
});

const getMediaByTrip = asyncHandler(async (req, res) => {
  res.json({ success: true, data: [] });
});

const updateMediaMetadata = asyncHandler(async (req, res) => {
  res.json({ success: true, message: 'Media metadata updated successfully' });
});

module.exports = {
  uploadMedia,
  getMedia,
  getMediaById,
  deleteMedia,
  getMediaByTrip,
  updateMediaMetadata
};
