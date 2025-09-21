part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final String userId;
  final String? tripId;
  final int? limit;
  final int? offset;

  const LoadExpenses({
    required this.userId,
    this.tripId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, tripId, limit, offset];
}

class CreateExpense extends ExpenseEvent {
  final ExpenseModel expense;

  const CreateExpense({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final ExpenseModel expense;

  const UpdateExpense({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

class LoadExpenseDetails extends ExpenseEvent {
  final String expenseId;

  const LoadExpenseDetails({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

class LoadBudgets extends ExpenseEvent {
  final String userId;
  final String? tripId;

  const LoadBudgets({
    required this.userId,
    this.tripId,
  });

  @override
  List<Object?> get props => [userId, tripId];
}

class CreateBudget extends ExpenseEvent {
  final BudgetModel budget;

  const CreateBudget({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class UpdateBudget extends ExpenseEvent {
  final BudgetModel budget;

  const UpdateBudget({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends ExpenseEvent {
  final String budgetId;

  const DeleteBudget({required this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}

class SyncExpenses extends ExpenseEvent {
  final String userId;

  const SyncExpenses({required this.userId});

  @override
  List<Object?> get props => [userId];
}
