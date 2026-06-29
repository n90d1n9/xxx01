import 'audit_action.dart';

class MCPSecurityAudit {
  final String id;
  final String serverId;
  final DateTime timestamp;
  final MCPAuditAction action;
  final String userId;
  final String details;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  MCPSecurityAudit({
    required this.id,
    required this.serverId,
    required this.timestamp,
    required this.action,
    required this.userId,
    required this.details,
    required this.success,
    this.errorMessage,
    this.metadata,
  });
}


/* class MCPSecurityAudit {
  final String id;
  final String serverId;
  final DateTime timestamp;
  final MCPAuditAction action;
  final String userId;
  final String details;
  final bool success;
  final String? errorMessage;

  MCPSecurityAudit({
    required this.id,
    required this.serverId,
    required this.timestamp,
    required this.action,
    required this.userId,
    required this.details,
    required this.success,
    this.errorMessage,
  });
} */