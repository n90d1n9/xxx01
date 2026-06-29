import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../states/gantt_provider.dart';
import '../states/task_state.dart';
import '../widgets/timeline/timeline_panel.dart';
import '../widgets/gantt_toolbar.dart';
import '../widgets/task/subtask_add.dart';
import '../widgets/task/task_detail_panel.dart';
import '../widgets/task/task_edit.dart';
import '../widgets/task/task_form.dart';
import '../widgets/task/task_list_panel.dart';

class GanttChartScreen extends ConsumerStatefulWidget {
  const GanttChartScreen({super.key});

  @override
  ConsumerState<GanttChartScreen> createState() => _GanttChartScreenState();
}

class _GanttChartScreenState extends ConsumerState<GanttChartScreen> {
  bool detailClosed = true;
  final taskItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(tasksProvider);

    final dateRange = ref.watch(dateRangeProvider);

    //double taskPanelWidth = 500;

    double headerHeight = 50;
    double taskItemHeight = 80;

    final selectedTask = _getSelectedTask(
      taskState.tasks,
      taskState.selectedTaskId,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Gantt Chart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(taskState.viewMode, taskState.zoomLevel),

          Expanded(
            child: Row(
              children: [
                // Task List Panel
                TaskListPanel(
                  headerHeight: headerHeight,
                  taskItemHeight: taskItemHeight,
                  //width: taskPanelWidth,
                  selectedTaskId: taskState.selectedTaskId,
                  onSelectedTask: (id) {
                    ref.read(tasksProvider.notifier).setSelectedTaskId(id);
                  },
                  tasks: taskState.tasks,
                ),

                // Timeline and Gantt Chart
                TimelinePanel(
                  tasks: taskState.tasks,
                  dateRange: dateRange,
                  headerHeight: headerHeight,
                  taskItemHeight: taskItemHeight,
                  zoomLevel: taskState.zoomLevel,
                  viewMode: taskState.viewMode,
                  selectedTaskId: taskState.selectedTaskId,
                  // ref: ref,
                  onSelectedTask: (task) {
                    ref.read(tasksProvider.notifier).setSelectedTaskId(task.id);
                    setState(() {
                      detailClosed = false;
                    });
                  },
                ),
              ],
            ),
          ),

          if (!detailClosed && selectedTask != null)
            _buildTaskDetailsPanel(context, selectedTask, taskState.tasks)
          else
            const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildToolbar(ViewMode viewMode, double zoomLevel) {
    return GanttToolbar(
      viewMode: viewMode,
      zoomLevel: zoomLevel,
      onSearchChanged: (value) {
        ref.read(tasksProvider.notifier).setSearchQuery(value);
      },
      onChanged: (value) {
        ref.read(tasksProvider.notifier).setViewMode(value);
      },
      onZoomChanged: (value) {
        ref.read(tasksProvider.notifier).setZoomLevel(value);
      },
      onPressedToday: () {
        final now = DateTime.now();
        ref.read(dateRangeProvider.notifier).state = DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 7)),
          end: DateTime(
            now.year,
            now.month,
            now.day,
          ).add(const Duration(days: 30)),
        );
      },
    );
  }

  Widget _buildTaskDetailsPanel(
    BuildContext context,
    Task task,
    List<Task> tasks,
  ) {
    final taskNotifier = ref.read(tasksProvider.notifier);

    return TaskDetailPanel(
      task: task,
      onEdit: (task) {
        _showEditTaskDialog(context, task!, tasks);
      },
      onAdd: (task) {
        _showAddSubtaskDialog(context, task!);
      },
      onDelete: (id) {
        taskNotifier.deleteTask(task.id);
        ref.read(tasksProvider.notifier).deleteTask(task.id);
        ;
      },
      onUpdate: (Task? newTask) {},
      onChange: (value) {
        taskNotifier.updateTaskProgress(task.id, value!);
      },
      onAddSubtask: (id) {
        taskNotifier.updateTaskProgress(task.id, 1.0);
      },
      onClose: () {
        //ref.watch(tasksProvider).selectedTaskId == null;
        //ref.read(tasksProvider.notifier).setSelectedTaskId(null);
        ref.read(tasksProvider.notifier).clearSelectedTaskId();

        setState(() {
          detailClosed = true;
        });
      },
    );
  }

  Task? _getSelectedTask(List<Task> tasks, String? selectedTaskId) {
    if (selectedTaskId == null || tasks.isEmpty) return null;
    try {
      return tasks.firstWhere((task) => task.id == selectedTaskId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = ref.read(dateRangeProvider);
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );

    if (dateRange != null) {
      ref.read(dateRangeProvider.notifier).state = dateRange;
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final tasksData = ref.read(tasksProvider);
    showDialog(
      context: context,
      builder:
          (context) => TaskForm(
            tasksData: tasksData.tasks,
            onPressed: (newTask) {
              ref.read(tasksProvider.notifier).addTask(newTask!);
            },
          ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, List<Task> tasks) {
    showDialog(
      context: context,
      builder:
          (context) => TaskEdit(
            task: task,
            onPressed: (updatedTask) {
              ref.read(tasksProvider.notifier).updateTask(updatedTask!);
            },
            tasksData: tasks,
          ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context, Task parentTask) {
    showDialog(
      context: context,
      builder:
          (context) => SubTaskAdd(
            parentTask: parentTask,
            onPressed: (updatedTask) {
              ref.read(tasksProvider.notifier).updateTask(updatedTask!);
            },
          ),
    );
  }
}
