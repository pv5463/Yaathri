import '../config/environment.dart';
import '../../data/models/user_model.dart';

class OfflineService {
  static bool _isOfflineMode = false;
  
  static bool get isOfflineMode => _isOfflineMode;
  
  static void enableOfflineMode() {
    _isOfflineMode = true;
    print('🔄 Offline mode enabled - Using mock data');
  }
  
  static void disableOfflineMode() {
    _isOfflineMode = false;
    print('🌐 Online mode enabled - Using live API');
  }
  
  // Mock user for offline testing
  static UserModel getMockUser() {
    return UserModel(
      id: 'offline_user_123',
      email: 'demo@yaathri.com',
      fullName: 'Demo User',
      phoneNumber: '+91 9876543210',
      profileImageUrl: null,
      travelPreferences: const ['Adventure', 'Culture', 'Food'],
      consentGiven: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      isVerified: true,
      settings: null,
    );
  }

  // Mock data for different features
  static Map<String, dynamic> getMockTripsData() {
    return {
      'trips': [
        {
          'id': 'trip_1',
          'userId': 'offline_user_123',
          'origin': 'Home',
          'destination': 'Office',
          'status': 'inProgress',
          'distance': 12.5,
          'duration': 135,
          'startTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'travelMode': 'driving',
          'tripType': 'business',
          'notes': 'Daily commute to office',
        },
        {
          'id': 'trip_2',
          'userId': 'offline_user_123',
          'origin': 'Delhi',
          'destination': 'Goa',
          'status': 'completed',
          'distance': 1850.0,
          'duration': 4320,
          'startTime': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'endTime': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'travelMode': 'flight',
          'tripType': 'leisure',
          'notes': 'Amazing beach vacation with friends',
        },
      ],
      'currentTrip': {
        'id': 'trip_1',
        'origin': 'Home',
        'destination': 'Office',
        'status': 'inProgress',
        'duration': '2h 15m',
      }
    };
  }

  static Map<String, dynamic> getMockPlanningData() {
    return {
      'tripPlans': [
        {
          'id': 'plan_1',
          'userId': 'offline_user_123',
          'title': 'Weekend Getaway to Manali',
          'description': 'A relaxing weekend trip to the mountains',
          'destination': 'Manali, Himachal Pradesh',
          'budget': 25000.0,
          'status': 'confirmed',
          'startDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 17)).toIso8601String(),
        },
        {
          'id': 'plan_2',
          'userId': 'offline_user_123',
          'title': 'Kerala Backwaters Tour',
          'description': 'Exploring the beautiful backwaters of Kerala',
          'destination': 'Alleppey, Kerala',
          'budget': 40000.0,
          'status': 'draft',
          'startDate': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 50)).toIso8601String(),
        },
      ]
    };
  }

  static Map<String, dynamic> getMockExpensesData() {
    return {
      'expenses': [
        {
          'id': 'expense_1',
          'userId': 'offline_user_123',
          'tripId': 'trip_1',
          'title': 'Petrol for office commute',
          'amount': 1200.0,
          'currency': 'INR',
          'category': 'fuel',
          'date': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'location': 'Shell Petrol Pump',
        },
        {
          'id': 'expense_2',
          'userId': 'offline_user_123',
          'tripId': 'trip_2',
          'title': 'Beach resort stay',
          'amount': 8500.0,
          'currency': 'INR',
          'category': 'accommodation',
          'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'location': 'Goa Beach Resort',
        },
      ],
      'totalExpenses': 15100.0,
      'monthlyExpenses': 9700.0,
    };
  }
  
  // Mock login response
  static Future<Map<String, dynamic>> mockLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Accept any email/password for demo
    if (email.isNotEmpty && password.length >= 6) {
      return {
        'success': true,
        'user': getMockUser().toJson(),
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Login successful (Offline Mode)',
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    }
  }
  
  // Mock register response
  static Future<Map<String, dynamic>> mockRegister(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final user = getMockUser().copyWith(
      email: userData['email'] ?? 'demo@yaathri.com',
      fullName: userData['fullName'] ?? 'Demo User',
      phoneNumber: userData['phoneNumber'],
    );
    
    return {
      'success': true,
      'user': user.toJson(),
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Registration successful (Offline Mode)',
    };
  }
  
  // Check if we should use offline mode
  static Future<bool> shouldUseOfflineMode() async {
    if (EnvironmentConfig.isDevelopment) {
      // In development, allow offline mode for testing
      return true;
    }
    
    // In production, only use offline mode if server is unreachable
    // This will be determined by the robust API client
    return false;
  }
  
  // Get offline status message
  static String getOfflineStatusMessage() {
    if (_isOfflineMode) {
      return '📱 Running in offline mode with demo data';
    } else {
      return '🌐 Connected to live server';
    }
  }
}
