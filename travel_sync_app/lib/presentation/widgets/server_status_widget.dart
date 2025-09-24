import 'package:flutter/material.dart';
import '../../core/services/server_connectivity_manager.dart';
import '../../core/services/offline_service.dart';
import '../../core/config/environment.dart';

class ServerStatusWidget extends StatefulWidget {
  const ServerStatusWidget({super.key});

  @override
  State<ServerStatusWidget> createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatusWidget> {
  final _connectivityManager = ServerConnectivityManager.instance;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _connectivityManager.addConnectivityListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityManager.removeConnectivityListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged(bool isOnline) {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshConnectivity() async {
    setState(() {
      _isRefreshing = true;
    });

    await _connectivityManager.forceRefresh();

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _testSpecificUrl(String url) async {
    setState(() {
      _isRefreshing = true;
    });

    final result = await _connectivityManager.testSpecificUrl(url);
    
    setState(() {
      _isRefreshing = false;
    });

    _showTestResultDialog(result);
  }

  void _showTestResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Server Test Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('URL: ${result['url']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  result['isWorking'] ? Icons.check_circle : Icons.error,
                  color: result['isWorking'] ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  result['isWorking'] ? 'Working' : 'Failed',
                  style: TextStyle(
                    color: result['isWorking'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (result['statusCode'] != null) ...[
              const SizedBox(height: 8),
              Text('Status Code: ${result['statusCode']}'),
            ],
            if (result['responseTime'] != null) ...[
              const SizedBox(height: 8),
              Text('Response Time: ${result['responseTime']}ms'),
            ],
            if (result['error'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${result['error']}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showServerListDialog() {
    final servers = [
      EnvironmentConfig.baseUrl,
      ...EnvironmentConfig.fallbackUrls,
      'http://localhost:5000/api',
      'http://127.0.0.1:5000/api',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Server URLs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              final isCurrent = server == _connectivityManager.workingServerUrl;
              
              return ListTile(
                title: Text(
                  server,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.blue : null,
                  ),
                ),
                leading: Icon(
                  isCurrent ? Icons.check_circle : Icons.language,
                  color: isCurrent ? Colors.green : Colors.grey,
                  size: 20,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow, size: 20),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _testSpecificUrl(server);
                  },
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _testSpecificUrl(server);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _connectivityManager.getConnectivityStatus();
    final isOnline = status['isOnline'] as bool;
    final workingUrl = status['workingServerUrl'] as String?;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: isOnline ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? 'Server Connected' : 'Offline Mode',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (workingUrl != null)
                        Text(
                          workingUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      else
                        const Text(
                          'Using mock data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isRefreshing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _refreshConnectivity,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Connection',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status indicators
            Row(
              children: [
                _buildStatusChip(
                  'Internet',
                  isOnline,
                  isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'Server',
                  workingUrl != null,
                  workingUrl != null ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'Offline Mode',
                  OfflineService.isOfflineMode,
                  OfflineService.isOfflineMode ? Colors.orange : Colors.grey,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRefreshing ? null : _refreshConnectivity,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showServerListDialog,
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('Test Servers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // Environment info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Environment: ${EnvironmentConfig.environmentName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Primary URL: ${EnvironmentConfig.baseUrl}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    'Last Checked: ${DateTime.now().toString().substring(11, 19)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
