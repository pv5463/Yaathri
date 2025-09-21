import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({Connectivity? connectivity}) 
      : connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    // Consider connected if any interface reports connectivity other than 'none'
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<List<ConnectivityResult>> get connectivityResults {
    return connectivity.checkConnectivity();
  }
}
