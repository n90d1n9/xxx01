import 'dart:ui';

class Port {
  final String id;
  final Offset position;
  final String nodeId;
  final bool isInput;
  final String label;

  Port({
    required this.label,
    required this.id,
    required this.position,
    required this.nodeId,
    required this.isInput,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'nodeId': nodeId,
      'isInput': isInput,
      'label': label,
    };
  }

  // fromJson method
  factory Port.fromJson(Map<String, dynamic> json) {
    return Port(
      id: json['id'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      nodeId: json['nodeId'],
      isInput: json['isInput'],
      label: json['label'],
    );
  }

  // copyWith method
  Port copyWith({
    String? id,
    Offset? position,
    String? nodeId,
    bool? isInput,
    String? label,
  }) {
    return Port(
      id: id ?? this.id,
      position: position ?? this.position,
      nodeId: nodeId ?? this.nodeId,
      isInput: isInput ?? this.isInput,
      label: label ?? this.label,
    );
  }

  // toString method
  @override
  String toString() {
    return 'Port(id: $id, position: $position, nodeId: $nodeId, isInput: $isInput, label: $label)';
  }
}
