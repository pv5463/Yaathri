import 'package:dio/dio.dart';
import '../config/environment.dart';

class RenderUrlTest {
  static Future<void> testYaathriRenderUrl() async {
    const String renderUrl = 'https://yaathri.onrender.com';
    
    print('\n🔍 === TESTING YAATHRI RENDER URL ===');
    print('URL: $renderUrl');
    print('Environment: ${EnvironmentConfig.environmentName}');
    print('Current Base URL: ${EnvironmentConfig.baseUrl}');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30); // Render can be slow
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'User-Agent': 'TravelSync-Flutter-App/1.0',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    // Test different endpoints
    final endpointsToTest = [
      {'path': '', 'name': 'Root'},
      {'path': '/health', 'name': 'Health Check'},
      {'path': '/api/v1/auth/login', 'name': 'Auth Login (POST)', 'method': 'POST'},
      {'path': '/api/v1/users', 'name': 'Users Endpoint'},
      {'path': '/api/v1/trips', 'name': 'Trips Endpoint'},
      {'path': '/api-docs', 'name': 'API Documentation'},
    ];
    
    bool anyEndpointWorking = false;
    
    for (final endpoint in endpointsToTest) {
      final path = endpoint['path']!;
      final name = endpoint['name']!;
      final method = endpoint['method'] ?? 'GET';
      final fullUrl = '$renderUrl$path';
      
      try {
        print('\n📡 Testing $name: $fullUrl');
        
        Response response;
        if (method == 'POST') {
          response = await dio.post(
            fullUrl,
            data: {'test': 'connectivity'},
            options: Options(validateStatus: (status) => true),
          );
        } else {
          response = await dio.get(
            fullUrl,
            options: Options(validateStatus: (status) => true),
          );
        }
        
        final statusCode = response.statusCode ?? 0;
        
        if (statusCode < 500) {
          print('   ✅ SUCCESS - Status: $statusCode');
          if (response.data != null) {
            final dataStr = response.data.toString();
            if (dataStr.length > 200) {
              print('   📄 Response: ${dataStr.substring(0, 200)}...');
            } else {
              print('   📄 Response: $dataStr');
            }
          }
          anyEndpointWorking = true;
        } else {
          print('   ❌ SERVER ERROR - Status: $statusCode');
        }
        
      } catch (e) {
        if (e is DioException) {
          print('   ❌ ERROR: ${e.type}');
          print('   📝 Message: ${e.message}');
          
          if (e.response?.statusCode != null) {
            print('   📊 Status Code: ${e.response!.statusCode}');
          }
          
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              print('   ⏰ Connection timeout - Render server might be sleeping');
              break;
            case DioExceptionType.receiveTimeout:
              print('   ⏰ Receive timeout - Server response is slow');
              break;
            case DioExceptionType.connectionError:
              print('   🌐 Connection error - Check internet or server status');
              break;
            case DioExceptionType.badResponse:
              if (e.response?.statusCode == 404) {
                print('   🔍 Endpoint not found (normal for some endpoints)');
              } else if (e.response?.statusCode == 500) {
                print('   🔥 Internal server error');
              }
              break;
            default:
              print('   ❓ Other error type');
          }
        } else {
          print('   ❌ UNEXPECTED ERROR: $e');
        }
      }
      
      // Add delay between requests to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    print('\n📊 === TEST SUMMARY ===');
    if (anyEndpointWorking) {
      print('✅ RENDER URL IS WORKING!');
      print('🎉 Your Yaathri Render backend is accessible');
      print('🔗 URL: $renderUrl');
    } else {
      print('❌ RENDER URL NOT RESPONDING');
      print('💡 Possible reasons:');
      print('   - Server is sleeping (Render free tier)');
      print('   - Server is down or experiencing issues');
      print('   - Network connectivity problems');
      print('   - Server configuration issues');
    }
    
    print('\n💡 Next Steps:');
    print('1. If server is sleeping, wait 30-60 seconds and try again');
    print('2. Check Render dashboard for server status');
    print('3. App will automatically fallback to offline mode if needed');
    print('4. Use Server Diagnostics in Profile for real-time testing');
  }
  
  static Future<void> testAllConfiguredUrls() async {
    print('\n🔍 === TESTING ALL CONFIGURED URLs ===');
    
    final urlsToTest = [
      EnvironmentConfig.baseUrl,
      ...EnvironmentConfig.fallbackUrls,
    ];
    
    for (final url in urlsToTest) {
      await _testSingleUrl(url);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }
  
  static Future<void> _testSingleUrl(String url) async {
    print('\n🎯 Testing: $url');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    try {
      final response = await dio.get(url);
      print('   ✅ Status: ${response.statusCode} - WORKING');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode != null) {
          print('   ⚠️  Status: ${e.response!.statusCode} - ${e.response!.statusMessage}');
        } else {
          print('   ❌ ${e.type} - ${e.message}');
        }
      } else {
        print('   ❌ Error: $e');
      }
    }
  }
  
  static Future<void> wakeUpRenderServer() async {
    const String renderUrl = 'https://yaathri.onrender.com';
    
    print('\n🌅 === WAKING UP RENDER SERVER ===');
    print('Sending wake-up request to: $renderUrl');
    print('This may take 30-60 seconds for a sleeping server...');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    
    try {
      final startTime = DateTime.now();
      final response = await dio.get(renderUrl);
      final duration = DateTime.now().difference(startTime);
      
      print('✅ Server responded in ${duration.inSeconds} seconds');
      print('📊 Status: ${response.statusCode}');
      print('🎉 Render server is now awake and ready!');
      
    } catch (e) {
      print('❌ Failed to wake up server: $e');
      print('💡 Try again in a few minutes or check Render dashboard');
    }
  }
  
  /// Test the health endpoint specifically
  static Future<void> testHealthEndpoint() async {
    const String healthUrl = 'https://yaathri.onrender.com/health';
    
    print('\n🏥 === TESTING HEALTH ENDPOINT ===');
    print('Health URL: $healthUrl');
    print('Expected: Should return 200 with server status');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'User-Agent': 'TravelSync-Flutter-App/1.0',
      'Accept': 'application/json',
    };
    
    try {
      final response = await dio.get(healthUrl);
      
      print('✅ Health check successful!');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.data}');
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('success') && data['success'] == true) {
          print('🎉 Server is healthy and running properly!');
        }
      }
      
    } catch (e) {
      if (e is DioException) {
        print('❌ Health check failed: ${e.type}');
        print('📝 Message: ${e.message}');
        if (e.response?.statusCode != null) {
          print('📊 Status Code: ${e.response!.statusCode}');
          print('📄 Response: ${e.response!.data}');
        }
      } else {
        print('❌ Unexpected error: $e');
      }
    }
  }
}
