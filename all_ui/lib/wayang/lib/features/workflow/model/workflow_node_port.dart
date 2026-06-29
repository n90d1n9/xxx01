enum PortType { string, number, boolean, object, array, any }

enum NodeStatus { idle, running, success, error }

class WorkflowNodePort {
  final String id;
  final String label;
  final PortType type;

  WorkflowNodePort({required this.id, required this.label, required this.type});

  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label, 'type': type.name};
  }

  factory WorkflowNodePort.fromMap(Map<String, dynamic> map) {
    return WorkflowNodePort(
      id: map['id'] as String,
      label: map['label'] as String,
      type: PortType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PortType.any,
      ),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory WorkflowNodePort.fromJson(Map<String, dynamic> json) =>
      WorkflowNodePort.fromMap(json);

  WorkflowNodePort copyWith({String? id, String? label, PortType? type}) {
    return WorkflowNodePort(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'WorkflowNodePort(id: $id, label: $label, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowNodePort && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
