import 'package:dio/dio.dart';
import '../config/environment.dart';

class RobustApiClient {
  static Dio? _dio;
  static String? _workingBaseUrl;
  
  static Future<Dio> getInstance() async {
    if (_dio != null && _workingBaseUrl != null) {
      return _dio!;
    }
    
    await _findWorkingServer();
    return _dio!;
  }
  
  static Future<void> _findWorkingServer() async {
    final urlsToTry = [
      EnvironmentConfig.baseUrl,
      ...EnvironmentConfig.fallbackUrls,
    ];
    
    for (String baseUrl in urlsToTry) {
      try {
        print('Testing server: $baseUrl');
        
        final testDio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
        
        // Try to reach the server
        final response = await testDio.get('');
        
        if (response.statusCode != null && response.statusCode! < 500) {
          print('✅ Found working server: $baseUrl');
          _workingBaseUrl = baseUrl;
          _dio = testDio;
          return;
        }
        
      } catch (e) {
        print('❌ Server $baseUrl failed: $e');
        continue;
      }
    }
    
    // If no server works, use the primary URL anyway
    print('⚠️ No working server found, using primary URL');
    _workingBaseUrl = EnvironmentConfig.baseUrl;
    _dio = Dio(BaseOptions(
      baseUrl: _workingBaseUrl!,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
  
  static Future<Response> safeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final dio = await getInstance();
    
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(
            endpoint,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'POST':
          response = await dio.post(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'PUT':
          response = await dio.put(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            endpoint,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      return response;
      
    } on DioException catch (e) {
      // Enhanced error handling
      print('API Request Failed:');
      print('  URL: ${_workingBaseUrl}$endpoint');
      print('  Method: $method');
      print('  Status: ${e.response?.statusCode}');
      print('  Error: ${e.message}');
      
      if (e.response?.data != null) {
        print('  Response: ${e.response!.data}');
      }
      
      // If server error, try to find a new working server
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        print('Server error detected, trying to find alternative server...');
        _dio = null;
        _workingBaseUrl = null;
        
        // Retry with a different server
        return await safeRequest(
          method: method,
          endpoint: endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      }
      
      rethrow;
    }
  }
  
  // Convenience methods
  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) {
    return safeRequest(method: 'GET', endpoint: endpoint, queryParameters: queryParameters);
  }
  
  static Future<Response> post(String endpoint, {Map<String, dynamic>? data}) {
    return safeRequest(method: 'POST', endpoint: endpoint, data: data);
  }
  
  static Future<Response> put(String endpoint, {Map<String, dynamic>? data}) {
    return safeRequest(method: 'PUT', endpoint: endpoint, data: data);
  }
  
  static Future<Response> delete(String endpoint) {
    return safeRequest(method: 'DELETE', endpoint: endpoint);
  }
  
  static String? get currentBaseUrl => _workingBaseUrl;
}
