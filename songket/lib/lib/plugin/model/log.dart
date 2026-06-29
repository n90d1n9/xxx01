enum LogLevel { debug, info, warning, error }

class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String pluginId;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.pluginId,
    this.error,
    this.stackTrace,
  });
}
