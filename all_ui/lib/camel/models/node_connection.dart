import 'package:uuid/v4.dart';

class NodeConnection {
  final String id;
  final String? sourceNodeId;
  final String? targetNodeId;
  final String? sourcePortId;
  final String? targetPortId;

  NodeConnection({
    String? id,
    this.sourceNodeId,
    this.targetNodeId,
    this.sourcePortId,
    this.targetPortId,
  }) : id = UuidV4().generate();

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceNodeId': sourceNodeId,
    'targetNodeId': targetNodeId,
    'sourcePortId': sourcePortId,
    'targetPortId': targetPortId,
  };

  factory NodeConnection.fromJson(Map<String, dynamic> json) => NodeConnection(
    id: json['id'],
    sourceNodeId: json['sourceNodeId'],
    targetNodeId: json['targetNodeId'],
    sourcePortId: json['sourcePortId'],
    targetPortId: json['targetPortId'],
  );

  NodeConnection copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    String? sourcePortId,
    String? targetPortId,
  }) {
    return NodeConnection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetPortId: targetPortId ?? this.targetPortId,
    );
  }
}
