import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ExpenseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ExpenseModel>>> getExpenses({
    required String userId,
    String? tripId,
    int? limit,
    int? offset,
  }) async {
    try {
      // Always try to get cached data first
      final cachedExpenses = await localDataSource.getCachedExpenses(userId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get fresh data from server
          final expenses = await remoteDataSource.getExpenses(
            userId,
            tripId: tripId,
            limit: limit,
            offset: offset,
          );
          
          // Cache the fresh data
          await localDataSource.cacheExpenses(expenses);
          return Right(expenses);
        } on ServerException catch (e) {
          // If server fails, return cached data if available
          if (cachedExpenses.isNotEmpty) {
            return Right(cachedExpenses);
          }
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // No network, return cached data
        return Right(cachedExpenses);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> getExpenseById(String expenseId) async {
    try {
      // Try to get from cache first
      final cachedExpense = await localDataSource.getCachedExpense(expenseId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get fresh data from server
          final expense = await remoteDataSource.getExpenseById(expenseId);
          
          // Cache the fresh data
          await localDataSource.cacheExpense(expense);
          return Right(expense);
        } on ServerException catch (e) {
          // If server fails, return cached data if available
          if (cachedExpense != null) {
            return Right(cachedExpense);
          }
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // No network, return cached data
        if (cachedExpense != null) {
          return Right(cachedExpense);
        }
        return const Left(NetworkFailure());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> createExpense(ExpenseModel expense) async {
    if (await networkInfo.isConnected) {
      try {
        final createdExpense = await remoteDataSource.createExpense(expense.toJson());
        await localDataSource.cacheExpense(createdExpense);
        return Right(createdExpense);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('create_expense', expense.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> updateExpense(ExpenseModel expense) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedExpense = await remoteDataSource.updateExpense(expense.id, expense.toJson());
        await localDataSource.cacheExpense(updatedExpense);
        return Right(updatedExpense);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('update_expense', expense.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteExpense(expenseId);
        await localDataSource.deleteCachedExpense(expenseId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('delete_expense', {
        'id': expenseId,
      });
      return const Left(NetworkFailure());
    }
  }

  Future<Either<Failure, List<String>>> getExpenseCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getExpenseCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Return default categories when offline
      return const Right([
        'Food & Dining',
        'Transportation',
        'Accommodation',
        'Entertainment',
        'Shopping',
        'Healthcare',
        'Miscellaneous',
      ]);
    }
  }

  @override
  Future<Either<Failure, List<BudgetModel>>> getBudgets({
    required String userId,
    String? tripId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final budgets = await remoteDataSource.getBudgets(userId, tripId: tripId);
        return Right(budgets);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, BudgetModel>> createBudget(BudgetModel budget) async {
    if (await networkInfo.isConnected) {
      try {
        final createdBudget = await remoteDataSource.createBudget(budget.toJson());
        return Right(createdBudget);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('create_budget', budget.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, BudgetModel>> updateBudget(BudgetModel budget) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedBudget = await remoteDataSource.updateBudget(budget.id, budget.toJson());
        return Right(updatedBudget);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('update_budget', budget.toJson());
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String budgetId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBudget(budgetId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Store for offline sync
      await localDataSource.addPendingSyncData('delete_budget', {
        'id': budgetId,
      });
      return const Left(NetworkFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getExpenseSummary({
    required String userId,
    required String period,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final summary = await remoteDataSource.getExpenseSummary(userId, period);
        return Right(summary);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  Future<Either<Failure, double>> getTotalExpenses({
    required String userId,
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await localDataSource.getCachedExpenses(userId);
      
      // Filter expenses based on criteria
      var filteredExpenses = expenses;
      
      if (tripId != null) {
        filteredExpenses = filteredExpenses.where((e) => e.tripId == tripId).toList();
      }
      
      if (startDate != null) {
        filteredExpenses = filteredExpenses.where((e) => e.date.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredExpenses = filteredExpenses.where((e) => e.date.isBefore(endDate)).toList();
      }
      
      final total = filteredExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  Future<Either<Failure, Map<String, double>>> getExpensesByCategory({
    required String userId,
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await localDataSource.getCachedExpenses(userId);
      
      // Filter expenses based on criteria
      var filteredExpenses = expenses;
      
      if (tripId != null) {
        filteredExpenses = filteredExpenses.where((e) => e.tripId == tripId).toList();
      }
      
      if (startDate != null) {
        filteredExpenses = filteredExpenses.where((e) => e.date.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredExpenses = filteredExpenses.where((e) => e.date.isBefore(endDate)).toList();
      }
      
      final Map<String, double> categoryTotals = {};
      
      for (final expense in filteredExpenses) {
        final category = expense.category.toString().split('.').last;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
      }
      
      return Right(categoryTotals);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> syncExpenses(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get pending sync data
        final pendingCreates = await localDataSource.getPendingSyncData('create_expense');
        final pendingUpdates = await localDataSource.getPendingSyncData('update_expense');
        final pendingDeletes = await localDataSource.getPendingSyncData('delete_expense');
        
        // Sync all pending changes
        final syncData = {
          'user_id': userId,
          'creates': pendingCreates,
          'updates': pendingUpdates,
          'deletes': pendingDeletes,
        };
        
        await remoteDataSource.syncData(syncData);
        
        // Get fresh expenses from server
        final expenses = await remoteDataSource.getExpenses(userId);
        await localDataSource.cacheExpenses(expenses);
        
        // Clear pending sync data after successful sync
        await localDataSource.clearPendingSyncData('create_expense');
        await localDataSource.clearPendingSyncData('update_expense');
        await localDataSource.clearPendingSyncData('delete_expense');
        
        return Right(expenses);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
