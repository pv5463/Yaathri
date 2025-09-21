part of 'planning_bloc.dart';

abstract class PlanningState extends Equatable {
  const PlanningState();

  @override
  List<Object?> get props => [];
}

class PlanningInitial extends PlanningState {}

class PlanningLoading extends PlanningState {}

class PlanningLoaded extends PlanningState {
  final List<TripPlanModel> tripPlans;

  const PlanningLoaded({required this.tripPlans});

  @override
  List<Object?> get props => [tripPlans];
}

class TripPlanCreated extends PlanningState {
  final TripPlanModel tripPlan;

  const TripPlanCreated({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class TripPlanUpdated extends PlanningState {
  final TripPlanModel tripPlan;

  const TripPlanUpdated({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class TripPlanDeleted extends PlanningState {
  final String tripPlanId;

  const TripPlanDeleted({required this.tripPlanId});

  @override
  List<Object?> get props => [tripPlanId];
}

class TripPlanDetailsLoaded extends PlanningState {
  final TripPlanModel tripPlan;

  const TripPlanDetailsLoaded({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class ItineraryItemAdded extends PlanningState {
  final TripPlanModel tripPlan;

  const ItineraryItemAdded({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class ItineraryItemUpdated extends PlanningState {
  final TripPlanModel tripPlan;

  const ItineraryItemUpdated({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class ItineraryItemDeleted extends PlanningState {
  final TripPlanModel tripPlan;

  const ItineraryItemDeleted({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class ItineraryItemsReordered extends PlanningState {
  final TripPlanModel tripPlan;

  const ItineraryItemsReordered({required this.tripPlan});

  @override
  List<Object?> get props => [tripPlan];
}

class TripPlanShared extends PlanningState {
  final ShareInfo shareInfo;

  const TripPlanShared({required this.shareInfo});

  @override
  List<Object?> get props => [shareInfo];
}

class TripPlansSynced extends PlanningState {
  final List<TripPlanModel> tripPlans;

  const TripPlansSynced({required this.tripPlans});

  @override
  List<Object?> get props => [tripPlans];
}

class PlanningError extends PlanningState {
  final String message;

  const PlanningError({required this.message});

  @override
  List<Object?> get props => [message];
}
