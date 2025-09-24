import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../services/offline_service.dart';

class ServerTest {
  static Future<void> testServerAndOfflineMode() async {
    print('\n🔍 === COMPREHENSIVE SERVER TEST ===');
    
    // Test 1: Check current environment
    print('\n📍 Environment Configuration:');
    print('   Current: ${EnvironmentConfig.environmentName}');
    print('   Base URL: ${EnvironmentConfig.baseUrl}');
    print('   API URL: ${EnvironmentConfig.apiUrl}');
    print('   Fallback URLs: ${EnvironmentConfig.fallbackUrls}');
    
    // Test 2: Server connectivity
    await _testServerConnectivity();
    
    // Test 3: Offline mode
    await _testOfflineMode();
    
    print('\n✅ === TEST COMPLETE ===\n');
  }
  
  static Future<void> _testServerConnectivity() async {
    print('\n🌐 Testing Server Connectivity:');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    final urlsToTest = [
      EnvironmentConfig.baseUrl,
      ...EnvironmentConfig.fallbackUrls,
    ];
    
    bool foundWorkingServer = false;
    
    for (String url in urlsToTest) {
      try {
        print('   Testing: $url');
        final response = await dio.get(url);
        
        if (response.statusCode != null && response.statusCode! < 500) {
          print('   ✅ $url - Status: ${response.statusCode} (Working)');
          foundWorkingServer = true;
          break;
        } else {
          print('   ❌ $url - Status: ${response.statusCode} (Server Error)');
        }
      } catch (e) {
        if (e is DioException) {
          print('   ❌ $url - Error: ${e.type} - ${e.message}');
          if (e.response?.statusCode != null) {
            print('      Response Status: ${e.response!.statusCode}');
          }
        } else {
          print('   ❌ $url - Unexpected Error: $e');
        }
      }
    }
    
    if (!foundWorkingServer) {
      print('   ⚠️ No working servers found - Offline mode will be activated');
    }
  }
  
  static Future<void> _testOfflineMode() async {
    print('\n📱 Testing Offline Mode:');
    
    try {
      // Test offline login
      OfflineService.enableOfflineMode();
      print('   Status: ${OfflineService.getOfflineStatusMessage()}');
      
      final mockLoginResult = await OfflineService.mockLogin('test@example.com', 'password123');
      print('   Mock Login Result: ${mockLoginResult['success'] ? '✅ Success' : '❌ Failed'}');
      print('   Message: ${mockLoginResult['message']}');
      
      // Test mock user creation
      final mockUser = OfflineService.getMockUser();
      print('   Mock User: ${mockUser.fullName} (${mockUser.email})');
      print('   User ID: ${mockUser.id}');
      
      OfflineService.disableOfflineMode();
      print('   Offline mode test completed');
      
    } catch (e) {
      print('   ❌ Offline mode test failed: $e');
    }
  }
  
  static Future<void> testSpecificEndpoints() async {
    print('\n🎯 Testing Specific API Endpoints:');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    final endpoints = [
      {'method': 'GET', 'path': ''},
      {'method': 'GET', 'path': '/health'},
      {'method': 'POST', 'path': '/auth/login'},
      {'method': 'POST', 'path': '/auth/register'},
    ];
    
    for (var endpoint in endpoints) {
      try {
        final url = '${EnvironmentConfig.baseUrl}${endpoint['path']}';
        print('   Testing ${endpoint['method']} $url');
        
        Response response;
        if (endpoint['method'] == 'GET') {
          response = await dio.get(url);
        } else {
          response = await dio.post(
            url,
            data: {'test': 'data'},
            options: Options(validateStatus: (status) => true),
          );
        }
        
        print('   ✅ Status: ${response.statusCode}');
        
      } catch (e) {
        if (e is DioException) {
          print('   ❌ Error: ${e.response?.statusCode ?? 'Connection Failed'}');
        } else {
          print('   ❌ Unexpected: $e');
        }
      }
    }
  }
}
