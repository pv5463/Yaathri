import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/expense_model.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../core/error/failures.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;

  ExpenseBloc({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<CreateExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadExpenseDetails>(_onLoadExpenseDetails);
    on<LoadBudgets>(_onLoadBudgets);
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<SyncExpenses>(_onSyncExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.getExpenses(
        userId: event.userId,
        tripId: event.tripId,
        limit: event.limit,
        offset: event.offset,
      );
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (expenses) => emit(ExpenseLoaded(expenses: expenses)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCreateExpense(
    CreateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.createExpense(event.expense);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (expense) => emit(ExpenseCreated(expense: expense)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to create expense'));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.updateExpense(event.expense);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (expense) => emit(ExpenseUpdated(expense: expense)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to update expense'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.deleteExpense(event.expenseId);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (_) => emit(ExpenseDeleted(expenseId: event.expenseId)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to delete expense'));
    }
  }

  Future<void> _onLoadExpenseDetails(
    LoadExpenseDetails event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.getExpenseById(event.expenseId);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (expense) => emit(ExpenseDetailsLoaded(expense: expense)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to load expense details'));
    }
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.getBudgets(
        userId: event.userId,
        tripId: event.tripId,
      );
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (budgets) => emit(BudgetsLoaded(budgets: budgets)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to load budgets'));
    }
  }

  Future<void> _onCreateBudget(
    CreateBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.createBudget(event.budget);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (budget) => emit(BudgetCreated(budget: budget)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to create budget'));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.updateBudget(event.budget);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (budget) => emit(BudgetUpdated(budget: budget)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to update budget'));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    
    try {
      final result = await _expenseRepository.deleteBudget(event.budgetId);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (_) => emit(BudgetDeleted(budgetId: event.budgetId)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to delete budget'));
    }
  }

  Future<void> _onSyncExpenses(
    SyncExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final result = await _expenseRepository.syncExpenses(event.userId);
      
      result.fold(
        (failure) => emit(ExpenseError(message: _mapFailureToMessage(failure))),
        (expenses) => emit(ExpensesSynced(expenses: expenses)),
      );
    } catch (e) {
      emit(const ExpenseError(message: 'Failed to sync expenses'));
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
      case ExpenseFailure:
        return failure.message ?? 'Expense operation failed.';
      case BudgetExceededFailure:
        return 'Budget exceeded for this category.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
