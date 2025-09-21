class ApiResponse {
  constructor(success, data, message, errors = null, statusCode = null) {
    this.success = success;
    this.data = data;
    this.message = message;
    this.errors = errors;
    this.statusCode = statusCode;
    this.timestamp = new Date().toISOString();
  }

  static success(data, message = 'Success', statusCode = 200) {
    return new ApiResponse(true, data, message, null, statusCode);
  }

  static error(message = 'Error', errors = null, statusCode = 500) {
    return new ApiResponse(false, null, message, errors, statusCode);
  }

  static validationError(errors, message = 'Validation failed') {
    return new ApiResponse(false, null, message, errors, 400);
  }

  static notFound(message = 'Resource not found') {
    return new ApiResponse(false, null, message, null, 404);
  }

  static unauthorized(message = 'Unauthorized') {
    return new ApiResponse(false, null, message, null, 401);
  }

  static forbidden(message = 'Forbidden') {
    return new ApiResponse(false, null, message, null, 403);
  }

  static conflict(message = 'Conflict') {
    return new ApiResponse(false, null, message, null, 409);
  }

  static tooManyRequests(message = 'Too many requests') {
    return new ApiResponse(false, null, message, null, 429);
  }

  static serverError(message = 'Internal server error') {
    return new ApiResponse(false, null, message, null, 500);
  }
}

module.exports = { ApiResponse };
