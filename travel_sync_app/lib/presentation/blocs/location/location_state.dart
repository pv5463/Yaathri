part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionGranted extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationPoint locationPoint;

  const LocationLoaded({required this.locationPoint});

  @override
  List<Object?> get props => [locationPoint];
}

class LocationTrackingStarted extends LocationState {
  final String tripId;

  const LocationTrackingStarted({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class LocationTrackingStopped extends LocationState {}

class LocationServiceStatus extends LocationState {
  final bool hasPermission;
  final bool isServiceEnabled;
  final bool isTracking;

  const LocationServiceStatus({
    required this.hasPermission,
    required this.isServiceEnabled,
    required this.isTracking,
  });

  @override
  List<Object?> get props => [hasPermission, isServiceEnabled, isTracking];
}

class AddressLoaded extends LocationState {
  final String address;
  final double latitude;
  final double longitude;

  const AddressLoaded({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class CoordinatesLoaded extends LocationState {
  final LocationPoint locationPoint;
  final String address;

  const CoordinatesLoaded({
    required this.locationPoint,
    required this.address,
  });

  @override
  List<Object?> get props => [locationPoint, address];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}
