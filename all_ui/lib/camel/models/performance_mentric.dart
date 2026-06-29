// Performance Metrics (Enhanced)
import 'performance_alert.dart';

class PerformanceMetrics {
  final int totalNodes;
  final int totalConnections;
  final Duration averageProcessingTime;
  final int messagesProcessed;
  final double throughput;
  final Map<String, int> nodeExecutionCounts;
  final Map<String, Duration> nodeProcessingTimes;
  final List<PerformanceAlert> alerts;

  PerformanceMetrics({
    required this.totalNodes,
    required this.totalConnections,
    required this.averageProcessingTime,
    required this.messagesProcessed,
    required this.throughput,
    required this.nodeExecutionCounts,
    required this.nodeProcessingTimes,
    this.alerts = const [],
  });
}
