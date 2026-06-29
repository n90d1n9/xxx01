import 'package:flutter/material.dart';

import '../../models/task.dart';
import 'task_list_item.dart';

class TaskListPanel extends StatefulWidget {
  final double headerHeight;
  final double taskItemHeight;
  final List<Task> tasks;
  final String? selectedTaskId;
  final void Function(String id) onSelectedTask;
  const TaskListPanel({
    super.key,
    this.headerHeight = 40,
    required this.tasks,
    this.selectedTaskId,
    required this.onSelectedTask,
    this.taskItemHeight = 40,
  });

  @override
  State<TaskListPanel> createState() => _TaskListPanelState();
}

class _TaskListPanelState extends State<TaskListPanel> {
  double width = 300;
  double _dragStartWidth = 300;
  double _dragStartX = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Task List Header
          Container(
            width: width,
            height: widget.headerHeight,
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  onEnter: (_) => setState(() => _isHovering = true),
                  onExit: (_) => setState(() => _isHovering = false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (details) {
                      _dragStartWidth = width;
                      _dragStartX = details.globalPosition.dx;
                    },
                    onHorizontalDragUpdate: (details) {
                      final newWidth =
                          _dragStartWidth +
                          (details.globalPosition.dx - _dragStartX);
                      setState(() {
                        width = newWidth.clamp(150, 600);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: widget.headerHeight,
                      width: 12,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color:
                            _isHovering
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          width: 2,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                _isHovering
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];

                return Column(
                  children: [
                    TaskListItem(
                      height: widget.taskItemHeight,
                      task: task,
                      isSelected: task.id == widget.selectedTaskId,
                      onTap: () {
                        widget.onSelectedTask(task.id);
                      },
                      isSubtask: false,
                    ),
                    // Subtasks
                    ...task.subtasks.map((subtask) {
                      return TaskListItem(
                        height: widget.taskItemHeight,
                        task: subtask,
                        isSelected: task.id == widget.selectedTaskId,
                        isSubtask: true,
                        onTap: () {
                          widget.onSelectedTask(task.id);
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
