enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.production;
  
  static Environment get currentEnvironment => _currentEnvironment;
  
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:5000/api';
      case Environment.staging:
        return 'https://yaathri-staging.onrender.com/api';
      case Environment.production:
        return 'https://yaathri.onrender.com/api';
    }
  }
  
  // Fallback URLs in case primary server is down
  static List<String> get fallbackUrls => [
    'http://localhost:5000/api', // Local development server
    'https://yaathri-staging.onrender.com/api',
    'https://yaathri-backend.onrender.com/api',
  ];
  
  static String get apiUrl => '$baseUrl/v1';
  
  // API endpoint paths
  static String get authEndpoint => '$apiUrl/auth';
  static String get usersEndpoint => '$apiUrl/users';
  static String get tripsEndpoint => '$apiUrl/trips';
  static String get expensesEndpoint => '$apiUrl/expenses';
  
  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
  
  // Feature flags based on environment
  static bool get enableDebugMode => !isProduction;
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashReporting => isProduction;
  static bool get enableDetailedLogging => isDevelopment;
}
