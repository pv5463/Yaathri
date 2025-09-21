part of 'planning_bloc.dart';

abstract class PlanningEvent extends Equatable {
  const PlanningEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripPlans extends PlanningEvent {
  final String userId;
  final TripPlanStatus? status;
  final int? limit;
  final int? offset;

  const LoadTripPlans({
    required this.userId,
    this.status,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, status, limit, offset];
}

class CreateTripPlan extends PlanningEvent {
  final TripPlanModel tripPlan;

  const CreateTripPlan({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class UpdateTripPlan extends PlanningEvent {
  final TripPlanModel tripPlan;

  const UpdateTripPlan({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class DeleteTripPlan extends PlanningEvent {
  final String tripPlanId;

  const DeleteTripPlan({required this.tripPlanId});

  @override
  List<Object?> get props => [tripPlanId];
}

class LoadTripPlanDetails extends PlanningEvent {
  final String tripPlanId;

  const LoadTripPlanDetails({required this.tripPlanId});

  @override
  List<Object?> get props => [tripPlanId];
}

class AddItineraryItem extends PlanningEvent {
  final String tripPlanId;
  final ItineraryItem itineraryItem;

  const AddItineraryItem({
    required this.tripPlanId,
    required this.itineraryItem,
  });

  @override
  List<Object?> get props => [tripPlanId, itineraryItem];
}

class UpdateItineraryItem extends PlanningEvent {
  final String tripPlanId;
  final ItineraryItem itineraryItem;

  const UpdateItineraryItem({
    required this.tripPlanId,
    required this.itineraryItem,
  });

  @override
  List<Object?> get props => [tripPlanId, itineraryItem];
}

class DeleteItineraryItem extends PlanningEvent {
  final String tripPlanId;
  final String itineraryItemId;

  const DeleteItineraryItem({
    required this.tripPlanId,
    required this.itineraryItemId,
  });

  @override
  List<Object?> get props => [tripPlanId, itineraryItemId];
}

class ReorderItineraryItems extends PlanningEvent {
  final String tripPlanId;
  final List<String> itemIds;

  const ReorderItineraryItems({
    required this.tripPlanId,
    required this.itemIds,
  });

  @override
  List<Object?> get props => [tripPlanId, itemIds];
}

class ShareTripPlan extends PlanningEvent {
  final String tripPlanId;
  final List<String> shareWith;
  final SharePermissions permissions;

  const ShareTripPlan({
    required this.tripPlanId,
    required this.shareWith,
    this.permissions = SharePermissions.view,
  });

  @override
  List<Object?> get props => [tripPlanId, shareWith, permissions];
}

class SyncTripPlans extends PlanningEvent {
  final String userId;

  const SyncTripPlans({required this.userId});

  @override
  List<Object?> get props => [userId];
}
