import 'mcp.dart';

class MCPError {
  final String message;
  final String code;
  final DateTime timestamp;
  final MCPErrorSeverity severity;

  MCPError({
    required this.message,
    required this.code,
    required this.timestamp,
    required this.severity,
  });
}
