import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../utils/helper.dart';
import '../dependency/dependency_line.dart';
import '../task/taskbar.dart';

class TimelineGrid extends StatefulWidget {
  final Task task;
  final List<Task> tasks;
  final DateTimeRange dateRange;
  final double colWidth;
  final String? selectedTaskId;
  final bool isSubtask;
  final double taskItemHeight;
  final void Function(Task task) onSelectedTask;

  const TimelineGrid({
    super.key,
    required this.task,
    required this.tasks,
    required this.dateRange,
    required this.colWidth,
    this.selectedTaskId,
    this.isSubtask = false,
    required this.onSelectedTask,
    this.taskItemHeight = 40,
  });

  @override
  State<StatefulWidget> createState() => _TimelineGridState();
}

class _TimelineGridState extends State<TimelineGrid> {
  @override
  void initState() {
    super.initState();
    // Add post-frame callback to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final taskStart = getDayPosition(
      widget.task.startDate,
      widget.dateRange.start,
    );
    final taskDuration =
        widget.task.endDate.difference(widget.task.startDate).inDays + 1;
    final isSelected = widget.task.id == widget.selectedTaskId;
    final taskIndex = widget.tasks.indexWhere((t) => t.id == widget.task.id);
    final x = taskStart * widget.colWidth;
    final y = taskIndex * widget.taskItemHeight;

    return SizedBox(
      height: widget.taskItemHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Background grid lines
          Positioned.fill(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  widget.dateRange.end
                      .difference(widget.dateRange.start)
                      .inDays,
              itemBuilder:
                  (context, index) => Container(
                    height: widget.task.visualProperties!.taskItemSize.height,
                    width: widget.colWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      color:
                          isWeekend(
                                widget.dateRange.start.add(
                                  Duration(days: index),
                                ),
                              )
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Colors.transparent,
                    ),
                  ),
            ),
          ),

          // Add dependency lines
          ..._dependencyLines(widget.tasks, widget.task),

          ...widget.tasks.map((t) {
            final pos = getPosition(t.visualProperties.taskBarkey);

            print(
              'Task: ${t.title}, Key ${t.visualProperties.taskBarkey} Position: $pos',
            );
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: t.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.color, width: 1),
                ),
              ),
            );
          }),

          // Task bar
          TaskBar(
            key: widget.task.visualProperties.taskBarkey,
            task: widget.task,
            taskDuration: taskDuration,
            taskStart: taskStart,
            colWidth: widget.colWidth,
            isSelected: isSelected,
            onTap: () => widget.onSelectedTask(widget.task),
          ),
        ],
      ),
    );
  }

  List<Widget> _dependencyLines(List<Task> tasks, Task task) {
    final taskItems = <Widget>[];
    if (widget.task.dependsOn != null) {
      final dependentTask = widget.tasks.firstWhere(
        (t) => t.id == widget.task.dependsOn,
        orElse: () => task,
      );

      taskItems.add(
        DependencyLine(
          position: getPosition(widget.task.visualProperties.taskBarkey),
          tasks: tasks,
          height: widget.taskItemHeight,
          fromTask: dependentTask,
          toTask: task,
          dateRange: widget.dateRange,
          colWidth: widget.colWidth,
        ),
      );
    }
    return taskItems;
  }
}
