import 'health_status.dart';

class MCPHealthCheck {
  final String serverId;
  final DateTime timestamp;
  final MCPHealthStatus status;
  final int responseTime;
  final String? message;
  final double cpuUsage;
  final double memoryUsage;
  final int activeConnections;

  MCPHealthCheck({
    required this.serverId,
    required this.timestamp,
    required this.status,
    required this.responseTime,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.activeConnections,
    this.message,
  });
}
