enum CollaborationEventType {
  nodeAdded,
  nodeUpdated,
  nodeDeleted,
  nodeMoved,
  edgeAdded,
  edgeDeleted,
  cursorMoved,
  userJoined,
  userLeft,
  selectionChanged,
  chatMessage,
  edgeUpdated,
  workflowModified,
}

class CollaborationEvent {
  final String id;
  final CollaborationEventType type;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  CollaborationEvent({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'userId': userId,
    'userName': userName,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };

  factory CollaborationEvent.fromJson(Map<String, dynamic> json) {
    return CollaborationEvent(
      id: json['id'],
      type: CollaborationEventType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      userId: json['userId'],
      userName: json['userName'],
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
    );
  }
}
