class ExecutionStep {
  final String nodeId;
  final String nodeName;
  final DateTime timestamp;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final Duration duration;
  final bool success;
  final String? error;

  ExecutionStep({
    required this.nodeId,
    required this.nodeName,
    required this.timestamp,
    required this.input,
    required this.output,
    required this.duration,
    required this.success,
    this.error,
  });
}
