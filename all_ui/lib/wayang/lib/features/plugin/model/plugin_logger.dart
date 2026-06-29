import 'log.dart';

class PluginLogger {
  final String pluginId;
  final List<LogEntry> _logs = [];

  PluginLogger(this.pluginId);

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message) => _log(LogLevel.warning, message);
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      pluginId: pluginId,
      error: error,
      stackTrace: stackTrace,
    );
    _logs.add(entry);
    print('[${entry.level.name.toUpperCase()}] [$pluginId] $message');
  }

  List<LogEntry> getLogs() => List.unmodifiable(_logs);
}
