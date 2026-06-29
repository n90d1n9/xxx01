class CollaborationEvent {
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  CollaborationEvent({
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    this.data,
  });
}
