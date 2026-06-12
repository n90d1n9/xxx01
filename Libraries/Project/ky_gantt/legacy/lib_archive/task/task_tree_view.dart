import 'package:flutter/material.dart';

import 'task.dart';

class TaskTreeView extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskSelected;

  const TaskTreeView(
      {super.key, required this.tasks, required this.onTaskSelected});

  @override
  TaskTreeViewState createState() => TaskTreeViewState();
}

class TaskTreeViewState extends State<TaskTreeView> {
  // Track expanded nodes
  final Set<String> _expandedNodes = {};

  @override
  Widget build(BuildContext context) {
    // Build hierarchical tree of tasks
    List<Task> rootTasks = _buildTaskHierarchy(widget.tasks);

    return ListView.builder(
      itemCount: rootTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskNode(rootTasks[index]);
      },
    );
  }

  Widget _buildTaskNode(Task task, {int depth = 0}) {
    bool isExpanded = _expandedNodes.contains(task.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            widget.onTaskSelected(task);

            // Toggle node expansion
            setState(() {
              if (_expandedNodes.contains(task.id)) {
                _expandedNodes.remove(task.id);
              } else {
                _expandedNodes.add(task.id!);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.only(left: depth * 16.0),
            child: Row(
              children: [
                // Expand/collapse icon
                Icon(
                  task.subTasks!.isNotEmpty
                      ? (isExpanded ? Icons.expand_more : Icons.chevron_right)
                      : Icons.fiber_manual_record,
                  size: 16,
                ),

                // Task details
                Expanded(
                  child: Text(
                    task.name!,
                    style: TextStyle(
                        fontWeight: task.subTasks!.isNotEmpty
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                ),

                // Progress indicator
                CircularProgressIndicator(
                  value: task.progress! / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(task.progress!)),
                  semanticsLabel: 'Task progress',
                  semanticsValue: '${task.progress!}%',
                )
              ],
            ),
          ),
        ),

        // Recursively show subtasks if expanded
        if (isExpanded && task.subTasks!.isNotEmpty)
          ...task.subTasks!
              .map((subTask) => _buildTaskNode(subTask, depth: depth + 1)),
      ],
    );
  }

  // Builds task hierarchy
  List<Task> _buildTaskHierarchy(List<Task> tasks) {
    // Group tasks by parent
    Map<String?, List<Task>> taskGroups = {};
    for (var task in tasks) {
      taskGroups.putIfAbsent(task.parentId, () => []).add(task);
    }

    // Find root tasks (tasks without parent)
    return taskGroups[null] ?? [];
  }

  // Color-coded progress indicator
  Color _getProgressColor(double progress) {
    if (progress < 25) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 75) return Colors.yellow;
    return Colors.green;
  }
}
