const { validationResult } = require('express-validator');
const { ApiResponse } = require('../utils/apiResponse');
const { handleValidationError } = require('./errorMiddleware');

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const formattedErrors = handleValidationError(errors.array());
    return res.status(400).json(
      ApiResponse.validationError(formattedErrors, 'Validation failed')
    );
  }
  
  next();
};

module.exports = {
  validateRequest,
};
