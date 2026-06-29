import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Task {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final Color color;
  final List<Task> subtasks;
  final String? dependsOn;

  Task({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.progress = 0.0,
    this.color = Colors.blue,
    this.subtasks = const [],
    this.dependsOn,
  });
}

// Providers
final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 7)),
    end: DateTime(now.year, now.month, now.day).add(const Duration(days: 30)),
  );
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) return tasks;

  return tasks
      .where(
        (task) => task.title.toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});

final selectedTaskProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final zoomLevelProvider = StateProvider<double>((ref) => 1.0);
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.week);

enum ViewMode { day, week, month, quarter }

// Notifiers
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super(_generateSampleTasks());

  static List<Task> _generateSampleTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: '1',
        title: 'Project Planning',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 2)),
        progress: 0.8,
        color: Colors.blue,
        subtasks: [
          Task(
            id: '1.1',
            title: 'Requirements Gathering',
            startDate: now.subtract(const Duration(days: 5)),
            endDate: now.subtract(const Duration(days: 2)),
            progress: 1.0,
            color: Colors.blue.shade300,
          ),
          Task(
            id: '1.2',
            title: 'Resource Allocation',
            startDate: now.subtract(const Duration(days: 1)),
            endDate: now.add(const Duration(days: 2)),
            progress: 0.6,
            color: Colors.blue.shade300,
          ),
        ],
      ),
      Task(
        id: '2',
        title: 'Design Phase',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 10)),
        progress: 0.2,
        color: Colors.green,
        dependsOn: '1',
      ),
      Task(
        id: '3',
        title: 'Development',
        startDate: now.add(const Duration(days: 11)),
        endDate: now.add(const Duration(days: 25)),
        progress: 0.0,
        color: Colors.orange,
        dependsOn: '2',
      ),
      Task(
        id: '4',
        title: 'Testing',
        startDate: now.add(const Duration(days: 25)),
        endDate: now.add(const Duration(days: 30)),
        progress: 0.0,
        color: Colors.purple,
        dependsOn: '3',
      ),
    ];
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state =
        state
            .map((task) => task.id == updatedTask.id ? updatedTask : task)
            .toList();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void updateTaskProgress(String taskId, double progress) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return Task(
              id: task.id,
              title: task.title,
              startDate: task.startDate,
              endDate: task.endDate,
              progress: progress,
              color: task.color,
              subtasks: task.subtasks,
              dependsOn: task.dependsOn,
            );
          }
          return task;
        }).toList();
  }
}

