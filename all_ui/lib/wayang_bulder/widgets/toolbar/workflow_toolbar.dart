import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/workflow/model/workflow_node.dart';
import 'draggable_toolbar_item.dart';

class WorkflowToolbar extends ConsumerWidget {
  const WorkflowToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          DraggableToolbarItem(type: NodeType.trigger, icon: Icons.play_arrow),
          SizedBox(height: 8),
          DraggableToolbarItem(type: NodeType.trigger, icon: Icons.flash_on),
          SizedBox(height: 8),
          DraggableToolbarItem(type: NodeType.trigger, icon: Icons.device_hub),
        ],
      ),
    );
  }
}
