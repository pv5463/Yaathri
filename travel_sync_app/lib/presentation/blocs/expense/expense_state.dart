part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;

  const ExpenseLoaded({required this.expenses});

  @override
  List<Object?> get props => [expenses];
}

class ExpenseCreated extends ExpenseState {
  final ExpenseModel expense;

  const ExpenseCreated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseUpdated extends ExpenseState {
  final ExpenseModel expense;

  const ExpenseUpdated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseDeleted extends ExpenseState {
  final String expenseId;

  const ExpenseDeleted({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

class ExpenseDetailsLoaded extends ExpenseState {
  final ExpenseModel expense;

  const ExpenseDetailsLoaded({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class BudgetsLoaded extends ExpenseState {
  final List<BudgetModel> budgets;

  const BudgetsLoaded({required this.budgets});

  @override
  List<Object?> get props => [budgets];
}

class BudgetCreated extends ExpenseState {
  final BudgetModel budget;

  const BudgetCreated({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class BudgetUpdated extends ExpenseState {
  final BudgetModel budget;

  const BudgetUpdated({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class BudgetDeleted extends ExpenseState {
  final String budgetId;

  const BudgetDeleted({required this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}

class ExpensesSynced extends ExpenseState {
  final List<ExpenseModel> expenses;

  const ExpensesSynced({required this.expenses});

  @override
  List<Object?> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({required this.message});

  @override
  List<Object?> get props => [message];
}
