class WorkflowConnection {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String sourcePortId;
  final String targetPortId;

  WorkflowConnection({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.sourcePortId,
    required this.targetPortId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceNodeId': sourceNodeId,
    'targetNodeId': targetNodeId,
    'sourcePortId': sourcePortId,
    'targetPortId': targetPortId,
  };

  factory WorkflowConnection.fromJson(Map<String, dynamic> json) =>
      WorkflowConnection(
        id: json['id'],
        sourceNodeId: json['sourceNodeId'],
        targetNodeId: json['targetNodeId'],
        sourcePortId: json['sourcePortId'],
        targetPortId: json['targetPortId'],
      );

  WorkflowConnection copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    String? sourcePortId,
    String? targetPortId,
  }) {
    return WorkflowConnection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetPortId: targetPortId ?? this.targetPortId,
    );
  }
}