// UI Components
class GanttChartScreen extends ConsumerWidget {
  const GanttChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final selectedTaskId = ref.watch(selectedTaskProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);
    final viewMode = ref.watch(viewModeProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Gantt Chart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(context, ref),
          Expanded(
            child: Row(
              children: [
                // Task List Panel
                SizedBox(
                  width: 250,
                  child: _buildTaskListPanel(context, tasks, ref),
                ),
                // Timeline and Gantt Chart
                Expanded(
                  child: _buildGanttChartPanel(
                    context,
                    tasks,
                    dateRange,
                    zoomLevel,
                    viewMode,
                    selectedTaskId,
                    ref,
                  ),
                ),
              ],
            ),
          ),
          if (selectedTaskId != null)
            _buildTaskDetailsPanel(
              context,
              tasks.firstWhere(
                (task) => task.id == selectedTaskId,
                orElse: () => tasks[0],
              ),
              ref,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged:
                      (value) =>
                          ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<ViewMode>(
                value: viewMode,
                items:
                    ViewMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(mode.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(viewModeProvider.notifier).state = value;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Zoom:'),
              Expanded(
                child: Slider(
                  value: zoomLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  label: zoomLevel.toStringAsFixed(1),
                  onChanged: (value) {
                    ref.read(zoomLevelProvider.notifier).state = value;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
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
                tooltip: 'Jump to today',
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  // Export functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting chart data...')),
                  );
                },
                tooltip: 'Export',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListPanel(
    BuildContext context,
    List<Task> tasks,
    WidgetRef ref,
  ) {
    final selectedTaskId = ref.watch(selectedTaskProvider);

    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Column(
                  children: [
                    _buildTaskListItem(context, task, selectedTaskId, ref),
                    ...task.subtasks.map((subtask) {
                      return _buildTaskListItem(
                        context,
                        subtask,
                        selectedTaskId,
                        ref,
                        isSubtask: true,
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

  Widget _buildTaskListItem(
    BuildContext context,
    Task task,
    String? selectedTaskId,
    WidgetRef ref, {
    bool isSubtask = false,
  }) {
    final isSelected = task.id == selectedTaskId;

    return InkWell(
      onTap: () {
        ref.read(selectedTaskProvider.notifier).state = task.id;
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSubtask ? 24 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: task.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: task.progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: task.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(task.progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttChartPanel(
    BuildContext context,
    List<Task> tasks,
    DateTimeRange dateRange,
    double zoomLevel,
    ViewMode viewMode,
    String? selectedTaskId,
    WidgetRef ref,
  ) {
    // Calculate number of days to display
    final daysDiff = dateRange.end.difference(dateRange.start).inDays;

    // Calculate column width based on zoom level and view mode
    double colWidth;
    switch (viewMode) {
      case ViewMode.day:
        colWidth = 100 * zoomLevel;
        break;
      case ViewMode.week:
        colWidth = 50 * zoomLevel;
        break;
      case ViewMode.month:
        colWidth = 30 * zoomLevel;
        break;
      case ViewMode.quarter:
        colWidth = 20 * zoomLevel;
        break;
    }

    return Container(
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
          _buildTimelineHeader(context, dateRange, colWidth, viewMode),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: daysDiff * colWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...tasks.expand((task) {
                        final taskItems = [
                          _buildTaskBar(
                            context,
                            task,
                            dateRange,
                            colWidth,
                            selectedTaskId,
                            ref,
                          ),
                        ];

                        // Add subtasks
                        taskItems.addAll(
                          task.subtasks.map(
                            (subtask) => _buildTaskBar(
                              context,
                              subtask,
                              dateRange,
                              colWidth,
                              selectedTaskId,
                              ref,
                              isSubtask: true,
                            ),
                          ),
                        );

                        // Add dependency lines
                        if (task.dependsOn != null) {
                          final dependentTask = tasks.firstWhere(
                            (t) => t.id == task.dependsOn,
                            orElse: () => task,
                          );

                          taskItems.add(
                            _buildDependencyLine(
                              context,
                              dependentTask,
                              task,
                              dateRange,
                              colWidth,
                            ),
                          );
                        }

                        return taskItems;
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(
    BuildContext context,
    DateTimeRange dateRange,
    double colWidth,
    ViewMode viewMode,
  ) {
    final days = dateRange.end.difference(dateRange.start).inDays;
    final dateFormat = DateFormat('MMM d');
    final weekdayFormat = DateFormat('E');

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: days * colWidth,
            child: Stack(
              children: [
                // Month indicators
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Row(
                    children: [
                      for (
                        int i = 0;
                        i < days;
                        i += viewMode == ViewMode.day ? 1 : 7
                      )
                        SizedBox(
                          width:
                              viewMode == ViewMode.day
                                  ? colWidth
                                  : colWidth * 7,
                          child: Center(
                            child: Text(
                              dateFormat.format(
                                dateRange.start.add(Duration(days: i)),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Day indicators
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Row(
                    children: [
                      for (int i = 0; i < days; i++)
                        SizedBox(
                          width: colWidth,
                          child: Center(
                            child:
                                viewMode == ViewMode.day ||
                                        viewMode == ViewMode.week
                                    ? Text(
                                      weekdayFormat.format(
                                        dateRange.start.add(Duration(days: i)),
                                      ),
                                      style: TextStyle(
                                        color:
                                            _isWeekend(
                                                  dateRange.start.add(
                                                    Duration(days: i),
                                                  ),
                                                )
                                                ? Colors.red
                                                : null,
                                      ),
                                    )
                                    : (i % 7 == 0
                                        ? Text('Week ${(i / 7 + 1).toInt()}')
                                        : const SizedBox.shrink()),
                          ),
                        ),
                    ],
                  ),
                ),
                // Vertical day lines
                for (int i = 0; i < days; i++)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: i * colWidth,
                    child: Container(
                      width: 1,
                      color:
                          _isWeekend(dateRange.start.add(Duration(days: i)))
                              ? Colors.red.withValues(alpha: 0.2)
                              : i % 7 == 0
                              ? Theme.of(context).dividerColor
                              : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                // Today indicator
                if (_isDateInRange(DateTime.now(), dateRange))
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left:
                        _getDayPosition(DateTime.now(), dateRange.start) *
                        colWidth,
                    child: Container(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBar(
    BuildContext context,
    Task task,
    DateTimeRange dateRange,
    double colWidth,
    String? selectedTaskId,
    WidgetRef ref, {
    bool isSubtask = false,
  }) {
    final taskStart = _getDayPosition(task.startDate, dateRange.start);
    final taskDuration = task.endDate.difference(task.startDate).inDays + 1;
    final isSelected = task.id == selectedTaskId;

    return Container(
      height: 40,
      width: double.infinity,
      margin: EdgeInsets.only(left: isSubtask ? 24 : 0),
      child: Stack(
        children: [
          // Background grid lines
          Positioned.fill(
            child: Row(
              children: [
                for (
                  int i = 0;
                  i < dateRange.end.difference(dateRange.start).inDays;
                  i++
                )
                  Container(
                    width: colWidth,
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
                          _isWeekend(dateRange.start.add(Duration(days: i)))
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
          // Task bar
          Positioned(
            left: taskStart * colWidth,
            top: 8,
            height: 24,
            width: taskDuration * colWidth,
            child: GestureDetector(
              onTap: () {
                ref.read(selectedTaskProvider.notifier).state = task.id;
              },
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyLine(
    BuildContext context,
    Task fromTask,
    Task toTask,
    DateTimeRange dateRange,
    double colWidth,
  ) {
    final fromX =
        (_getDayPosition(fromTask.endDate, dateRange.start) + 1) * colWidth;
    final toX = _getDayPosition(toTask.startDate, dateRange.start) * colWidth;
    final fromY = (_getTaskIndex(fromTask.id) + 0.5) * 40;
    final toY = (_getTaskIndex(toTask.id) + 0.5) * 40;

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: CustomPaint(
        painter: DependencyPainter(
          fromX: fromX,
          fromY: fromY,
          toX: toX,
          toY: toY,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  int _getTaskIndex(String taskId) {
    // For simplicity, we're using a mock index. In a real app,
    // you would calculate this based on task position in the list.
    return int.parse(taskId.split('.').first) - 1;
  }

  Widget _buildTaskDetailsPanel(
    BuildContext context,
    Task task,
    WidgetRef ref,
  ) {
    final taskNotifier = ref.read(tasksProvider.notifier);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditTaskDialog(context, task, ref),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  taskNotifier.deleteTask(task.id);
                  ref.read(selectedTaskProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d, yyyy').format(task.startDate)} - ${DateFormat('MMM d, yyyy').format(task.endDate)}',
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                '${task.endDate.difference(task.startDate).inDays + 1} days',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: task.color,
                    activeTrackColor: task.color,
                    inactiveTrackColor: task.color.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: task.progress,
                    onChanged: (value) {
                      taskNotifier.updateTaskProgress(task.id, value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(task.progress * 100).toInt()}%'),
            ],
          ),
          if (task.dependsOn != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                const Text('Depends on: '),
                Text(
                  task.dependsOn!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Subtask'),
                onPressed: () => _showAddSubtaskDialog(context, task, ref),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Set Complete'),
                onPressed:
                    task.progress >= 1.0
                        ? null
                        : () {
                          taskNotifier.updateTaskProgress(task.id, 1.0);
                        },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isDateInRange(DateTime date, DateTimeRange range) {
    return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
        date.isBefore(range.end.add(const Duration(days: 1)));
  }

  double _getDayPosition(DateTime date, DateTime startDate) {
    return date.difference(startDate).inDays.toDouble();
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    Color taskColor = Colors.blue;
    String? dependsOnId;

    final tasksData = ref.read(tasksProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Task'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: taskTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (date != null) {
                          startDate = date;
                          startDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a start date first'),
                            ),
                          );
                          return;
                        }

                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate!.add(const Duration(days: 1)),
                          firstDate: startDate!,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (date != null) {
                          endDate = date;
                          endDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Depends On (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...tasksData.map(
                          (task) => DropdownMenuItem<String>(
                            value: task.id,
                            child: Text(task.title),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        dependsOnId = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Task Color: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Select Color'),
                                    content: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _colorOption(
                                            context,
                                            Colors.blue,
                                            () {
                                              taskColor = Colors.blue;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.green,
                                            () {
                                              taskColor = Colors.green;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.orange,
                                            () {
                                              taskColor = Colors.orange;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.purple,
                                            () {
                                              taskColor = Colors.purple;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(context, Colors.red, () {
                                            taskColor = Colors.red;
                                            Navigator.of(context).pop();
                                          }),
                                          _colorOption(
                                            context,
                                            Colors.teal,
                                            () {
                                              taskColor = Colors.teal;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: taskColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    if (startDate != null && endDate != null) {
                      final newTask = Task(
                        id: (tasksData.length + 1).toString(),
                        title: taskTitleController.text,
                        startDate: startDate!,
                        endDate: endDate!,
                        color: taskColor,
                        dependsOn: dependsOnId,
                      );

                      ref.read(tasksProvider.notifier).addTask(newTask);
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Add Task'),
              ),
            ],
          ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController(text: task.title);
    final startDateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(task.startDate),
    );
    final endDateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(task.endDate),
    );

    DateTime? startDate = task.startDate;
    DateTime? endDate = task.endDate;
    Color taskColor = task.color;
    String? dependsOnId = task.dependsOn;

    final tasksData = ref.read(tasksProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Task'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: taskTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: task.startDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (date != null) {
                          startDate = date;
                          startDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a start date first'),
                            ),
                          );
                          return;
                        }

                        final date = await showDatePicker(
                          context: context,
                          initialDate: task.endDate,
                          firstDate: startDate!,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (date != null) {
                          endDate = date;
                          endDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Depends On (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: dependsOnId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...tasksData
                            .where((t) => t.id != task.id)
                            .map(
                              (task) => DropdownMenuItem<String>(
                                value: task.id,
                                child: Text(task.title),
                              ),
                            ),
                      ],
                      onChanged: (value) {
                        dependsOnId = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Task Color: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Select Color'),
                                    content: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _colorOption(
                                            context,
                                            Colors.blue,
                                            () {
                                              taskColor = Colors.blue;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.green,
                                            () {
                                              taskColor = Colors.green;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.orange,
                                            () {
                                              taskColor = Colors.orange;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.purple,
                                            () {
                                              taskColor = Colors.purple;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(context, Colors.red, () {
                                            taskColor = Colors.red;
                                            Navigator.of(context).pop();
                                          }),
                                          _colorOption(
                                            context,
                                            Colors.teal,
                                            () {
                                              taskColor = Colors.teal;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: taskColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    if (startDate != null && endDate != null) {
                      final updatedTask = Task(
                        id: task.id,
                        title: taskTitleController.text,
                        startDate: startDate!,
                        endDate: endDate!,
                        progress: task.progress,
                        color: taskColor,
                        subtasks: task.subtasks,
                        dependsOn: dependsOnId,
                      );

                      ref.read(tasksProvider.notifier).updateTask(updatedTask);
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Update Task'),
              ),
            ],
          ),
    );
  }

  void _showAddSubtaskDialog(
    BuildContext context,
    Task parentTask,
    WidgetRef ref,
  ) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController();
    final startDateController = TextEditingController();

    final endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    Color taskColor = parentTask.color;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Subtask'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: taskTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtask Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subtask title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: parentTask.startDate,
                          firstDate: parentTask.startDate,
                          lastDate: parentTask.endDate,
                        );

                        if (date != null) {
                          startDate = date;
                          startDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a start date first'),
                            ),
                          );
                          return;
                        }

                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate!,
                          firstDate: startDate!,
                          lastDate: parentTask.endDate,
                        );

                        if (date != null) {
                          endDate = date;
                          endDateController.text = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Task Color: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Select Color'),
                                    content: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _colorOption(
                                            context,
                                            Colors.blue.shade300,
                                            () {
                                              taskColor = Colors.blue.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.green.shade300,
                                            () {
                                              taskColor = Colors.green.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.orange.shade300,
                                            () {
                                              taskColor =
                                                  Colors.orange.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.purple.shade300,
                                            () {
                                              taskColor =
                                                  Colors.purple.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.red.shade300,
                                            () {
                                              taskColor = Colors.red.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          _colorOption(
                                            context,
                                            Colors.teal.shade300,
                                            () {
                                              taskColor = Colors.teal.shade300;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: taskColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    if (startDate != null && endDate != null) {
                      final newSubtask = Task(
                        id: '${parentTask.id}.${parentTask.subtasks.length + 1}',
                        title: taskTitleController.text,
                        startDate: startDate!,
                        endDate: endDate!,
                        color: taskColor,
                      );

                      final updatedTask = Task(
                        id: parentTask.id,
                        title: parentTask.title,
                        startDate: parentTask.startDate,
                        endDate: parentTask.endDate,
                        progress: parentTask.progress,
                        color: parentTask.color,
                        subtasks: [...parentTask.subtasks, newSubtask],
                        dependsOn: parentTask.dependsOn,
                      );

                      ref.read(tasksProvider.notifier).updateTask(updatedTask);
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Add Subtask'),
              ),
            ],
          ),
    );
  }

  Widget _colorOption(
    BuildContext context,
    Color color,
    VoidCallback onSelect,
  ) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }
}

// Custom painter for dependency arrows
class DependencyPainter extends CustomPainter {
  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final Color color;

  DependencyPainter({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(fromX, fromY);

    final controlPointX = (fromX + toX) / 2;

    path.cubicTo(controlPointX, fromY, controlPointX, toY, toX, toY);

    canvas.drawPath(path, paint);

    // Draw arrow head
    final arrowSize = 6.0;
    final angle = _calculateAngle();

    final arrowPath = Path();
    arrowPath.moveTo(toX, toY);
    arrowPath.lineTo(
      toX - arrowSize * math.cos(angle - math.pi / 6),
      toY - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      toX - arrowSize * math.cos(angle + math.pi / 6),
      toY - arrowSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    final arrowPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  double _calculateAngle() {
    final dx = toX - ((fromX + toX) / 2);
    final dy = 0; // Horizontal line at the end
    return math.atan2(dy, dx);
  }

  @override
  bool shouldRepaint(DependencyPainter oldDelegate) {
    return oldDelegate.fromX != fromX ||
        oldDelegate.fromY != fromY ||
        oldDelegate.toX != toX ||
        oldDelegate.toY != toY ||
        oldDelegate.color != color;
  }
}

// Main app entry point
class GanttChartApp extends StatelessWidget {
  const GanttChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Advanced Gantt Chart',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const GanttChartScreen(),
      ),
    );
  }
}

void main() {
  runApp(const GanttChartApp());
}
