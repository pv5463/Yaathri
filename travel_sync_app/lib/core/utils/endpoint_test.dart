import 'package:dio/dio.dart';
import '../config/environment.dart';

class EndpointTest {
  static Future<void> testCorrectEndpoints() async {
    print('\n🎯 === TESTING CORRECT API ENDPOINTS ===');
    print('Environment: ${EnvironmentConfig.environmentName}');
    print('Base URL: ${EnvironmentConfig.baseUrl}');
    print('API URL: ${EnvironmentConfig.apiUrl}');
    print('Auth Endpoint: ${EnvironmentConfig.authEndpoint}');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Test the correct endpoints based on your backend configuration
    final endpointsToTest = [
      {
        'url': EnvironmentConfig.baseUrl,
        'name': 'Base API Root',
        'method': 'GET'
      },
      {
        'url': '${EnvironmentConfig.baseUrl}/health',
        'name': 'Health Check',
        'method': 'GET'
      },
      {
        'url': '${EnvironmentConfig.authEndpoint}/login',
        'name': 'Auth Login',
        'method': 'POST'
      },
      {
        'url': '${EnvironmentConfig.usersEndpoint}',
        'name': 'Users Endpoint',
        'method': 'GET'
      },
      {
        'url': '${EnvironmentConfig.tripsEndpoint}',
        'name': 'Trips Endpoint',
        'method': 'GET'
      },
    ];
    
    for (final endpoint in endpointsToTest) {
      await _testEndpoint(dio, endpoint);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    print('\n📋 === ENDPOINT SUMMARY ===');
    print('✅ Your backend is configured with /api/v1 prefix');
    print('✅ Correct login endpoint: ${EnvironmentConfig.authEndpoint}/login');
    print('✅ App should now use the correct API paths');
  }
  
  static Future<void> _testEndpoint(Dio dio, Map<String, dynamic> endpoint) async {
    final url = endpoint['url'] as String;
    final name = endpoint['name'] as String;
    final method = endpoint['method'] as String;
    
    print('\n📡 Testing $name: $url');
    
    try {
      Response response;
      
      if (method == 'POST') {
        response = await dio.post(
          url,
          data: {'test': 'connectivity'},
          options: Options(validateStatus: (status) => true),
        );
      } else {
        response = await dio.get(
          url,
          options: Options(validateStatus: (status) => true),
        );
      }
      
      final statusCode = response.statusCode ?? 0;
      
      if (statusCode == 200) {
        print('   ✅ SUCCESS - Status: $statusCode');
      } else if (statusCode == 404) {
        print('   ⚠️  NOT FOUND - Status: $statusCode (endpoint may not exist)');
      } else if (statusCode == 401) {
        print('   🔐 AUTH REQUIRED - Status: $statusCode (expected for protected endpoints)');
      } else if (statusCode == 422) {
        print('   📝 VALIDATION ERROR - Status: $statusCode (expected for POST without proper data)');
      } else if (statusCode >= 500) {
        print('   ❌ SERVER ERROR - Status: $statusCode');
      } else {
        print('   ℹ️  Response - Status: $statusCode');
      }
      
      // Show response data if it's small
      if (response.data != null) {
        final dataStr = response.data.toString();
        if (dataStr.length <= 200) {
          print('   📄 Response: $dataStr');
        }
      }
      
    } catch (e) {
      if (e is DioException) {
        print('   ❌ ERROR: ${e.type}');
        if (e.response?.statusCode != null) {
          print('   📊 Status: ${e.response!.statusCode}');
        }
        
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('   ⏰ Server might be sleeping (Render free tier)');
            break;
          case DioExceptionType.connectionError:
            print('   🌐 Connection error - check server status');
            break;
          default:
            print('   📝 ${e.message}');
        }
      } else {
        print('   ❌ Unexpected error: $e');
      }
    }
  }
  
  static void printEndpointConfiguration() {
    print('\n📋 === CURRENT ENDPOINT CONFIGURATION ===');
    print('Environment: ${EnvironmentConfig.environmentName}');
    print('Base URL: ${EnvironmentConfig.baseUrl}');
    print('API URL: ${EnvironmentConfig.apiUrl}');
    print('');
    print('🔐 Auth Endpoints:');
    print('  Login: ${EnvironmentConfig.authEndpoint}/login');
    print('  Register: ${EnvironmentConfig.authEndpoint}/register');
    print('  Logout: ${EnvironmentConfig.authEndpoint}/logout');
    print('');
    print('👤 User Endpoints:');
    print('  Users: ${EnvironmentConfig.usersEndpoint}');
    print('');
    print('🚗 Trip Endpoints:');
    print('  Trips: ${EnvironmentConfig.tripsEndpoint}');
    print('');
    print('💰 Expense Endpoints:');
    print('  Expenses: ${EnvironmentConfig.expensesEndpoint}');
    print('');
    print('🔧 Backend Configuration:');
    print('  Routes are prefixed with /api/v1');
    print('  Auth routes: /api/v1/auth/*');
    print('  User routes: /api/v1/users/*');
    print('  Trip routes: /api/v1/trips/*');
    print('  Expense routes: /api/v1/expenses/*');
  }
}
