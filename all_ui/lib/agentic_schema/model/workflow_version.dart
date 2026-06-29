import '../schema/workflow/workflow.dart';

class WorkflowVersion {
  final String id;
  final String workflowId;
  final DateTime timestamp;
  final String author;
  final String message;
  final Workflow snapshot;
  final Map<String, dynamic> changes;

  WorkflowVersion({
    required this.id,
    required this.workflowId,
    required this.timestamp,
    required this.author,
    required this.message,
    required this.snapshot,
    required this.changes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workflowId': workflowId,
    'timestamp': timestamp.toIso8601String(),
    'author': author,
    'message': message,
    'snapshot': snapshot.toJson(),
    'changes': changes,
  };

  factory WorkflowVersion.fromJson(Map<String, dynamic> json) {
    return WorkflowVersion(
      id: json['id'],
      workflowId: json['workflowId'],
      timestamp: DateTime.parse(json['timestamp']),
      author: json['author'],
      message: json['message'],
      snapshot: Workflow.fromJson(json['snapshot']),
      changes: json['changes'],
    );
  }
}
