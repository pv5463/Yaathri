part of 'trip_bloc.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final List<TripModel> trips;
  final TripModel? currentTrip;

  const TripLoaded({
    required this.trips,
    this.currentTrip,
  });

  @override
  List<Object?> get props => [trips, currentTrip];
}

class TripStarted extends TripState {
  final TripModel trip;

  const TripStarted({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripEnded extends TripState {
  final TripModel trip;

  const TripEnded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripLocationUpdated extends TripState {
  final TripModel trip;

  const TripLocationUpdated({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripCreated extends TripState {
  final TripModel trip;

  const TripCreated({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripUpdated extends TripState {
  final TripModel trip;

  const TripUpdated({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripDeleted extends TripState {
  final String tripId;

  const TripDeleted({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class TripDetailsLoaded extends TripState {
  final TripModel trip;

  const TripDetailsLoaded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripMediaAdded extends TripState {
  final TripModel trip;

  const TripMediaAdded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripMediaRemoved extends TripState {
  final TripModel trip;

  const TripMediaRemoved({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripsSynced extends TripState {
  final List<TripModel> trips;

  const TripsSynced({required this.trips});

  @override
  List<Object?> get props => [trips];
}

class TripError extends TripState {
  final String message;

  const TripError({required this.message});

  @override
  List<Object?> get props => [message];
}
