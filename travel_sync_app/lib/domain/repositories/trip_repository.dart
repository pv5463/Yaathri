import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/trip_model.dart';

abstract class TripRepository {
  Future<Either<Failure, List<TripModel>>> getTrips({
    required String userId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, TripModel>> getTripById(String tripId);

  Future<Either<Failure, TripModel>> createTrip(TripModel trip);

  Future<Either<Failure, TripModel>> updateTrip(TripModel trip);

  Future<Either<Failure, void>> deleteTrip(String tripId);

  Future<Either<Failure, TripModel>> addLocationPoint({
    required String tripId,
    required LocationPoint locationPoint,
  });

  Future<Either<Failure, TripModel>> addTripMedia({
    required String tripId,
    required List<String> mediaUrls,
  });

  Future<Either<Failure, TripModel>> removeTripMedia({
    required String tripId,
    required String mediaUrl,
  });

  Future<Either<Failure, List<TripModel>>> syncTrips(String userId);
}
