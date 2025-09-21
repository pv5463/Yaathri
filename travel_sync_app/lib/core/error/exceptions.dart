class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  const ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AuthException {
  const ForbiddenException({
    super.message = 'Forbidden access',
    super.statusCode = 403,
  });
}

class LocationException implements Exception {
  final String message;

  const LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

class LocationPermissionException extends LocationException {
  const LocationPermissionException({
    super.message = 'Location permission denied',
  });
}

class LocationServiceException extends LocationException {
  const LocationServiceException({
    super.message = 'Location service disabled',
  });
}

class MediaException implements Exception {
  final String message;

  const MediaException({required this.message});

  @override
  String toString() => 'MediaException: $message';
}

class MediaUploadException extends MediaException {
  const MediaUploadException({
    super.message = 'Failed to upload media',
  });
}

class MediaDownloadException extends MediaException {
  const MediaDownloadException({
    super.message = 'Failed to download media',
  });
}

class SyncException implements Exception {
  final String message;

  const SyncException({required this.message});

  @override
  String toString() => 'SyncException: $message';
}

class DataConflictException extends SyncException {
  const DataConflictException({
    super.message = 'Data conflict during sync',
  });
}

class TripException implements Exception {
  final String message;

  const TripException({required this.message});

  @override
  String toString() => 'TripException: $message';
}

class TripNotFoundException extends TripException {
  const TripNotFoundException({
    super.message = 'Trip not found',
  });
}

class TripInProgressException extends TripException {
  const TripInProgressException({
    super.message = 'Trip already in progress',
  });
}

class ExpenseException implements Exception {
  final String message;

  const ExpenseException({required this.message});

  @override
  String toString() => 'ExpenseException: $message';
}

class ExpenseNotFoundException extends ExpenseException {
  const ExpenseNotFoundException({
    super.message = 'Expense not found',
  });
}

class BudgetExceededException extends ExpenseException {
  const BudgetExceededException({
    super.message = 'Budget exceeded',
  });
}
