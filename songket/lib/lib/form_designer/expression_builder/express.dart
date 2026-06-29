// Visual Expression Builder for Calculations
import 'package:flutter/widgets.dart';

class ExpressionNode {
  final String id;
  final ExpressionNodeType type;
  final String? value;
  final List<ExpressionNode>? children;
  final Offset position;

  const ExpressionNode({
    required this.id,
    required this.type,
    this.value,
    this.children,
    this.position = Offset.zero,
  });

  ExpressionNode copyWith({
    String? id,
    ExpressionNodeType? type,
    String? value,
    List<ExpressionNode>? children,
    Offset? position,
  }) {
    return ExpressionNode(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      children: children ?? this.children,
      position: position ?? this.position,
    );
  }
}

enum ExpressionNodeType { field, operator, constant, function }
