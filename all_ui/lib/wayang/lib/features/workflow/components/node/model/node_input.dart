import 'package:flutter/material.dart';

import '../../../../../theme/theme_provider.dart';
import '../../../model/workflow_node.dart';

class NodeInputState {
  final WorkflowNode node;
  final WayangTheme theme;
  final String label;
  final String name;
  final bool isSelected;
  final bool isDragging;
  final VoidCallback onSelect;
  final Function(String) onConnectionStart;
  final Function(String) onConnectionEnd;
  final double width;
  final double height;
  final bool isHovered;

  NodeInputState({
    required this.node,
    required this.theme,
    required this.label,
    required this.name,
    required this.isSelected,
    required this.isDragging,
    required this.onSelect,
    required this.onConnectionStart,
    required this.onConnectionEnd,
    required this.width,
    required this.height,
    required this.isHovered,
  });
}
