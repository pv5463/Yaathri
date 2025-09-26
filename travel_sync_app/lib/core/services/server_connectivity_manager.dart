import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import 'offline_service.dart';

class ServerConnectivityManager {
  static ServerConnectivityManager? _instance;
  static ServerConnectivityManager get instance => _instance ??= ServerConnectivityManager._();
  
  ServerConnectivityManager._();
  
  bool _isOnline = false;
  String? _workingServerUrl;
  Timer? _connectivityTimer;
  final List<Function(bool)> _listeners = [];
  
  bool get isOnline => _isOnline;
  String? get workingServerUrl => _workingServerUrl;
  
  // Add listener for connectivity changes
  void addConnectivityListener(Function(bool) listener) {
    _listeners.add(listener);
  }
  
  void removeConnectivityListener(Function(bool) listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners(bool isOnline) {
    for (final listener in _listeners) {
      try {
        listener(isOnline);
      } catch (e) {
        print('Error notifying connectivity listener: $e');
      }
    }
  }
  
  // Start continuous monitoring
  void startMonitoring() {
    print('🔍 Starting server connectivity monitoring...');
    
    // Initial check
    checkConnectivity();
    
    // Check every 30 seconds
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkConnectivity();
    });
  }
  
  void stopMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
  }
  
  // Comprehensive connectivity check
  Future<bool> checkConnectivity() async {
    print('\n🌐 === SERVER CONNECTIVITY CHECK ===');
    
    // Step 1: Check internet connectivity
    final hasInternet = await _checkInternetConnectivity();
    if (!hasInternet) {
      print('❌ No internet connection detected');
      await _setOfflineMode();
      return false;
    }
    
    print('✅ Internet connection available');
    
    // Step 2: Test all server URLs
    final workingUrl = await _findWorkingServer();
    if (workingUrl != null) {
      print('✅ Found working server: $workingUrl');
      await _setOnlineMode(workingUrl);
      return true;
    } else {
      print('❌ No working servers found');
      await _setOfflineMode();
      return false;
    }
  }
  
  // Check basic internet connectivity
  Future<bool> _checkInternetConnectivity() async {
    try {
      // Try to reach Google DNS or Cloudflare DNS
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        // Fallback to Cloudflare DNS
        final result = await InternetAddress.lookup('1.1.1.1');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }
  
  // Find working server from available URLs
  Future<String?> _findWorkingServer() async {
    final urlsToTest = [
      EnvironmentConfig.baseUrl,
      ...EnvironmentConfig.fallbackUrls,
      // Add local development server as fallback
      'http://localhost:5000',
      'http://127.0.0.1:5000',
      'https://yaathri.onrender.com',
    ];
    
    print('🔍 Testing ${urlsToTest.length} server URLs...');
    
    for (final url in urlsToTest) {
      if (await _testServerUrl(url)) {
        return url;
      }
    }
    
    return null;
  }
  
  // Test individual server URL
  Future<bool> _testServerUrl(String url) async {
    try {
      print('   Testing: $url');
      
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 8);
      dio.options.receiveTimeout = const Duration(seconds: 8);
      dio.options.headers = {
        'User-Agent': 'TravelSync-Flutter-App/1.0',
        'Accept': 'application/json',
      };
      
      // Test different endpoints
      final endpointsToTest = [
        '', // Root endpoint
        '/health', // Health check
        '/status', // Status endpoint
      ];
      
      for (final endpoint in endpointsToTest) {
        try {
          final response = await dio.get('$url$endpoint');
          
          if (response.statusCode != null && response.statusCode! < 500) {
            print('   ✅ $url$endpoint - Status: ${response.statusCode}');
            return true;
          }
        } catch (e) {
          // Continue to next endpoint
          continue;
        }
      }
      
      print('   ❌ $url - All endpoints failed');
      return false;
      
    } catch (e) {
      print('   ❌ $url - Error: ${e.toString().split('\n')[0]}');
      return false;
    }
  }
  
  // Set online mode
  Future<void> _setOnlineMode(String serverUrl) async {
    if (!_isOnline || _workingServerUrl != serverUrl) {
      _isOnline = true;
      _workingServerUrl = serverUrl;
      OfflineService.disableOfflineMode();
      
      print('🌐 ONLINE MODE ACTIVATED');
      print('   Server: $serverUrl');
      
      _notifyListeners(true);
    }
  }
  
  // Set offline mode
  Future<void> _setOfflineMode() async {
    if (_isOnline) {
      _isOnline = false;
      _workingServerUrl = null;
      OfflineService.enableOfflineMode();
      
      print('📱 OFFLINE MODE ACTIVATED');
      print('   Using mock data for app functionality');
      
      _notifyListeners(false);
    }
  }
  
  // Force refresh connectivity
  Future<bool> forceRefresh() async {
    print('🔄 Force refreshing server connectivity...');
    return await checkConnectivity();
  }
  
  // Get detailed connectivity status
  Map<String, dynamic> getConnectivityStatus() {
    return {
      'isOnline': _isOnline,
      'workingServerUrl': _workingServerUrl,
      'offlineMode': OfflineService.isOfflineMode,
      'lastChecked': DateTime.now().toIso8601String(),
    };
  }
  
  // Test specific server URL manually
  Future<Map<String, dynamic>> testSpecificUrl(String url) async {
    print('🎯 Testing specific URL: $url');
    
    final startTime = DateTime.now();
    bool isWorking = false;
    String? error;
    int? statusCode;
    
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      final response = await dio.get(url);
      statusCode = response.statusCode;
      isWorking = statusCode != null && statusCode < 500;
      
    } catch (e) {
      error = e.toString();
      if (e is DioException && e.response?.statusCode != null) {
        statusCode = e.response!.statusCode;
      }
    }
    
    final duration = DateTime.now().difference(startTime);
    
    final result = {
      'url': url,
      'isWorking': isWorking,
      'statusCode': statusCode,
      'error': error,
      'responseTime': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    print('   Result: ${isWorking ? '✅' : '❌'} $url');
    if (statusCode != null) print('   Status: $statusCode');
    if (error != null) print('   Error: ${error.split('\n')[0]}');
    print('   Response Time: ${duration.inMilliseconds}ms');
    
    return result;
  }
  
  // Dispose resources
  void dispose() {
    stopMonitoring();
    _listeners.clear();
  }
}
