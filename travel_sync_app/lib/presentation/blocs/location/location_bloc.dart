import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/location_service.dart';
import '../../../data/models/trip_model.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  StreamSubscription<LocationPoint>? _locationSubscription;

  LocationBloc({required LocationService locationService})
      : _locationService = locationService,
        super(LocationInitial()) {
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<CheckLocationService>(_onCheckLocationService);
    on<GetAddressFromCoordinates>(_onGetAddressFromCoordinates);
    on<GetCoordinatesFromAddress>(_onGetCoordinatesFromAddress);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      
      if (hasPermission) {
        emit(LocationPermissionGranted());
      } else {
        emit(const LocationError(message: 'Location permission denied'));
      }
    } catch (e) {
      emit(const LocationError(message: 'Failed to request location permission'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      // Check permissions first
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        emit(const LocationError(message: 'Location permission required'));
        return;
      }

      // Check if location service is enabled
      final isServiceEnabled = await _locationService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        emit(const LocationError(message: 'Location service is disabled'));
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final locationPoint = LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
        );
        
        emit(LocationLoaded(locationPoint: locationPoint));
      } else {
        emit(const LocationError(message: 'Unable to get current location'));
      }
    } catch (e) {
      emit(LocationError(message: 'Failed to get current location: $e'));
    }
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      // Check permissions and service
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        emit(const LocationError(message: 'Location permission required'));
        return;
      }

      final isServiceEnabled = await _locationService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        emit(const LocationError(message: 'Location service is disabled'));
        return;
      }

      // Start tracking
      await _locationService.startLocationTracking(event.tripId);
      
      // Listen to location updates
      _locationSubscription?.cancel();
      _locationSubscription = _locationService.locationStream.listen(
        (locationPoint) {
          add(LocationUpdated(locationPoint: locationPoint));
        },
        onError: (error) {
          add(LocationTrackingError(message: error.toString()));
        },
      );

      emit(LocationTrackingStarted(tripId: event.tripId));
    } catch (e) {
      emit(LocationError(message: 'Failed to start location tracking: $e'));
    }
  }

  Future<void> _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      _locationService.stopLocationTracking();
      _locationSubscription?.cancel();
      _locationSubscription = null;
      
      emit(LocationTrackingStopped());
    } catch (e) {
      emit(LocationError(message: 'Failed to stop location tracking: $e'));
    }
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationLoaded(locationPoint: event.locationPoint));
  }

  Future<void> _onCheckLocationService(
    CheckLocationService event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final hasPermission = await _locationService.hasLocationPermission();
      final isServiceEnabled = await _locationService.isLocationServiceEnabled();
      
      emit(LocationServiceStatus(
        hasPermission: hasPermission,
        isServiceEnabled: isServiceEnabled,
        isTracking: _locationService.isTracking,
      ));
    } catch (e) {
      emit(const LocationError(message: 'Failed to check location service status'));
    }
  }

  Future<void> _onGetAddressFromCoordinates(
    GetAddressFromCoordinates event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final address = await _locationService.getAddressFromCoordinates(
        event.latitude,
        event.longitude,
      );
      
      if (address != null) {
        emit(AddressLoaded(
          address: address,
          latitude: event.latitude,
          longitude: event.longitude,
        ));
      } else {
        emit(const LocationError(message: 'Unable to get address for coordinates'));
      }
    } catch (e) {
      emit(LocationError(message: 'Failed to get address: $e'));
    }
  }

  Future<void> _onGetCoordinatesFromAddress(
    GetCoordinatesFromAddress event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final position = await _locationService.getCoordinatesFromAddress(event.address);
      
      if (position != null) {
        final locationPoint = LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        );
        
        emit(CoordinatesLoaded(
          locationPoint: locationPoint,
          address: event.address,
        ));
      } else {
        emit(const LocationError(message: 'Unable to find coordinates for address'));
      }
    } catch (e) {
      emit(LocationError(message: 'Failed to get coordinates: $e'));
    }
  }

  void _onLocationTrackingError(LocationTrackingError event) {
    emit(LocationError(message: event.message));
  }
}
