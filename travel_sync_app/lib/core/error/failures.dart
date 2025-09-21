import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  final int? statusCode;

  const Failure({this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.statusCode});
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({super.message, super.statusCode});
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure({super.message, super.statusCode});
}

class ForbiddenFailure extends AuthFailure {
  const ForbiddenFailure({super.message, super.statusCode});
}

// Location failures
class LocationFailure extends Failure {
  const LocationFailure({super.message, super.statusCode});
}

class LocationPermissionFailure extends LocationFailure {
  const LocationPermissionFailure({super.message, super.statusCode});
}

class LocationServiceFailure extends LocationFailure {
  const LocationServiceFailure({super.message, super.statusCode});
}

// Media failures
class MediaFailure extends Failure {
  const MediaFailure({super.message, super.statusCode});
}

class MediaUploadFailure extends MediaFailure {
  const MediaUploadFailure({super.message, super.statusCode});
}

class MediaDownloadFailure extends MediaFailure {
  const MediaDownloadFailure({super.message, super.statusCode});
}

// Sync failures
class SyncFailure extends Failure {
  const SyncFailure({super.message, super.statusCode});
}

class DataConflictFailure extends SyncFailure {
  const DataConflictFailure({super.message, super.statusCode});
}

// Trip failures
class TripFailure extends Failure {
  const TripFailure({super.message, super.statusCode});
}

class TripNotFoundFailure extends TripFailure {
  const TripNotFoundFailure({super.message, super.statusCode});
}

class TripInProgressFailure extends TripFailure {
  const TripInProgressFailure({super.message, super.statusCode});
}

// Expense failures
class ExpenseFailure extends Failure {
  const ExpenseFailure({super.message, super.statusCode});
}

class ExpenseNotFoundFailure extends ExpenseFailure {
  const ExpenseNotFoundFailure({super.message, super.statusCode});
}

class BudgetExceededFailure extends ExpenseFailure {
  const BudgetExceededFailure({super.message, super.statusCode});
}
