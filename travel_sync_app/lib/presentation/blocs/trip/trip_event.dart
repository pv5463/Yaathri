part of 'trip_bloc.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrips extends TripEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadTrips({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

class StartTrip extends TripEvent {
  final String userId;
  final String? origin;
  final String? destination;
  final double? destinationLat;
  final double? destinationLng;
  final TravelMode travelMode;
  final List<String> companions;
  final TripType tripType;
  final bool isAutoDetected;

  const StartTrip({
    required this.userId,
    this.origin,
    this.destination,
    this.destinationLat,
    this.destinationLng,
    required this.travelMode,
    this.companions = const [],
    required this.tripType,
    this.isAutoDetected = false,
  });

  @override
  List<Object?> get props => [
        userId,
        origin,
        destination,
        destinationLat,
        destinationLng,
        travelMode,
        companions,
        tripType,
        isAutoDetected,
      ];
}

class EndTrip extends TripEvent {
  final TripModel trip;
  final double? distance;
  final int? duration;

  const EndTrip({
    required this.trip,
    this.distance,
    this.duration,
  });

  @override
  List<Object?> get props => [trip, distance, duration];
}

class UpdateTripLocation extends TripEvent {
  final String tripId;
  final LocationPoint locationPoint;

  const UpdateTripLocation({
    required this.tripId,
    required this.locationPoint,
  });

  @override
  List<Object?> get props => [tripId, locationPoint];
}

class CreateManualTrip extends TripEvent {
  final String userId;
  final String origin;
  final String destination;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime startTime;
  final DateTime? endTime;
  final TravelMode travelMode;
  final List<String> companions;
  final TripType tripType;
  final double? distance;
  final int? duration;
  final String? notes;

  const CreateManualTrip({
    required this.userId,
    required this.origin,
    required this.destination,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.startTime,
    this.endTime,
    required this.travelMode,
    this.companions = const [],
    required this.tripType,
    this.distance,
    this.duration,
    this.notes,
  });

  @override
  List<Object?> get props => [
        userId,
        origin,
        destination,
        originLat,
        originLng,
        destinationLat,
        destinationLng,
        startTime,
        endTime,
        travelMode,
        companions,
        tripType,
        distance,
        duration,
        notes,
      ];
}

class UpdateTrip extends TripEvent {
  final TripModel trip;

  const UpdateTrip({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class DeleteTrip extends TripEvent {
  final String tripId;

  const DeleteTrip({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class LoadTripDetails extends TripEvent {
  final String tripId;

  const LoadTripDetails({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class AddTripMedia extends TripEvent {
  final String tripId;
  final List<String> mediaUrls;

  const AddTripMedia({
    required this.tripId,
    required this.mediaUrls,
  });

  @override
  List<Object?> get props => [tripId, mediaUrls];
}

class RemoveTripMedia extends TripEvent {
  final String tripId;
  final String mediaUrl;

  const RemoveTripMedia({
    required this.tripId,
    required this.mediaUrl,
  });

  @override
  List<Object?> get props => [tripId, mediaUrl];
}

class SyncTrips extends TripEvent {
  final String userId;

  const SyncTrips({required this.userId});

  @override
  List<Object?> get props => [userId];
}
