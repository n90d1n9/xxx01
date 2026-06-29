import 'package:flutter/widgets.dart';
import 'package:queue_ui/gantt/utils/helper.dart';

import 'task.dart';

class TaskVisual {
  final String taskId;
  final GlobalKey taskItemkey;
  final GlobalKey taskBarkey;
  final Offset taskItemPosition;
  final Offset taskBarPosition;
  final Size taskItemSize;
  final Size taskBarSize;
  final double progress;
  final Color color;

  TaskVisual({
    required this.taskId,
    GlobalKey? taskItemkey,
    GlobalKey? taskBarkey,
    this.taskItemPosition = Offset.zero,
    this.taskBarPosition = Offset.zero,
    this.taskItemSize = const Size(0, 0),
    this.taskBarSize = const Size(0, 0),
    this.progress = 0.0,
    this.color = const Color(0xFF2196F3),
  }) : taskBarkey = taskBarkey ?? GlobalKey(),
       taskItemkey = taskItemkey ?? GlobalKey();

  static TaskVisual empty() {
    return TaskVisual(
      taskId: '',
      taskItemkey: GlobalKey(),
      taskBarkey: GlobalKey(),
      taskItemPosition: Offset.zero,
      taskBarPosition: Offset.zero,
      taskItemSize: Size.zero,
      taskBarSize: Size.zero,
      progress: 0.0,
      color: const Color(0xFF2196F3),
    );
  }

  static List<TaskVisual> fromtasks(List<Task> tasks) {
    /*    final barKey = GlobalKey();
    final itemKey = GlobalKey(); */
    return tasks.map((task) {
      return TaskVisual(
        taskId: task.id,
        /*       taskItemkey: itemKey,
        taskBarkey: barKey, */
        taskItemPosition: getPosition(task.visualProperties.taskItemkey),
        taskBarPosition: getPosition(task.visualProperties.taskBarkey),
        taskItemSize: getRenderBox(task.visualProperties.taskItemkey).size,
        taskBarSize: getRenderBox(task.visualProperties.taskBarkey).size,
        progress: task.progress,
        color: task.color,
      );
    }).toList();
  }

  TaskVisual copyWith({
    String? taskId,
    GlobalKey? taskItemkey,
    GlobalKey? taskBarkey,
    Offset? taskItemPosition,
    Offset? taskBarPosition,
    Size? taskItemSize,
    Size? taskBarSize,
    double? progress,
    Color? color,
  }) {
    return TaskVisual(
      taskId: taskId ?? this.taskId,
      taskItemkey: taskItemkey ?? this.taskItemkey,
      taskBarkey: taskBarkey ?? this.taskBarkey,
      taskItemPosition: taskItemPosition ?? this.taskItemPosition,
      taskBarPosition: taskBarPosition ?? this.taskBarPosition,
      taskItemSize: taskItemSize ?? this.taskItemSize,
      taskBarSize: taskBarSize ?? this.taskBarSize,
      progress: progress ?? this.progress,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'TaskVisual(taskId: $taskId, taskItemkey: $taskItemkey, taskBarkey: $taskBarkey, taskItemPosition: $taskItemPosition, taskBarPosition: $taskBarPosition, taskItemSize: $taskItemSize, taskBarSize: $taskBarSize, progress: $progress, color: $color)';
  }
}
