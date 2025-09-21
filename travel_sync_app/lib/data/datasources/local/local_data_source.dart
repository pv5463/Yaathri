import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../models/expense_model.dart';

abstract class LocalDataSource {
  // User data
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserCache();

  // Trip data
  Future<List<TripModel>> getCachedTrips(String userId);
  Future<TripModel?> getCachedTrip(String tripId);
  Future<void> cacheTrip(TripModel trip);
  Future<void> cacheTrips(List<TripModel> trips);
  Future<void> deleteCachedTrip(String tripId);
  Future<void> clearTripsCache();

  // Expense data
  Future<List<ExpenseModel>> getCachedExpenses(String userId);
  Future<ExpenseModel?> getCachedExpense(String expenseId);
  Future<void> cacheExpense(ExpenseModel expense);
  Future<void> cacheExpenses(List<ExpenseModel> expenses);
  Future<void> deleteCachedExpense(String expenseId);
  Future<void> clearExpensesCache();

  // Settings and preferences
  Future<String?> getAuthToken();
  Future<void> saveAuthToken(String token);
  Future<void> clearAuthToken();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunch(bool isFirst);
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);

  // Offline data management
  Future<void> addPendingSyncData(String type, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getPendingSyncData(String type);
  Future<void> removePendingSyncData(String type, String id);
  Future<void> clearPendingSyncData(String type);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _sharedPreferences;
  final Box _userBox;
  final Box _tripBox;
  final Box _expenseBox;
  final Box _settingsBox;

  LocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    Box? userBox,
    Box? tripBox,
    Box? expenseBox,
    Box? settingsBox,
  })  : _sharedPreferences = sharedPreferences,
        _userBox = userBox ?? Hive.box(AppConfig.userBox),
        _tripBox = tripBox ?? Hive.box(AppConfig.tripBox),
        _expenseBox = expenseBox ?? Hive.box(AppConfig.expenseBox),
        _settingsBox = settingsBox ?? Hive.box(AppConfig.settingsBox);

  // User data methods
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = _userBox.get('current_user');
      if (userData != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _userBox.put('current_user', user.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _userBox.delete('current_user');
    } catch (e) {
      throw CacheException(message: 'Failed to clear user cache: $e');
    }
  }

  // Trip data methods
  @override
  Future<List<TripModel>> getCachedTrips(String userId) async {
    try {
      final tripsData = _tripBox.values
          .where((trip) => trip['userId'] == userId)
          .toList();
      
      return tripsData
          .map((data) => TripModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached trips: $e');
    }
  }

  @override
  Future<TripModel?> getCachedTrip(String tripId) async {
    try {
      final tripData = _tripBox.get(tripId);
      if (tripData != null) {
        return TripModel.fromJson(Map<String, dynamic>.from(tripData));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached trip: $e');
    }
  }

  @override
  Future<void> cacheTrip(TripModel trip) async {
    try {
      await _tripBox.put(trip.id, trip.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache trip: $e');
    }
  }

  @override
  Future<void> cacheTrips(List<TripModel> trips) async {
    try {
      final Map<String, Map<String, dynamic>> tripsMap = {
        for (var trip in trips) trip.id: trip.toJson()
      };
      await _tripBox.putAll(tripsMap);
    } catch (e) {
      throw CacheException(message: 'Failed to cache trips: $e');
    }
  }

  @override
  Future<void> deleteCachedTrip(String tripId) async {
    try {
      await _tripBox.delete(tripId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached trip: $e');
    }
  }

  @override
  Future<void> clearTripsCache() async {
    try {
      await _tripBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear trips cache: $e');
    }
  }

  // Expense data methods
  @override
  Future<List<ExpenseModel>> getCachedExpenses(String userId) async {
    try {
      final expensesData = _expenseBox.values
          .where((expense) => expense['userId'] == userId)
          .toList();
      
      return expensesData
          .map((data) => ExpenseModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached expenses: $e');
    }
  }

  @override
  Future<ExpenseModel?> getCachedExpense(String expenseId) async {
    try {
      final expenseData = _expenseBox.get(expenseId);
      if (expenseData != null) {
        return ExpenseModel.fromJson(Map<String, dynamic>.from(expenseData));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached expense: $e');
    }
  }

  @override
  Future<void> cacheExpense(ExpenseModel expense) async {
    try {
      await _expenseBox.put(expense.id, expense.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache expense: $e');
    }
  }

  @override
  Future<void> cacheExpenses(List<ExpenseModel> expenses) async {
    try {
      final Map<String, Map<String, dynamic>> expensesMap = {
        for (var expense in expenses) expense.id: expense.toJson()
      };
      await _expenseBox.putAll(expensesMap);
    } catch (e) {
      throw CacheException(message: 'Failed to cache expenses: $e');
    }
  }

  @override
  Future<void> deleteCachedExpense(String expenseId) async {
    try {
      await _expenseBox.delete(expenseId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached expense: $e');
    }
  }

  @override
  Future<void> clearExpensesCache() async {
    try {
      await _expenseBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear expenses cache: $e');
    }
  }

  // Settings and preferences methods
  @override
  Future<String?> getAuthToken() async {
    try {
      return _sharedPreferences.getString(AppConfig.authToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get auth token: $e');
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _sharedPreferences.setString(AppConfig.authToken, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _sharedPreferences.remove(AppConfig.authToken);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth token: $e');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return _sharedPreferences.getBool(AppConfig.isFirstLaunch) ?? true;
    } catch (e) {
      throw CacheException(message: 'Failed to check first launch: $e');
    }
  }

  @override
  Future<void> setFirstLaunch(bool isFirst) async {
    try {
      await _sharedPreferences.setBool(AppConfig.isFirstLaunch, isFirst);
    } catch (e) {
      throw CacheException(message: 'Failed to set first launch: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timestamp = _sharedPreferences.getInt(AppConfig.lastSyncTime);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get last sync time: $e');
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    try {
      await _sharedPreferences.setInt(
        AppConfig.lastSyncTime,
        time.millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to set last sync time: $e');
    }
  }

  // Offline data management methods
  @override
  Future<void> addPendingSyncData(String type, Map<String, dynamic> data) async {
    try {
      final key = 'pending_sync_$type';
      final existingData = _settingsBox.get(key, defaultValue: <Map<String, dynamic>>[]);
      final List<Map<String, dynamic>> pendingList = 
          List<Map<String, dynamic>>.from(existingData);
      
      pendingList.add(data);
      await _settingsBox.put(key, pendingList);
    } catch (e) {
      throw CacheException(message: 'Failed to add pending sync data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncData(String type) async {
    try {
      final key = 'pending_sync_$type';
      final data = _settingsBox.get(key, defaultValue: <Map<String, dynamic>>[]);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw CacheException(message: 'Failed to get pending sync data: $e');
    }
  }

  @override
  Future<void> removePendingSyncData(String type, String id) async {
    try {
      final key = 'pending_sync_$type';
      final existingData = _settingsBox.get(key, defaultValue: <Map<String, dynamic>>[]);
      final List<Map<String, dynamic>> pendingList = 
          List<Map<String, dynamic>>.from(existingData);
      
      pendingList.removeWhere((item) => item['id'] == id);
      await _settingsBox.put(key, pendingList);
    } catch (e) {
      throw CacheException(message: 'Failed to remove pending sync data: $e');
    }
  }

  @override
  Future<void> clearPendingSyncData(String type) async {
    try {
      final key = 'pending_sync_$type';
      await _settingsBox.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to clear pending sync data: $e');
    }
  }
}
