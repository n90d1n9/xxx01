import 'package:flutter/material.dart';

import 'criticalpath_painter.dart';
import '../task/task.dart';

class CriticalPathOverlay extends StatelessWidget {
  final List<Task> tasks;
  final double cellWidth;

  final DateTime? startDate;

  const CriticalPathOverlay(
      {super.key, required this.tasks, this.cellWidth = 50.0, this.startDate});

  List<Task> _calculateCriticalPath() {
    // Implementation of critical path calculation algorithm
    List<Task> criticalPath = [];
    Map<Task, int> earliestStart = {};
    Map<Task, int> earliestFinish = {};
    Map<Task, int> latestStart = {};
    Map<Task, int> latestFinish = {};

    // Forward pass
    for (var task in tasks) {
      if (task.predecessors!.isEmpty!) {
        earliestStart[task] = 0;
        earliestFinish[task] = task.duration!;
      } else {
        int maxFinish = task.predecessors!
            .map((p) => earliestFinish[p] ?? 0)
            .reduce((a, b) => a > b ? a : b);
        earliestStart[task] = maxFinish;
        earliestFinish[task] = maxFinish + task.duration!;
      }
    }

    // Backward pass and critical path identification
    // ... (Additional critical path calculation logic)

    return criticalPath;
  }

  @override
  Widget build(BuildContext context) {
    final criticalPath = _calculateCriticalPath();
    return CustomPaint(
      painter: CriticalPathPainter(
        criticalPath: criticalPath,
        cellWidth: cellWidth,
        taskHeight: 10,
        startDate: startDate!,
        taskPositions: {},
      ),
    );
  }
}
