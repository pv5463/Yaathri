import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/trip_plan_model.dart';

abstract class PlanningRepository {
  Future<Either<Failure, List<TripPlanModel>>> getTripPlans({
    required String userId,
    TripPlanStatus? status,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, TripPlanModel>> getTripPlanById(String tripPlanId);

  Future<Either<Failure, TripPlanModel>> createTripPlan(TripPlanModel tripPlan);

  Future<Either<Failure, TripPlanModel>> updateTripPlan(TripPlanModel tripPlan);

  Future<Either<Failure, void>> deleteTripPlan(String tripPlanId);

  Future<Either<Failure, TripPlanModel>> addItineraryItem({
    required String tripPlanId,
    required ItineraryItem itineraryItem,
  });

  Future<Either<Failure, TripPlanModel>> updateItineraryItem({
    required String tripPlanId,
    required ItineraryItem itineraryItem,
  });

  Future<Either<Failure, TripPlanModel>> deleteItineraryItem({
    required String tripPlanId,
    required String itineraryItemId,
  });

  Future<Either<Failure, TripPlanModel>> reorderItineraryItems({
    required String tripPlanId,
    required List<String> itemIds,
  });

  Future<Either<Failure, ShareInfo>> shareTripPlan({
    required String tripPlanId,
    required List<String> shareWith,
    required SharePermissions permissions,
  });

  Future<Either<Failure, List<TripPlanModel>>> syncTripPlans(String userId);
}
