import 'mcp_error.dart';

class MCPServerMetrics {
  final int activeConnections;
  final int totalRequests;
  final int failedRequests;
  final Duration averageResponseTime;
  final double cpuUsage;
  final double memoryUsage;
  final int bytesTransferred;
  final DateTime lastUpdated;
  final Map<String, int> requestsByType;
  final List<MCPError> recentErrors;
  final List<int> requestsPerHour; // For charting
  final List<int> errorsPerHour;

  MCPServerMetrics({
    required this.activeConnections,
    required this.totalRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.bytesTransferred,
    required this.lastUpdated,
    required this.requestsByType,
    required this.recentErrors,
    required this.requestsPerHour,
    required this.errorsPerHour,
  });
}
