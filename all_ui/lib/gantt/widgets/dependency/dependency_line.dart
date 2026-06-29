import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../utils/helper.dart';
import 'dependency_painter.dart';

class DependencyLine extends StatelessWidget {
  final Offset position;
  final Task fromTask;
  final Task toTask;
  final List<Task> tasks;
  final double height;
  final DateTimeRange dateRange;
  final double colWidth;
  const DependencyLine({
    super.key,
    required this.position,
    required this.fromTask,
    required this.toTask,
    required this.dateRange,
    required this.colWidth,
    required this.height,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final toX = toTask.visualProperties!.taskBarPosition.dx;
    // (getDayPosition(fromTask.endDate, dateRange.start) + 1) * colWidth;
    final fromX =
        position
            .dx; //getDayPosition(toTask.startDate, dateRange.start) * colWidth;
    final toY =
        toTask
            .visualProperties!
            .taskBarPosition!
            .dy; //(_getTaskIndex(fromTask.id) + 0.5) * height - 20;
    final fromY = position.dy; //(_getTaskIndex(toTask.id) + 0.5) * height;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Tooltip(
        message:
            'From ${fromTask.id}-${fromTask.title} to ${toTask.id}-${toTask.title}',
        child: CustomPaint(
          painter: DependencyPainter(
            fromX: fromX,
            fromY: fromY,
            toX: toX,
            toY: toY,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  int _getTaskIndex(String taskId) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw Exception(
        'Task with id $taskId not found',
      ); // or return a default value
    }
    return index;
  }
}
