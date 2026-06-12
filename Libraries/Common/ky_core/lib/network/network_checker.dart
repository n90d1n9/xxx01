import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  Stream<bool> onStatusChange() {
    return _connectivity.onConnectivityChanged
        .map(_isConnected)
        .distinct();
  }

  Stream<NetworkStatus> onStatusChangeDetailed() {
    return _connectivity.onConnectivityChanged
        .map(
          (results) => NetworkStatus(
            isOnline: _isConnected(results),
            results: results,
          ),
        )
        .distinct(_sameStatus);
  }

  Future<List<ConnectivityResult>> currentStatus() {
    return _connectivity.checkConnectivity();
  }

  Future<NetworkStatus> currentStatusDetailed() async {
    final results = await _connectivity.checkConnectivity();
    return NetworkStatus(isOnline: _isConnected(results), results: results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  bool _sameStatus(NetworkStatus a, NetworkStatus b) {
    if (a.isOnline != b.isOnline) return false;
    if (a.results.length != b.results.length) return false;
    for (var i = 0; i < a.results.length; i += 1) {
      if (a.results[i] != b.results[i]) return false;
    }
    return true;
  }
}

class NetworkStatus {
  final bool isOnline;
  final List<ConnectivityResult> results;
  const NetworkStatus({required this.isOnline, required this.results});
}
