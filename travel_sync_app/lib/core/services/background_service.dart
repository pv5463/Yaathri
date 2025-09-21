import 'dart:async';
import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../../data/models/trip_model.dart';

class BackgroundService {
  static const String _tripTrackingTask = AppConfig.tripTrackingTask;
  static const String _dataSyncTask = AppConfig.dataSyncTask;

  /// Initialize background tasks
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Start trip tracking in background
  static Future<void> startTripTracking(String tripId) async {
    await Workmanager().registerPeriodicTask(
      _tripTrackingTask,
      _tripTrackingTask,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
      inputData: {
        'tripId': tripId,
        'startTime': DateTime.now().millisecondsSinceEpoch,
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Stop trip tracking
  static Future<void> stopTripTracking() async {
    await Workmanager().cancelByUniqueName(_tripTrackingTask);
  }

  /// Start data synchronization
  static Future<void> startDataSync() async {
    await Workmanager().registerPeriodicTask(
      _dataSyncTask,
      _dataSyncTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  /// Stop data synchronization
  static Future<void> stopDataSync() async {
    await Workmanager().cancelByUniqueName(_dataSyncTask);
  }

  /// Handle background task execution
  static Future<bool> handleBackgroundTask(
    String task,
    Map<String, dynamic>? inputData,
  ) async {
    try {
      switch (task) {
        case _tripTrackingTask:
          return await _handleTripTracking(inputData);
        case _dataSyncTask:
          return await _handleDataSync(inputData);
        default:
          return false;
      }
    } catch (e) {
      print('Background task error: $e');
      return false;
    }
  }

  /// Handle trip tracking in background
  static Future<bool> _handleTripTracking(
    Map<String, dynamic>? inputData,
  ) async {
    if (inputData == null || !inputData.containsKey('tripId')) {
      return false;
    }

    try {
      final tripId = inputData['tripId'] as String;
      
      // Check if location permission is available
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      // Create location point
      final locationPoint = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
      );

      // Store location point locally
      await _storeLocationPoint(tripId, locationPoint);

      return true;
    } catch (e) {
      print('Trip tracking error: $e');
      return false;
    }
  }

  /// Handle data synchronization
  static Future<bool> _handleDataSync(
    Map<String, dynamic>? inputData,
  ) async {
    try {
      // Get pending sync data from local storage
      final prefs = await SharedPreferences.getInstance();
      final pendingTrips = prefs.getStringList('pending_sync_trips') ?? [];
      final pendingExpenses = prefs.getStringList('pending_sync_expenses') ?? [];

      // Sync trips
      for (final tripJson in pendingTrips) {
        final success = await _syncTrip(tripJson);
        if (success) {
          pendingTrips.remove(tripJson);
        }
      }

      // Sync expenses
      for (final expenseJson in pendingExpenses) {
        final success = await _syncExpense(expenseJson);
        if (success) {
          pendingExpenses.remove(expenseJson);
        }
      }

      // Update pending lists
      await prefs.setStringList('pending_sync_trips', pendingTrips);
      await prefs.setStringList('pending_sync_expenses', pendingExpenses);

      return true;
    } catch (e) {
      print('Data sync error: $e');
      return false;
    }
  }

  /// Store location point locally
  static Future<void> _storeLocationPoint(
    String tripId,
    LocationPoint locationPoint,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trip_locations_$tripId';
      final existingData = prefs.getStringList(key) ?? [];
      
      existingData.add(jsonEncode(locationPoint.toJson()));
      
      // Keep only last 1000 points to avoid storage issues
      if (existingData.length > 1000) {
        existingData.removeRange(0, existingData.length - 1000);
      }
      
      await prefs.setStringList(key, existingData);
    } catch (e) {
      print('Store location error: $e');
    }
  }

  /// Sync trip data to server
  static Future<bool> _syncTrip(String tripJson) async {
    try {
      // TODO: Implement actual API call to sync trip
      // This is a placeholder for the actual sync logic
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Return true if sync successful, false otherwise
      return true;
    } catch (e) {
      print('Trip sync error: $e');
      return false;
    }
  }

  /// Sync expense data to server
  static Future<bool> _syncExpense(String expenseJson) async {
    try {
      // TODO: Implement actual API call to sync expense
      // This is a placeholder for the actual sync logic
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Return true if sync successful, false otherwise
      return true;
    } catch (e) {
      print('Expense sync error: $e');
      return false;
    }
  }

  /// Get stored location points for a trip
  static Future<List<LocationPoint>> getStoredLocationPoints(
    String tripId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trip_locations_$tripId';
      final locationData = prefs.getStringList(key) ?? [];
      
      return locationData
          .map((json) => LocationPoint.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Get stored locations error: $e');
      return [];
    }
  }

  /// Clear stored location points for a trip
  static Future<void> clearStoredLocationPoints(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trip_locations_$tripId';
      await prefs.remove(key);
    } catch (e) {
      print('Clear stored locations error: $e');
    }
  }

  /// Add data to pending sync queue
  static Future<void> addToPendingSync(
    String type,
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pending_sync_$type';
      final pendingData = prefs.getStringList(key) ?? [];
      
      pendingData.add(jsonEncode(data));
      await prefs.setStringList(key, pendingData);
    } catch (e) {
      print('Add to pending sync error: $e');
    }
  }

  /// Check if background tasks are running
  static Future<bool> isTrackingActive() async {
    // This is a simplified check - in a real implementation,
    // you might want to check the actual task status
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('background_tracking_active') ?? false;
  }

  /// Set background tracking status
  static Future<void> setTrackingStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_tracking_active', isActive);
  }
}

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return BackgroundService.handleBackgroundTask(task, inputData);
  });
}
