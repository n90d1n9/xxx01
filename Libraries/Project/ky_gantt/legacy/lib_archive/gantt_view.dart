import 'package:flutter/material.dart';

import 'task/add_task_dialog.dart';

import 'task/task.dart';
import 'task/task_tree_.dart';
import 'timeline/timeline_view.dart';

class GanttView extends StatelessWidget {
  final List<Task> tasks;
  final Timeline timeline;
  const GanttView({super.key, required this.tasks, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Tree View Section
          SizedBox(
            width: 300,
            child: TaskTreeView(
              tasks: tasks,
            ),
          ),
          // Timeline Section
          Expanded(
            child: TimelineView(
              timeline: Timeline(
                  //tasks: tasks
                  ),
              tasks: tasks,
              onTaskSelected: (Task) {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        task: tasks[0],
      ),
    );
  }
}
