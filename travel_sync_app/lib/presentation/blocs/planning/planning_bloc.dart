import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/trip_plan_model.dart';
import '../../../domain/repositories/planning_repository.dart';
import '../../../core/error/failures.dart';

part 'planning_event.dart';
part 'planning_state.dart';

class PlanningBloc extends Bloc<PlanningEvent, PlanningState> {
  final PlanningRepository _planningRepository;

  PlanningBloc({required PlanningRepository planningRepository})
      : _planningRepository = planningRepository,
        super(PlanningInitial()) {
    on<LoadTripPlans>(_onLoadTripPlans);
    on<CreateTripPlan>(_onCreateTripPlan);
    on<UpdateTripPlan>(_onUpdateTripPlan);
    on<DeleteTripPlan>(_onDeleteTripPlan);
    on<LoadTripPlanDetails>(_onLoadTripPlanDetails);
    on<AddItineraryItem>(_onAddItineraryItem);
    on<UpdateItineraryItem>(_onUpdateItineraryItem);
    on<DeleteItineraryItem>(_onDeleteItineraryItem);
    on<ReorderItineraryItems>(_onReorderItineraryItems);
    on<ShareTripPlan>(_onShareTripPlan);
    on<SyncTripPlans>(_onSyncTripPlans);
  }

  Future<void> _onLoadTripPlans(
    LoadTripPlans event,
    Emitter<PlanningState> emit,
  ) async {
    emit(PlanningLoading());
    
    try {
      final result = await _planningRepository.getTripPlans(
        userId: event.userId,
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlans) => emit(PlanningLoaded(tripPlans: tripPlans)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCreateTripPlan(
    CreateTripPlan event,
    Emitter<PlanningState> emit,
  ) async {
    emit(PlanningLoading());
    
    try {
      final result = await _planningRepository.createTripPlan(event.tripPlan);
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(TripPlanCreated(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to create trip plan'));
    }
  }

  Future<void> _onUpdateTripPlan(
    UpdateTripPlan event,
    Emitter<PlanningState> emit,
  ) async {
    emit(PlanningLoading());
    
    try {
      final result = await _planningRepository.updateTripPlan(event.tripPlan);
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(TripPlanUpdated(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to update trip plan'));
    }
  }

  Future<void> _onDeleteTripPlan(
    DeleteTripPlan event,
    Emitter<PlanningState> emit,
  ) async {
    emit(PlanningLoading());
    
    try {
      final result = await _planningRepository.deleteTripPlan(event.tripPlanId);
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (_) => emit(TripPlanDeleted(tripPlanId: event.tripPlanId)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to delete trip plan'));
    }
  }

  Future<void> _onLoadTripPlanDetails(
    LoadTripPlanDetails event,
    Emitter<PlanningState> emit,
  ) async {
    emit(PlanningLoading());
    
    try {
      final result = await _planningRepository.getTripPlanById(event.tripPlanId);
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(TripPlanDetailsLoaded(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to load trip plan details'));
    }
  }

  Future<void> _onAddItineraryItem(
    AddItineraryItem event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.addItineraryItem(
        tripPlanId: event.tripPlanId,
        itineraryItem: event.itineraryItem,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(ItineraryItemAdded(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to add itinerary item'));
    }
  }

  Future<void> _onUpdateItineraryItem(
    UpdateItineraryItem event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.updateItineraryItem(
        tripPlanId: event.tripPlanId,
        itineraryItem: event.itineraryItem,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(ItineraryItemUpdated(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to update itinerary item'));
    }
  }

  Future<void> _onDeleteItineraryItem(
    DeleteItineraryItem event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.deleteItineraryItem(
        tripPlanId: event.tripPlanId,
        itineraryItemId: event.itineraryItemId,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(ItineraryItemDeleted(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to delete itinerary item'));
    }
  }

  Future<void> _onReorderItineraryItems(
    ReorderItineraryItems event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.reorderItineraryItems(
        tripPlanId: event.tripPlanId,
        itemIds: event.itemIds,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlan) => emit(ItineraryItemsReordered(tripPlan: tripPlan)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to reorder itinerary items'));
    }
  }

  Future<void> _onShareTripPlan(
    ShareTripPlan event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.shareTripPlan(
        tripPlanId: event.tripPlanId,
        shareWith: event.shareWith,
        permissions: event.permissions,
      );
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (shareInfo) => emit(TripPlanShared(shareInfo: shareInfo)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to share trip plan'));
    }
  }

  Future<void> _onSyncTripPlans(
    SyncTripPlans event,
    Emitter<PlanningState> emit,
  ) async {
    try {
      final result = await _planningRepository.syncTripPlans(event.userId);
      
      result.fold(
        (failure) => emit(PlanningError(message: _mapFailureToMessage(failure))),
        (tripPlans) => emit(TripPlansSynced(tripPlans: tripPlans)),
      );
    } catch (e) {
      emit(const PlanningError(message: 'Failed to sync trip plans'));
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
      case ValidationFailure:
        return failure.message ?? 'Invalid input provided.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
