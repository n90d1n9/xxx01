import 'package:flutter/material.dart';
import 'package:queue_ui/gantt/models/task.dart';

import 'task_title.dart';

class TaskBar extends StatelessWidget {
  final Task task;
  final double taskStart;
  final double colWidth;
  final int taskDuration;
  final bool isSelected;
  final void Function() onTap;
  const TaskBar({
    super.key,
    required this.task,
    required this.taskStart,
    required this.colWidth,
    required this.taskDuration,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: taskStart * colWidth,
      top: 8,
      height: 24,
      width: taskDuration * colWidth,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Tooltip(
          message:
              '${task.id} - ${task.title} \n ${task.dependsOn} - ${task.startDate} \n ${task.endDate}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: task.color.withValues(alpha: 0.7),
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : task.color,
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: task.color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              children: [
                // Progress indicator
                FractionallySizedBox(
                  widthFactor: task.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: task.color,
                    ),
                  ),
                ),
                // Task title
                TaskTitle(title: task.title, isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
