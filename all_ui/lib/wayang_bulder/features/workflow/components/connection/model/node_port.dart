import 'package:flutter/widgets.dart';

import 'connection_state.dart';

class NodePort {
  final String id;
  final ConnectionType type;
  final Offset position;
  final int? conditionIndex;
  final bool isElse;

  const NodePort({
    required this.id,
    required this.type,
    required this.position,
    this.conditionIndex,
    this.isElse = false,
  });

  String get label {
    if (isElse) return 'Else';
    if (conditionIndex != null) return 'Condition ${conditionIndex! + 1}';
    return 'Input';
  }

  @override
  String toString() {
    return 'NodePort{id: $id, type: $type, label: $label}';
  }
}
