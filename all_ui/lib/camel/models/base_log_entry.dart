abstract class BaseLogEntry {
  final String id;
  final String action;
  final String nodeName;
  final DateTime timestamp;
  final Duration? processingTime;

  const BaseLogEntry({
    required this.id,
    required this.action,
    required this.nodeName,
    required this.timestamp,
    this.processingTime,
  });
}
