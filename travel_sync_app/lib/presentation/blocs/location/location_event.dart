part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class RequestLocationPermission extends LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class StartLocationTracking extends LocationEvent {
  final String tripId;

  const StartLocationTracking({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class StopLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final LocationPoint locationPoint;

  const LocationUpdated({required this.locationPoint});

  @override
  List<Object?> get props => [locationPoint];
}

class LocationTrackingError extends LocationEvent {
  final String message;

  const LocationTrackingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CheckLocationService extends LocationEvent {}

class GetAddressFromCoordinates extends LocationEvent {
  final double latitude;
  final double longitude;

  const GetAddressFromCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class GetCoordinatesFromAddress extends LocationEvent {
  final String address;

  const GetCoordinatesFromAddress({required this.address});

  @override
  List<Object?> get props => [address];
}
