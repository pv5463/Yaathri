import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseModel>>> getExpenses({
    required String userId,
    String? tripId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, ExpenseModel>> getExpenseById(String expenseId);

  Future<Either<Failure, ExpenseModel>> createExpense(ExpenseModel expense);

  Future<Either<Failure, ExpenseModel>> updateExpense(ExpenseModel expense);

  Future<Either<Failure, void>> deleteExpense(String expenseId);

  Future<Either<Failure, List<BudgetModel>>> getBudgets({
    required String userId,
    String? tripId,
  });

  Future<Either<Failure, BudgetModel>> createBudget(BudgetModel budget);

  Future<Either<Failure, BudgetModel>> updateBudget(BudgetModel budget);

  Future<Either<Failure, void>> deleteBudget(String budgetId);

  Future<Either<Failure, List<ExpenseModel>>> syncExpenses(String userId);
}
