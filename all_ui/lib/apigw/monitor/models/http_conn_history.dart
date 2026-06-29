import 'http_conn.dart';

class HttpConnectionsHistoryEntry {
  final DateTime timestamp;
  final HttpConnections connections;

  HttpConnectionsHistoryEntry({
    required this.timestamp,
    required this.connections,
  });
}
