class AppConfig {
  static const String appName = 'TravelSync';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  static const String apiVersion = 'v1';
  static const String apiUrl = '$baseUrl/$apiVersion';
  
  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'dsowqiw1n';
  static const String cloudinaryApiKey = '459754623547978';
  static const String cloudinaryApiSecret = 'nVqz3MTBvS4KSJAB8q5pPiX4tAQ';
  static const String cloudinaryUploadPreset = 'travel_sync_preset';
  
  // Database Configuration
  static const String databaseName = 'travel_sync.db';
  static const int databaseVersion = 1;
  
  // Location Configuration
  static const double locationAccuracy = 10.0; // meters
  static const int locationUpdateInterval = 30; // seconds
  static const double tripDetectionRadius = 100.0; // meters
  
  // Background Task Configuration
  static const String tripTrackingTask = 'trip_tracking_task';
  static const String dataSyncTask = 'data_sync_task';
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String tripBox = 'trip_box';
  static const String expenseBox = 'expense_box';
  static const String settingsBox = 'settings_box';
  
  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String authToken = 'auth_token';
  static const String lastSyncTime = 'last_sync_time';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundTracking = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
