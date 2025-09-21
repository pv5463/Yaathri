import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/trip_model.dart';
import '../../../domain/repositories/trip_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/error/failures.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;
  final LocationService _locationService;

  TripBloc({
    required TripRepository tripRepository,
    required LocationService locationService,
  })  : _tripRepository = tripRepository,
        _locationService = locationService,
        super(TripInitial()) {
    on<LoadTrips>(_onLoadTrips);
    on<StartTrip>(_onStartTrip);
    on<EndTrip>(_onEndTrip);
    on<UpdateTripLocation>(_onUpdateTripLocation);
    on<CreateManualTrip>(_onCreateManualTrip);
    on<UpdateTrip>(_onUpdateTrip);
    on<DeleteTrip>(_onDeleteTrip);
    on<LoadTripDetails>(_onLoadTripDetails);
    on<AddTripMedia>(_onAddTripMedia);
    on<RemoveTripMedia>(_onRemoveTripMedia);
    on<SyncTrips>(_onSyncTrips);
  }

  Future<void> _onLoadTrips(
    LoadTrips event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      final result = await _tripRepository.getTrips(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
      );
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trips) {
          final currentTrip = trips.where((trip) => 
            trip.status == TripStatus.inProgress).firstOrNull;
          
          emit(TripLoaded(
            trips: trips,
            currentTrip: currentTrip,
          ));
        },
      );
    } catch (e) {
      emit(const TripError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      // Check location permissions
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        emit(const TripError(message: 'Location permission required'));
        return;
      }

      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        emit(const TripError(message: 'Unable to get current location'));
        return;
      }

      // Create new trip
      final trip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.userId,
        origin: event.origin ?? 'Current Location',
        destination: event.destination ?? 'Unknown',
        originLat: position.latitude,
        originLng: position.longitude,
        destinationLat: event.destinationLat ?? position.latitude,
        destinationLng: event.destinationLng ?? position.longitude,
        startTime: DateTime.now(),
        travelMode: event.travelMode,
        companions: event.companions,
        tripType: event.tripType,
        status: TripStatus.inProgress,
        route: [
          LocationPoint(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
            accuracy: position.accuracy,
            altitude: position.altitude,
            speed: position.speed,
          ),
        ],
        isAutoDetected: event.isAutoDetected,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _tripRepository.createTrip(trip);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (createdTrip) {
          // Start location tracking
          _locationService.startLocationTracking(createdTrip.id);
          
          emit(TripStarted(trip: createdTrip));
        },
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to start trip'));
    }
  }

  Future<void> _onEndTrip(
    EndTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      // Get current location for end point
      final position = await _locationService.getCurrentPosition();
      
      // Update trip with end details
      final updatedTrip = event.trip.copyWith(
        endTime: DateTime.now(),
        status: TripStatus.completed,
        destinationLat: position?.latitude ?? event.trip.destinationLat,
        destinationLng: position?.longitude ?? event.trip.destinationLng,
        distance: event.distance,
        duration: event.duration,
        updatedAt: DateTime.now(),
      );

      final result = await _tripRepository.updateTrip(updatedTrip);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trip) {
          // Stop location tracking
          _locationService.stopLocationTracking();
          
          emit(TripEnded(trip: trip));
        },
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to end trip'));
    }
  }

  Future<void> _onUpdateTripLocation(
    UpdateTripLocation event,
    Emitter<TripState> emit,
  ) async {
    try {
      final result = await _tripRepository.addLocationPoint(
        tripId: event.tripId,
        locationPoint: event.locationPoint,
      );
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trip) => emit(TripLocationUpdated(trip: trip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to update location'));
    }
  }

  Future<void> _onCreateManualTrip(
    CreateManualTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      final trip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.userId,
        origin: event.origin,
        destination: event.destination,
        originLat: event.originLat,
        originLng: event.originLng,
        destinationLat: event.destinationLat,
        destinationLng: event.destinationLng,
        startTime: event.startTime,
        endTime: event.endTime,
        travelMode: event.travelMode,
        companions: event.companions,
        tripType: event.tripType,
        status: TripStatus.completed,
        distance: event.distance,
        duration: event.duration,
        notes: event.notes,
        isAutoDetected: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _tripRepository.createTrip(trip);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (createdTrip) => emit(TripCreated(trip: createdTrip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to create trip'));
    }
  }

  Future<void> _onUpdateTrip(
    UpdateTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      final result = await _tripRepository.updateTrip(event.trip);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (updatedTrip) => emit(TripUpdated(trip: updatedTrip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to update trip'));
    }
  }

  Future<void> _onDeleteTrip(
    DeleteTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      final result = await _tripRepository.deleteTrip(event.tripId);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (_) => emit(TripDeleted(tripId: event.tripId)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to delete trip'));
    }
  }

  Future<void> _onLoadTripDetails(
    LoadTripDetails event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    
    try {
      final result = await _tripRepository.getTripById(event.tripId);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trip) => emit(TripDetailsLoaded(trip: trip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to load trip details'));
    }
  }

  Future<void> _onAddTripMedia(
    AddTripMedia event,
    Emitter<TripState> emit,
  ) async {
    try {
      final result = await _tripRepository.addTripMedia(
        tripId: event.tripId,
        mediaUrls: event.mediaUrls,
      );
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trip) => emit(TripMediaAdded(trip: trip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to add media'));
    }
  }

  Future<void> _onRemoveTripMedia(
    RemoveTripMedia event,
    Emitter<TripState> emit,
  ) async {
    try {
      final result = await _tripRepository.removeTripMedia(
        tripId: event.tripId,
        mediaUrl: event.mediaUrl,
      );
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trip) => emit(TripMediaRemoved(trip: trip)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to remove media'));
    }
  }

  Future<void> _onSyncTrips(
    SyncTrips event,
    Emitter<TripState> emit,
  ) async {
    try {
      final result = await _tripRepository.syncTrips(event.userId);
      
      result.fold(
        (failure) => emit(TripError(message: _mapFailureToMessage(failure))),
        (trips) => emit(TripsSynced(trips: trips)),
      );
    } catch (e) {
      emit(const TripError(message: 'Failed to sync trips'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case CacheFailure:
        return 'Local storage error occurred.';
      case LocationFailure:
        return 'Location service error occurred.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
