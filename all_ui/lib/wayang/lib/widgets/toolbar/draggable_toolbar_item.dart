import 'package:flutter/material.dart';

import '../../features/workflow/model/workflow_node.dart';

class DraggableToolbarItem extends StatelessWidget {
  final NodeType type;
  final IconData icon;

  const DraggableToolbarItem({
    super.key,
    required this.type,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: {'type': type},
      feedback: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
