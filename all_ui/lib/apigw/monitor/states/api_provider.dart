import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/api_metric.dart';
import '../models/http_conn.dart';
import '../models/http_conn_history.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: 'http://[::1]:8080',
    username: 'admin',
    password: 'securepassword',
  );
});

final apiMetricsStreamProvider = StreamProvider<ApiMetrics>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMetricsStream();
});

final httpConnectionsHistoryProvider = StateNotifierProvider<
  ConnectionsHistoryNotifier,
  List<HttpConnectionsHistoryEntry>
>((ref) {
  return ConnectionsHistoryNotifier();
});

class ConnectionsHistoryNotifier
    extends StateNotifier<List<HttpConnectionsHistoryEntry>> {
  ConnectionsHistoryNotifier() : super([]);

  void addEntry(DateTime timestamp, HttpConnections connections) {
    // Keep only the last 50 entries for the time series
    if (state.length >= 50) {
      state = [
        ...state.skip(1),
        HttpConnectionsHistoryEntry(
          timestamp: timestamp,
          connections: connections,
        ),
      ];
    } else {
      state = [
        ...state,
        HttpConnectionsHistoryEntry(
          timestamp: timestamp,
          connections: connections,
        ),
      ];
    }
  }
}
