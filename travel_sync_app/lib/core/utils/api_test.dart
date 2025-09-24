import 'package:dio/dio.dart';
import '../config/environment.dart';

class ApiTest {
  static Future<void> testApiConnectivity() async {
    final dio = Dio();
    
    try {
      print('Testing API connectivity to: ${EnvironmentConfig.baseUrl}');
      
      // Configure timeouts
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      // First test basic connectivity to the domain
      final baseResponse = await dio.get(EnvironmentConfig.baseUrl);
      print('Base URL Response: ${baseResponse.statusCode}');
      
      // Test health endpoint
      try {
        final healthResponse = await dio.get('${EnvironmentConfig.baseUrl}/health');
        print('Health Check Response: ${healthResponse.statusCode}');
        print('Health Data: ${healthResponse.data}');
      } catch (healthError) {
        print('Health endpoint not available, trying root endpoint');
      }
      
      if (baseResponse.statusCode == 200) {
        print('✅ API base URL is reachable');
      } else {
        print('⚠️ API responded with status: ${baseResponse.statusCode}');
      }
      
    } catch (e) {
      if (e is DioException) {
        print('❌ DioException Details:');
        print('   Type: ${e.type}');
        print('   Message: ${e.message}');
        print('   Response Status: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request URL: ${e.requestOptions.uri}');
        
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('❌ Connection timeout - Server might be down or slow');
            break;
          case DioExceptionType.receiveTimeout:
            print('❌ Receive timeout - Server response is slow');
            break;
          case DioExceptionType.connectionError:
            print('❌ Connection error - Check internet or server status');
            break;
          case DioExceptionType.badResponse:
            print('❌ Bad response: ${e.response?.statusCode}');
            if (e.response?.statusCode == 404) {
              print('   Server endpoint not found');
            } else if (e.response?.statusCode == 500) {
              print('   Internal server error');
            }
            break;
          default:
            print('❌ Other API Error: ${e.message}');
        }
      } else {
        print('❌ Unexpected error: $e');
      }
    }
  }
  
  static Future<void> testAuthEndpoint() async {
    final dio = Dio();
    
    try {
      print('\n=== Testing Auth Endpoints ===');
      
      // Configure timeouts
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      // Test different auth endpoints
      final endpoints = [
        '/auth/login',
        '/auth/register',
        '/users',
        '/trips',
      ];
      
      for (String endpoint in endpoints) {
        try {
          print('\nTesting: ${EnvironmentConfig.apiUrl}$endpoint');
          
          final response = await dio.post(
            '${EnvironmentConfig.apiUrl}$endpoint',
            data: {
              'email': 'test@example.com',
              'password': 'testpassword'
            },
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              validateStatus: (status) => true, // Accept all status codes
            ),
          );
          
          print('✅ $endpoint - Status: ${response.statusCode}');
          
          if (response.statusCode == 404) {
            print('   Endpoint not found - might need different HTTP method');
          } else if (response.statusCode == 401) {
            print('   Authentication required (expected for protected endpoints)');
          } else if (response.statusCode == 422) {
            print('   Validation error (expected for invalid test data)');
          } else if (response.statusCode != null && response.statusCode! >= 500) {
            print('   Server error: ${response.data}');
          }
          
        } catch (e) {
          if (e is DioException) {
            print('❌ $endpoint - Error: ${e.response?.statusCode} - ${e.message}');
          } else {
            print('❌ $endpoint - Unexpected error: $e');
          }
        }
      }
      
    } catch (e) {
      print('❌ Auth endpoint testing failed: $e');
    }
  }
  
  static Future<void> runAllTests() async {
    print('=== API Connectivity Tests ===');
    await testApiConnectivity();
    await testAuthEndpoint();
    print('=== Tests Complete ===\n');
  }
}
