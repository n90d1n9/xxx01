import 'package:flutter/material.dart';

import '../task/task.dart';

class CriticalPathPainter extends CustomPainter {
  final List<Task> criticalPath;
  final double cellWidth;
  final double taskHeight;
  final DateTime startDate;
  final Map<String, double> taskPositions;

  CriticalPathPainter({
    required this.criticalPath,
    required this.cellWidth,
    required this.taskHeight,
    required this.startDate,
    required this.taskPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (criticalPath.isEmpty) return;

    // Setup paint styles
    final pathPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw connecting lines and task highlights
    for (int i = 0; i < criticalPath.length; i++) {
      Task currentTask = criticalPath[i];
      
      // Calculate task rectangle
      double taskStart = _getTaskStartX(currentTask);
      double taskEnd = taskStart + (currentTask.duration! * cellWidth);
      double taskY = taskPositions[currentTask.id] ?? 0;
      
      // Draw task highlight
      Rect taskRect = Rect.fromLTWH(
        taskStart,
        taskY,
        taskEnd - taskStart,
        taskHeight
      );
      canvas.drawRect(taskRect, highlightPaint);
      canvas.drawRect(taskRect, pathPaint);

      // Draw connection to next task if exists
      if (i < criticalPath.length - 1) {
        Task nextTask = criticalPath[i + 1];
        double nextTaskStart = _getTaskStartX(nextTask);
        double nextTaskY = taskPositions[nextTask.id] ?? 0;

        // Draw connecting line
        Path connectionPath = Path();
        connectionPath.moveTo(taskEnd, taskY + taskHeight / 2);

        // If tasks are on different rows, use curved path
        if (taskY != nextTaskY) {
          double controlX1 = taskEnd + cellWidth / 2;
          double controlX2 = nextTaskStart - cellWidth / 2;
          
          connectionPath.cubicTo(
            controlX1, taskY + taskHeight / 2,
            controlX2, nextTaskY + taskHeight / 2,
            nextTaskStart, nextTaskY + taskHeight / 2
          );
        } else {
          // Straight line if tasks are on same row
          connectionPath.lineTo(nextTaskStart, nextTaskY + taskHeight / 2);
        }

        canvas.drawPath(connectionPath, pathPaint);

        // Draw connection points
        canvas.drawCircle(
          Offset(taskEnd, taskY + taskHeight / 2),
          3,
          dotPaint
        );
        canvas.drawCircle(
          Offset(nextTaskStart, nextTaskY + taskHeight / 2),
          3,
          dotPaint
        );
      }

      // Draw milestone diamond for final task
      if (i == criticalPath.length - 1) {
        double diamondSize = 8.0;
        Path diamondPath = Path();
        Offset center = Offset(taskEnd, taskY + taskHeight / 2);
        
        diamondPath.moveTo(center.dx, center.dy - diamondSize);
        diamondPath.lineTo(center.dx + diamondSize, center.dy);
        diamondPath.lineTo(center.dx, center.dy + diamondSize);
        diamondPath.lineTo(center.dx - diamondSize, center.dy);
        diamondPath.close();

        canvas.drawPath(diamondPath, pathPaint);
        canvas.drawPath(diamondPath, Paint()
          ..color = Colors.red.withOpacity(0.2)
          ..style = PaintingStyle.fill);
      }
    }
  }

  double _getTaskStartX(Task task) {
    // Calculate days from project start to task start
    int predecessorDuration = 0;
    if (task.predecessors!.isNotEmpty) {
      predecessorDuration = task.predecessors!
          .map((p) => p.duration!)
          .reduce((a, b) => a + b);
    }
    
    return predecessorDuration * cellWidth;
  }

  @override
  bool shouldRepaint(covariant CriticalPathPainter oldDelegate) {
    return oldDelegate.criticalPath != criticalPath ||
           oldDelegate.cellWidth != cellWidth ||
           oldDelegate.taskHeight != taskHeight ||
           oldDelegate.startDate != startDate ||
           oldDelegate.taskPositions != taskPositions;
  }
}