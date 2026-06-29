import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../states/gantt_provider.dart';
import '../../states/task_state.dart';
import 'timeline_grid.dart';
import 'timeline_header.dart';

class TimelinePanel extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final double headerHeight;
  final double taskItemHeight;
  final DateTimeRange dateRange;
  final double zoomLevel;
  final ViewMode viewMode;
  final String? selectedTaskId;
  final void Function(Task) onSelectedTask;

  const TimelinePanel({
    super.key,
    required this.tasks,
    required this.dateRange,
    required this.zoomLevel,
    required this.viewMode,
    this.selectedTaskId,
    required this.onSelectedTask,
    this.headerHeight = 50,
    this.taskItemHeight = 40,
  });

  @override
  ConsumerState<TimelinePanel> createState() => _TimelinePanelState();
}

class _TimelinePanelState extends ConsumerState<TimelinePanel> {
  final Map<String, GlobalKey> _taskKeys = {};
  final Map<String, Offset> _taskPositions = {};

  @override
  void initState() {
    super.initState();
    // Initialize keys for all tasks and subtasks
    _initializeKeys();
  }

  void _initializeKeys() {
    for (final task in widget.tasks) {
      _taskKeys[task.id] = GlobalKey();
      for (final subtask in task.subtasks) {
        _taskKeys[subtask.id] = GlobalKey();
      }
    }
  }

  @override
  void didUpdateWidget(covariant TimelinePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      ref.read(tasksProvider.notifier).fromtasks(widget.tasks);
    }

    // print();
    debugPrint(ref.watch(tasksProvider).tasks.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Calculate number of days to display
    final daysDiff =
        widget.dateRange.end.difference(widget.dateRange.start).inDays;

    // Calculate column width based on zoom level and view mode
    final colWidth = _calculateColumnWidth();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
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
              // Timeline header
              TimelineHeader(
                height: widget.headerHeight,
                dateRange: widget.dateRange,
                colWidth: colWidth,
                viewMode: widget.viewMode,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Expanded(
                  child: SizedBox(
                    width: daysDiff * colWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...ref.watch(tasksProvider).tasks.expand((task) {
                          final taskItems = <Widget>[
                            TimelineGrid(
                              //key: _taskKeys[task.id],
                              task: task,
                              tasks: widget.tasks,
                              taskItemHeight: widget.taskItemHeight,
                              dateRange: widget.dateRange,
                              colWidth: colWidth,
                              selectedTaskId: widget.selectedTaskId,
                              onSelectedTask: widget.onSelectedTask,
                            ),
                            ...task.subtasks.map(
                              (subtask) => TimelineGrid(
                                //key: _taskKeys[subtask.id],
                                task: subtask,
                                tasks: widget.tasks,
                                taskItemHeight: widget.taskItemHeight,
                                dateRange: widget.dateRange,
                                colWidth: colWidth,
                                selectedTaskId: widget.selectedTaskId,
                                isSubtask: true,
                                onSelectedTask: widget.onSelectedTask,
                              ),
                            ),
                          ];

                          return taskItems;
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update positions after the first build
    // WidgetsBinding.instance.addPostFrameCallback((_) => _updateTaskPositions());
  }

  void _updateTaskPositions() {
    final updatedTasks = <Task>[];

    for (final task in widget.tasks) {
      // Update main task position
      final taskPosition = _getTaskBarPosition(_taskKeys[task.id]);
      if (taskPosition != null) {
        updatedTasks.add(task.copyWith(barPosition: taskPosition));
      }

      // Update subtask positions
      for (final subtask in task.subtasks) {
        final subtaskPosition = _getTaskBarPosition(_taskKeys[subtask.id]);
        if (subtaskPosition != null) {
          updatedTasks.add(subtask.copyWith(barPosition: subtaskPosition));
        }
      }
    }

    if (updatedTasks.isNotEmpty) {
      ref.read(tasksProvider.notifier).updateTasks(updatedTasks);
    }
  }

  Offset? _getTaskBarPosition(GlobalKey? key) {
    if (key?.currentContext == null) return null;
    final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  double _calculateColumnWidth() {
    switch (widget.viewMode) {
      case ViewMode.day:
        return 100 * widget.zoomLevel;
      case ViewMode.week:
        return 50 * widget.zoomLevel;
      case ViewMode.month:
        return 30 * widget.zoomLevel;
      case ViewMode.quarter:
        return 20 * widget.zoomLevel;
    }
  }
}
