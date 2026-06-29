class PerformanceAlert {
  final String severity; // 'info', 'warning', 'critical'
  final String message;
  final DateTime timestamp;
  final String? nodeId;

  PerformanceAlert({
    required this.severity,
    required this.message,
    required this.timestamp,
    this.nodeId,
  });
}
