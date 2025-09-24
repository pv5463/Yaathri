import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/server_connectivity_manager.dart';
import '../../../core/services/offline_service.dart';
import '../../../core/config/environment.dart';
import '../../../core/utils/server_test.dart';
import '../../../core/utils/render_url_test.dart';
import '../../../core/utils/endpoint_test.dart';
import '../../widgets/server_status_widget.dart';

class ServerDiagnosticsScreen extends StatefulWidget {
  const ServerDiagnosticsScreen({super.key});

  @override
  State<ServerDiagnosticsScreen> createState() => _ServerDiagnosticsScreenState();
}

class _ServerDiagnosticsScreenState extends State<ServerDiagnosticsScreen> {
  final _connectivityManager = ServerConnectivityManager.instance;
  final _customUrlController = TextEditingController();
  final _logMessages = <String>[];
  bool _isRunningTests = false;

  @override
  void initState() {
    super.initState();
    _connectivityManager.addConnectivityListener(_onConnectivityChanged);
    _addLogMessage('Server Diagnostics initialized');
  }

  @override
  void dispose() {
    _connectivityManager.removeConnectivityListener(_onConnectivityChanged);
    _customUrlController.dispose();
    super.dispose();
  }

  void _onConnectivityChanged(bool isOnline) {
    _addLogMessage('Connectivity changed: ${isOnline ? 'ONLINE' : 'OFFLINE'}');
    if (mounted) setState(() {});
  }

  void _addLogMessage(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logMessages.insert(0, '[$timestamp] $message');
      if (_logMessages.length > 100) {
        _logMessages.removeLast();
      }
    });
  }

  Future<void> _runComprehensiveTest() async {
    setState(() {
      _isRunningTests = true;
    });

    _addLogMessage('🔍 Starting comprehensive server test...');

    try {
      // Test 1: Endpoint configuration
      _addLogMessage('Checking endpoint configuration...');
      EndpointTest.printEndpointConfiguration();
      
      // Test 2: Correct endpoints
      _addLogMessage('Testing correct API endpoints...');
      await EndpointTest.testCorrectEndpoints();

      // Test 3: Render URL specifically
      _addLogMessage('Testing Yaathri Render URL...');
      await RenderUrlTest.testYaathriRenderUrl();

      // Test 2: Basic connectivity
      _addLogMessage('Testing basic connectivity...');
      final isConnected = await _connectivityManager.checkConnectivity();
      _addLogMessage('Basic connectivity: ${isConnected ? '✅ PASS' : '❌ FAIL'}');

      // Test 3: All configured URLs
      _addLogMessage('Testing all configured URLs...');
      await RenderUrlTest.testAllConfiguredUrls();

      // Test 4: Server endpoints
      _addLogMessage('Testing server endpoints...');
      await ServerTest.testSpecificEndpoints();

      // Test 5: Offline mode
      _addLogMessage('Testing offline mode...');
      await ServerTest.testServerAndOfflineMode();

      _addLogMessage('✅ Comprehensive test completed');

    } catch (e) {
      _addLogMessage('❌ Test failed: $e');
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  Future<void> _wakeUpRenderServer() async {
    _addLogMessage('🌅 Waking up Render server...');
    try {
      await RenderUrlTest.wakeUpRenderServer();
      _addLogMessage('✅ Render server wake-up completed');
    } catch (e) {
      _addLogMessage('❌ Failed to wake up server: $e');
    }
  }

  Future<void> _testCustomUrl() async {
    final url = _customUrlController.text.trim();
    if (url.isEmpty) {
      _addLogMessage('❌ Please enter a URL to test');
      return;
    }

    _addLogMessage('🎯 Testing custom URL: $url');
    
    try {
      final result = await _connectivityManager.testSpecificUrl(url);
      _addLogMessage('Custom URL result: ${result['isWorking'] ? '✅ WORKING' : '❌ FAILED'}');
      if (result['statusCode'] != null) {
        _addLogMessage('Status Code: ${result['statusCode']}');
      }
      if (result['responseTime'] != null) {
        _addLogMessage('Response Time: ${result['responseTime']}ms');
      }
      if (result['error'] != null) {
        _addLogMessage('Error: ${result['error']}');
      }
    } catch (e) {
      _addLogMessage('❌ Custom URL test failed: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logMessages.clear();
    });
    _addLogMessage('Logs cleared');
  }

  void _copyLogsToClipboard() {
    final logsText = _logMessages.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _toggleOfflineMode() {
    if (OfflineService.isOfflineMode) {
      OfflineService.disableOfflineMode();
      _addLogMessage('🌐 Offline mode disabled');
    } else {
      OfflineService.enableOfflineMode();
      _addLogMessage('📱 Offline mode enabled');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Diagnostics'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Logs',
          ),
          IconButton(
            onPressed: _copyLogsToClipboard,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Server Status Widget
          const ServerStatusWidget(),
          
          // Control Panel
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Control Panel',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunningTests ? null : _runComprehensiveTest,
                          icon: _isRunningTests 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                          label: Text(_isRunningTests ? 'Testing...' : 'Run Full Test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _toggleOfflineMode,
                        icon: Icon(OfflineService.isOfflineMode ? Icons.cloud : Icons.offline_bolt),
                        label: Text(OfflineService.isOfflineMode ? 'Go Online' : 'Go Offline'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OfflineService.isOfflineMode ? Colors.blue : Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Render-specific button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _wakeUpRenderServer,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Wake Up Render Server'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Custom URL testing
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Custom URL to test',
                            hintText: 'https://example.com/api',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _testCustomUrl,
                        child: const Text('Test'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Environment info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Environment: ${EnvironmentConfig.environmentName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Primary: ${EnvironmentConfig.baseUrl}'),
                        Text('API URL: ${EnvironmentConfig.apiUrl}'),
                        Text('Fallback URLs: ${EnvironmentConfig.fallbackUrls.length}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Logs section
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Diagnostic Logs',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${_logMessages.length} messages',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _logMessages.isEmpty
                        ? const Center(
                            child: Text(
                              'No logs yet. Run some tests to see diagnostic information.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logMessages.length,
                            itemBuilder: (context, index) {
                              final message = _logMessages[index];
                              Color? textColor;
                              
                              if (message.contains('✅')) {
                                textColor = Colors.green[700];
                              } else if (message.contains('❌')) {
                                textColor = Colors.red[700];
                              } else if (message.contains('⚠️')) {
                                textColor = Colors.orange[700];
                              } else if (message.contains('🔍') || message.contains('🎯')) {
                                textColor = Colors.blue[700];
                              }
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: index.isEven ? Colors.grey[50] : null,
                                ),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
