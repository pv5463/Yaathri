import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../models/expense_model.dart';

abstract class RemoteDataSource {
  // Authentication
  Future<UserModel> login(Map<String, dynamic> loginData);
  Future<UserModel> register(Map<String, dynamic> registerData);
  Future<UserModel> socialLogin(Map<String, dynamic> socialData);
  Future<String> phoneLogin(Map<String, dynamic> phoneData);
  Future<UserModel> verifyOtp(Map<String, dynamic> otpData);
  Future<String> forgotPassword(Map<String, dynamic> emailData);
  Future<String> resetPassword(Map<String, dynamic> resetData);
  Future<String> logout();
  Future<UserModel> getCurrentUser();

  // User management
  Future<UserModel> updateUser(String userId, Map<String, dynamic> userData);
  Future<String> deleteUser(String userId);

  // Trip management
  Future<List<TripModel>> getTrips(String userId, {int? limit, int? offset, String? status});
  Future<TripModel> getTripById(String tripId);
  Future<TripModel> createTrip(Map<String, dynamic> tripData);
  Future<TripModel> updateTrip(String tripId, Map<String, dynamic> tripData);
  Future<String> deleteTrip(String tripId);
  Future<TripModel> addLocationPoint(String tripId, Map<String, dynamic> locationData);
  Future<TripModel> addTripMedia(String tripId, Map<String, dynamic> mediaData);
  Future<TripModel> removeTripMedia(String tripId, String mediaUrl);
  Future<List<TripModel>> syncTrips(Map<String, dynamic> syncData);

  // Expense management
  Future<List<ExpenseModel>> getExpenses(String userId, {String? tripId, int? limit, int? offset});
  Future<ExpenseModel> getExpenseById(String expenseId);
  Future<ExpenseModel> createExpense(Map<String, dynamic> expenseData);
  Future<ExpenseModel> updateExpense(String expenseId, Map<String, dynamic> expenseData);
  Future<String> deleteExpense(String expenseId);
  Future<List<String>> getExpenseCategories();

  // Budget management
  Future<List<BudgetModel>> getBudgets(String userId, {String? tripId});
  Future<BudgetModel> createBudget(Map<String, dynamic> budgetData);
  Future<BudgetModel> updateBudget(String budgetId, Map<String, dynamic> budgetData);
  Future<String> deleteBudget(String budgetId);

  // Analytics
  Future<Map<String, dynamic>> getTravelInsights(String userId, String period);
  Future<Map<String, dynamic>> getExpenseSummary(String userId, String period);

  // Media
  Future<Map<String, dynamic>> uploadMedia(String filePath, String type, {String? tripId});
  Future<String> deleteMedia(String mediaId);

  // Sync
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData);
  Future<Map<String, dynamic>> getSyncStatus(String userId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient _apiClient;

  RemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> login(Map<String, dynamic> loginData) async {
    try {
      final response = await _apiClient.login(loginData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Login failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> registerData) async {
    try {
      final response = await _apiClient.register(registerData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Registration failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<UserModel> socialLogin(Map<String, dynamic> socialData) async {
    try {
      final response = await _apiClient.socialLogin(socialData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Social login failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> phoneLogin(Map<String, dynamic> phoneData) async {
    try {
      final response = await _apiClient.phoneLogin(phoneData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Phone login failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<UserModel> verifyOtp(Map<String, dynamic> otpData) async {
    try {
      final response = await _apiClient.verifyOtp(otpData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'OTP verification failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> forgotPassword(Map<String, dynamic> emailData) async {
    try {
      final response = await _apiClient.forgotPassword(emailData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Password reset failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> resetPassword(Map<String, dynamic> resetData) async {
    try {
      final response = await _apiClient.resetPassword(resetData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Password reset failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> logout() async {
    try {
      final response = await _apiClient.logout();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Logout failed');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.getCurrentUser();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get user');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<UserModel> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.updateUser(userId, userData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to update user');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> deleteUser(String userId) async {
    try {
      final response = await _apiClient.deleteUser(userId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to delete user');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<List<TripModel>> getTrips(String userId, {int? limit, int? offset, String? status}) async {
    try {
      final response = await _apiClient.getTrips(userId, limit, offset, status);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get trips');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    try {
      final response = await _apiClient.getTripById(tripId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get trip');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await _apiClient.createTrip(tripData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to create trip');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> updateTrip(String tripId, Map<String, dynamic> tripData) async {
    try {
      final response = await _apiClient.updateTrip(tripId, tripData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to update trip');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> deleteTrip(String tripId) async {
    try {
      final response = await _apiClient.deleteTrip(tripId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to delete trip');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> addLocationPoint(String tripId, Map<String, dynamic> locationData) async {
    try {
      final response = await _apiClient.addLocationPoint(tripId, locationData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to add location point');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> addTripMedia(String tripId, Map<String, dynamic> mediaData) async {
    try {
      final response = await _apiClient.addTripMedia(tripId, mediaData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to add trip media');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<TripModel> removeTripMedia(String tripId, String mediaUrl) async {
    try {
      final response = await _apiClient.removeTripMedia(tripId, mediaUrl);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to remove trip media');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<List<TripModel>> syncTrips(Map<String, dynamic> syncData) async {
    try {
      final response = await _apiClient.syncTrips(syncData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to sync trips');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String userId, {String? tripId, int? limit, int? offset}) async {
    try {
      final response = await _apiClient.getExpenses(userId, tripId, limit, offset);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get expenses');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String expenseId) async {
    try {
      final response = await _apiClient.getExpenseById(expenseId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get expense');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<ExpenseModel> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _apiClient.createExpense(expenseData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to create expense');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<ExpenseModel> updateExpense(String expenseId, Map<String, dynamic> expenseData) async {
    try {
      final response = await _apiClient.updateExpense(expenseId, expenseData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to update expense');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> deleteExpense(String expenseId) async {
    try {
      final response = await _apiClient.deleteExpense(expenseId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to delete expense');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<List<String>> getExpenseCategories() async {
    try {
      final response = await _apiClient.getExpenseCategories();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get expense categories');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<List<BudgetModel>> getBudgets(String userId, {String? tripId}) async {
    try {
      final response = await _apiClient.getBudgets(userId, tripId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get budgets');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<BudgetModel> createBudget(Map<String, dynamic> budgetData) async {
    try {
      final response = await _apiClient.createBudget(budgetData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to create budget');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<BudgetModel> updateBudget(String budgetId, Map<String, dynamic> budgetData) async {
    try {
      final response = await _apiClient.updateBudget(budgetId, budgetData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to update budget');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> deleteBudget(String budgetId) async {
    try {
      final response = await _apiClient.deleteBudget(budgetId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to delete budget');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getTravelInsights(String userId, String period) async {
    try {
      final response = await _apiClient.getTravelInsights(userId, period);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get travel insights');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getExpenseSummary(String userId, String period) async {
    try {
      final response = await _apiClient.getExpenseSummary(userId, period);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get expense summary');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> uploadMedia(String filePath, String type, {String? tripId}) async {
    try {
      // This would need to be implemented with multipart file upload
      // For now, returning a placeholder
      throw UnimplementedError('Media upload not yet implemented');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<String> deleteMedia(String mediaId) async {
    try {
      final response = await _apiClient.deleteMedia(mediaId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to delete media');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData) async {
    try {
      final response = await _apiClient.syncData(syncData);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to sync data');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getSyncStatus(String userId) async {
    try {
      final response = await _apiClient.getSyncStatus(userId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ServerException(message: response.message ?? 'Failed to get sync status');
    } on DioException catch (e) {
      throw ServerException(message: _handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
