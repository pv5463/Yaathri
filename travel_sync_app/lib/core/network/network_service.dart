import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../config/environment.dart';
import 'api_client.dart';

class NetworkService {
  static NetworkService? _instance;
  late Dio _dio;
  late ApiClient _apiClient;

  NetworkService._internal() {
    _initializeDio();
    _apiClient = ApiClient(_dio, baseUrl: AppConfig.apiUrl);
  }

  static NetworkService get instance {
    _instance ??= NetworkService._internal();
    return _instance!;
  }

  ApiClient get apiClient => _apiClient;

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    
    // Add logging in development
    if (EnvironmentConfig.enableDetailedLogging) {
      _dio.interceptors.add(_createLoggingInterceptor());
    }

    // Add error handling interceptor
    _dio.interceptors.add(_createErrorInterceptor());
  }

  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
        print('Headers: ${options.headers}');
        if (options.data != null) {
          print('Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        print('Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('Message: ${error.message}');
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors by refreshing token
        if (error.response?.statusCode == 401) {
          // Implement token refresh logic here
          // For now, just clear the token and redirect to login
          await _clearAuthToken();
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Log errors in development
        if (EnvironmentConfig.enableDetailedLogging) {
          print('API Error: ${error.message}');
          print('Status Code: ${error.response?.statusCode}');
          print('Response Data: ${error.response?.data}');
        }
        
        // Transform error messages for better UX
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          error = DioException(
            requestOptions: error.requestOptions,
            message: 'Connection timeout. Please check your internet connection.',
          );
        } else if (error.type == DioExceptionType.connectionError) {
          error = DioException(
            requestOptions: error.requestOptions,
            message: 'Unable to connect to server. Please try again later.',
          );
        }
        
        handler.next(error);
      },
    );
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.authToken);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> _clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.authToken);
      await prefs.setBool(AppConfig.isLoggedIn, false);
    } catch (e) {
      print('Error clearing auth token: $e');
    }
  }

  // Method to set auth token
  Future<void> setAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.authToken, token);
      await prefs.setBool(AppConfig.isLoggedIn, true);
      
      // Update dio headers
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (e) {
      print('Error setting auth token: $e');
    }
  }

  // Method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authToken);
      final isLoggedIn = prefs.getBool(AppConfig.isLoggedIn) ?? false;
      return token != null && token.isNotEmpty && isLoggedIn;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Method to update base URL if needed (for environment switching)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    _apiClient = ApiClient(_dio, baseUrl: newBaseUrl);
  }

  // Method to add custom headers
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  // Method to remove headers
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }
}
