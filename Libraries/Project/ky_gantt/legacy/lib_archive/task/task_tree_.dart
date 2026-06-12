// Tree View Implementation
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

import 'task.dart';

class TaskTreeView extends StatelessWidget {
  final List<Task> tasks;
  const TaskTreeView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    List<Node> _convertTasksToNodes(List<Task> tasks) {
      Map<String, List<Task>> tasksByParent = {};
      for (var task in tasks) {
        tasksByParent.putIfAbsent(task.parentId ?? 'root', () => []).add(task);
      }

      List<Node> buildNodes(String parentId) {
        final children = tasksByParent[parentId] ?? [];
        return children.map((task) {
          return Node(
            key: task.id!,
            label: task.name!,
            expanded: task.isExpanded!,
            children: buildNodes(task.id!),
            data: task,
          );
        }).toList();
      }

      return buildNodes('root');
    }

    final nodes = _convertTasksToNodes(tasks);
    TreeViewController controller = TreeViewController();
    return TreeView(
      //nodes: nodes,
      nodeBuilder: (p0, p1) {
        return Column(
          children: tasks.map((e) => Text(e.title)).toList(),
        );
      },
      onNodeTap: (key) {
        // Handle node tap
      },
      theme: const TreeViewTheme(
        expanderTheme: ExpanderThemeData(
          type: ExpanderType.caret,
          modifier: ExpanderModifier.circleFilled,
          position: ExpanderPosition.start,
          color: Colors.blue,
          size: 20,
        ),
      ),
      controller: controller,
    );
  }
}
