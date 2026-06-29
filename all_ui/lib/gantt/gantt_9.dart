import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Custom painter for dependency arrows
class DependencyLinesPainter extends CustomPainter {
  final List<Task> tasks;
  final List<Map<String, dynamic>> visibleTasks;
  final DateTimeRange dateRange;
  final double colWidth;
  final Set<String> collapsedTasks;
  final Color color;

  DependencyLinesPainter({
    required this.tasks,
    required this.visibleTasks,
    required this.dateRange,
    required this.colWidth,
    required this.collapsedTasks,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final arrowPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Build task position map
    final taskPositions = <String, double>{};
    for (final item in visibleTasks) {
      final task = item['task'] as Task;
      final index = item['index'] as int;
      taskPositions[task.id] = index * 50.0 + 25;
    }

    // Draw dependencies
    for (final item in visibleTasks) {
      final task = item['task'] as Task;

      for (final depId in task.dependsOn) {
        final fromTask = _findTaskById(tasks, depId);
        if (fromTask != null) {
          final fromY = taskPositions[fromTask.id];
          final toY = taskPositions[task.id];

          if (fromY != null && toY != null) {
            final fromX =
                _getDayPosition(fromTask.endDate, dateRange.start) * colWidth +
                colWidth;
            final toX =
                _getDayPosition(task.startDate, dateRange.start) * colWidth;

            _drawDependencyLine(
              canvas,
              fromX,
              fromY,
              toX,
              toY,
              paint,
              arrowPaint,
            );
          }
        }
      }
    }
  }

  void _drawDependencyLine(
    Canvas canvas,
    double fromX,
    double fromY,
    double toX,
    double toY,
    Paint paint,
    Paint arrowPaint,
  ) {
    final path = Path();
    path.moveTo(fromX, fromY);

    final controlPointX = (fromX + toX) / 2;
    path.cubicTo(controlPointX, fromY, controlPointX, toY, toX, toY);

    canvas.drawPath(path, paint);

    // Draw arrow head
    final arrowSize = 8.0;
    final arrowPath = Path();
    arrowPath.moveTo(toX, toY);
    arrowPath.lineTo(toX - arrowSize, toY - arrowSize / 2);
    arrowPath.lineTo(toX - arrowSize, toY + arrowSize / 2);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  Task? _findTaskById(List<Task> tasks, String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
      for (final subtask in task.subtasks) {
        if (subtask.id == id) return subtask;
      }
    }
    return null;
  }

  double _getDayPosition(DateTime date, DateTime startDate) {
    return date.difference(startDate).inDays.toDouble();
  }

  @override
  bool shouldRepaint(DependencyLinesPainter oldDelegate) {
    return true;
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
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

// Models
class Task {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final Color color;
  final List<Task> subtasks;
  final List<String> dependsOn;
  final String? description;
  final String? assignee;
  final TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.progress = 0.0,
    this.color = Colors.blue,
    this.subtasks = const [],
    this.dependsOn = const [],
    this.description,
    this.assignee,
    this.priority = TaskPriority.medium,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    Color? color,
    List<Task>? subtasks,
    List<String>? dependsOn,
    String? description,
    String? assignee,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      subtasks: subtasks ?? this.subtasks,
      dependsOn: dependsOn ?? this.dependsOn,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
    );
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;
  bool get isOverdue => DateTime.now().isAfter(endDate) && progress < 1.0;
  bool get isComplete => progress >= 1.0;

  double get overallProgress {
    if (subtasks.isEmpty) return progress;
    final subtaskProgress =
        subtasks.map((s) => s.progress).reduce((a, b) => a + b) /
        subtasks.length;
    return (progress + subtaskProgress) / 2;
  }
}

enum TaskPriority { low, medium, high, critical }

enum ViewMode { day, week, month, quarter }

enum SortBy { name, startDate, endDate, progress, priority }

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
  final sortBy = ref.watch(sortByProvider);
  final showCompleted = ref.watch(showCompletedProvider);

  var filteredTasks = tasks;

  if (searchQuery.isNotEmpty) {
    filteredTasks =
        filteredTasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  (task.assignee?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
  }

  if (!showCompleted) {
    filteredTasks = filteredTasks.where((task) => !task.isComplete).toList();
  }

  filteredTasks = List.from(filteredTasks);
  switch (sortBy) {
    case SortBy.name:
      filteredTasks.sort((a, b) => a.title.compareTo(b.title));
      break;
    case SortBy.startDate:
      filteredTasks.sort((a, b) => a.startDate.compareTo(b.startDate));
      break;
    case SortBy.endDate:
      filteredTasks.sort((a, b) => a.endDate.compareTo(b.endDate));
      break;
    case SortBy.progress:
      filteredTasks.sort((a, b) => b.progress.compareTo(a.progress));
      break;
    case SortBy.priority:
      filteredTasks.sort(
        (a, b) => b.priority.index.compareTo(a.priority.index),
      );
      break;
  }

  return filteredTasks;
});

final selectedTaskProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final zoomLevelProvider = StateProvider<double>((ref) => 1.0);
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.week);
final sortByProvider = StateProvider<SortBy>((ref) => SortBy.startDate);
final showCompletedProvider = StateProvider<bool>((ref) => true);
final showWeekendsProvider = StateProvider<bool>((ref) => true);
final collapsedTasksProvider = StateProvider<Set<String>>((ref) => {});
final dependencyModeProvider = StateProvider<String?>((ref) => null);

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
        description: 'Initial planning and resource allocation',
        assignee: 'John Doe',
        priority: TaskPriority.high,
        subtasks: [
          Task(
            id: '1.1',
            title: 'Requirements Gathering',
            startDate: now.subtract(const Duration(days: 5)),
            endDate: now.subtract(const Duration(days: 2)),
            progress: 1.0,
            color: Colors.blue.shade300,
            assignee: 'Jane Smith',
            priority: TaskPriority.high,
          ),
          Task(
            id: '1.2',
            title: 'Resource Allocation',
            startDate: now.subtract(const Duration(days: 1)),
            endDate: now.add(const Duration(days: 2)),
            progress: 0.6,
            color: Colors.blue.shade300,
            assignee: 'John Doe',
            priority: TaskPriority.medium,
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
        dependsOn: ['1'],
        description: 'UI/UX design and prototyping',
        assignee: 'Sarah Johnson',
        priority: TaskPriority.high,
      ),
      Task(
        id: '3',
        title: 'Development',
        startDate: now.add(const Duration(days: 11)),
        endDate: now.add(const Duration(days: 25)),
        progress: 0.0,
        color: Colors.orange,
        dependsOn: ['2'],
        description: 'Core development work',
        assignee: 'Mike Wilson',
        priority: TaskPriority.critical,
      ),
      Task(
        id: '4',
        title: 'Testing',
        startDate: now.add(const Duration(days: 25)),
        endDate: now.add(const Duration(days: 30)),
        progress: 0.0,
        color: Colors.purple,
        dependsOn: ['3'],
        description: 'QA and testing phase',
        assignee: 'Emily Brown',
        priority: TaskPriority.high,
      ),
    ];
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state =
        state.map((task) {
          if (task.id == updatedTask.id) {
            return updatedTask;
          }
          if (task.subtasks.any((s) => s.id == updatedTask.id)) {
            return task.copyWith(
              subtasks:
                  task.subtasks
                      .map((s) => s.id == updatedTask.id ? updatedTask : s)
                      .toList(),
            );
          }
          return task;
        }).toList();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    state =
        state.map((task) {
          if (task.dependsOn.contains(taskId)) {
            return task.copyWith(
              dependsOn: task.dependsOn.where((id) => id != taskId).toList(),
            );
          }
          return task;
        }).toList();
  }

  void updateTaskProgress(String taskId, double progress) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return task.copyWith(progress: progress);
          }
          if (task.subtasks.any((s) => s.id == taskId)) {
            return task.copyWith(
              subtasks:
                  task.subtasks
                      .map(
                        (s) =>
                            s.id == taskId ? s.copyWith(progress: progress) : s,
                      )
                      .toList(),
            );
          }
          return task;
        }).toList();
  }

  void updateTaskDates(String taskId, DateTime startDate, DateTime endDate) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return task.copyWith(startDate: startDate, endDate: endDate);
          }
          if (task.subtasks.any((s) => s.id == taskId)) {
            return task.copyWith(
              subtasks:
                  task.subtasks
                      .map(
                        (s) =>
                            s.id == taskId
                                ? s.copyWith(
                                  startDate: startDate,
                                  endDate: endDate,
                                )
                                : s,
                      )
                      .toList(),
            );
          }
          return task;
        }).toList();
  }

  void addDependency(String taskId, String dependsOnId) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            if (!task.dependsOn.contains(dependsOnId)) {
              return task.copyWith(dependsOn: [...task.dependsOn, dependsOnId]);
            }
          }
          return task;
        }).toList();
  }

  void removeDependency(String taskId, String dependsOnId) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return task.copyWith(
              dependsOn:
                  task.dependsOn.where((id) => id != dependsOnId).toList(),
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
    final dependencyMode = ref.watch(dependencyModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Gantt Chart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (dependencyMode != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 18),
                  const SizedBox(width: 8),
                  const Text('Select Target Task'),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      ref.read(dependencyModeProvider.notifier).state = null;
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context, ref),
            tooltip: 'Add Task',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context, ref),
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(context, ref),
          _buildStatsBar(context, tasks),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _buildTaskListPanel(context, tasks, ref),
                ),
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
              _findTaskById(tasks, selectedTaskId),
              ref,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Task? _findTaskById(List<Task> tasks, String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
      for (final subtask in task.subtasks) {
        if (subtask.id == id) return subtask;
      }
    }
    return tasks.isNotEmpty ? tasks[0] : null;
  }

  Widget _buildStatsBar(BuildContext context, List<Task> tasks) {
    final totalTasks =
        tasks.length + tasks.fold(0, (sum, task) => sum + task.subtasks.length);
    final completedTasks =
        tasks.where((t) => t.isComplete).length +
        tasks.fold(
          0,
          (sum, task) => sum + task.subtasks.where((s) => s.isComplete).length,
        );
    final overdueTasks =
        tasks.where((t) => t.isOverdue).length +
        tasks.fold(
          0,
          (sum, task) => sum + task.subtasks.where((s) => s.isOverdue).length,
        );
    final avgProgress =
        tasks.isEmpty
            ? 0.0
            : tasks.fold(0.0, (sum, task) => sum + task.overallProgress) /
                tasks.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            Icons.task_alt,
            'Total',
            totalTasks.toString(),
            Colors.blue,
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            context,
            Icons.check_circle,
            'Completed',
            completedTasks.toString(),
            Colors.green,
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            context,
            Icons.warning,
            'Overdue',
            overdueTasks.toString(),
            Colors.red,
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            context,
            Icons.trending_up,
            'Avg Progress',
            '${(avgProgress * 100).toInt()}%',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);
    final sortBy = ref.watch(sortByProvider);
    final showCompleted = ref.watch(showCompletedProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks or assignees...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  onChanged:
                      (value) =>
                          ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<ViewMode>(
                value: viewMode,
                underline: const SizedBox(),
                items:
                    ViewMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Row(
                          children: [
                            Icon(_getViewModeIcon(mode), size: 18),
                            const SizedBox(width: 8),
                            Text(mode.name.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(viewModeProvider.notifier).state = value;
                  }
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<SortBy>(
                value: sortBy,
                underline: const SizedBox(),
                items:
                    SortBy.values.map((sort) {
                      return DropdownMenuItem(
                        value: sort,
                        child: Row(
                          children: [
                            const Icon(Icons.sort, size: 18),
                            const SizedBox(width: 8),
                            Text(sort.name.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortByProvider.notifier).state = value;
                  }
                },
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Show Completed'),
                selected: showCompleted,
                onSelected: (value) {
                  ref.read(showCompletedProvider.notifier).state = value;
                },
                avatar: Icon(
                  showCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.zoom_in, size: 20),
              Expanded(
                child: Slider(
                  value: zoomLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${(zoomLevel * 100).toInt()}%',
                  onChanged: (value) {
                    ref.read(zoomLevelProvider.notifier).state = value;
                  },
                ),
              ),
              Text('${(zoomLevel * 100).toInt()}%'),
              const SizedBox(width: 16),
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
            ],
          ),
        ],
      ),
    );
  }

  IconData _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.day:
        return Icons.view_day;
      case ViewMode.week:
        return Icons.view_week;
      case ViewMode.month:
        return Icons.calendar_view_month;
      case ViewMode.quarter:
        return Icons.calendar_view_week;
    }
  }

  Widget _buildTaskListPanel(
    BuildContext context,
    List<Task> tasks,
    WidgetRef ref,
  ) {
    final selectedTaskId = ref.watch(selectedTaskProvider);
    final collapsedTasks = ref.watch(collapsedTasksProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tasks (${tasks.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isCollapsed = collapsedTasks.contains(task.id);
                return Column(
                  children: [
                    _buildTaskListItem(
                      context,
                      task,
                      selectedTaskId,
                      ref,
                      isCollapsed: isCollapsed,
                    ),
                    if (!isCollapsed)
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
    bool isCollapsed = false,
  }) {
    final isSelected = task.id == selectedTaskId;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showTaskContextMenu(context, ref, task, details.globalPosition);
      },
      child: InkWell(
        onTap: () {
          ref.read(selectedTaskProvider.notifier).state = task.id;
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSubtask ? 32 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              if (!isSubtask && task.subtasks.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    final collapsed = ref.read(collapsedTasksProvider);
                    if (collapsed.contains(task.id)) {
                      ref.read(collapsedTasksProvider.notifier).state =
                          collapsed.where((id) => id != task.id).toSet();
                    } else {
                      ref.read(collapsedTasksProvider.notifier).state = {
                        ...collapsed,
                        task.id,
                      };
                    }
                  },
                  child: Icon(
                    isCollapsed ? Icons.chevron_right : Icons.expand_more,
                    size: 18,
                  ),
                )
              else
                const SizedBox(width: 18),
              const SizedBox(width: 4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: isSubtask ? 13 : 14,
                              decoration:
                                  task.isComplete
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ),
                        if (task.priority == TaskPriority.critical)
                          const Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Colors.red,
                          )
                        else if (task.priority == TaskPriority.high)
                          const Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                    if (task.assignee != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.assignee!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if (task.isOverdue) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'OVERDUE',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: task.progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: task.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(task.progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskContextMenu(
    BuildContext context,
    WidgetRef ref,
    Task task,
    Offset position,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.info, size: 18),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
          onTap: () {
            ref.read(selectedTaskProvider.notifier).state = task.id;
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit Task'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showEditTaskDialog(context, task, ref),
            );
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.link, size: 18),
              SizedBox(width: 8),
              Text('Add Dependency'),
            ],
          ),
          onTap: () {
            ref.read(dependencyModeProvider.notifier).state = task.id;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Click on a task to create dependency'),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
        if (task.dependsOn.isNotEmpty)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.link_off, size: 18),
                SizedBox(width: 8),
                Text('Remove Dependencies'),
              ],
            ),
            onTap: () {
              for (final depId in task.dependsOn) {
                ref
                    .read(tasksProvider.notifier)
                    .removeDependency(task.id, depId);
              }
            },
          ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Task', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: Text(
                        'Are you sure you want to delete "${task.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(tasksProvider.notifier)
                                .deleteTask(task.id);
                            ref.read(selectedTaskProvider.notifier).state =
                                null;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );
            });
          },
        ),
      ],
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
    final daysDiff = dateRange.end.difference(dateRange.start).inDays;
    final showWeekends = ref.watch(showWeekendsProvider);
    final collapsedTasks = ref.watch(collapsedTasksProvider);

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

    // Build flat list of visible tasks with their indices
    final visibleTasks = <Map<String, dynamic>>[];
    var rowIndex = 0;
    for (final task in tasks) {
      visibleTasks.add({'task': task, 'index': rowIndex, 'isSubtask': false});
      rowIndex++;

      if (!collapsedTasks.contains(task.id)) {
        for (final subtask in task.subtasks) {
          visibleTasks.add({
            'task': subtask,
            'index': rowIndex,
            'isSubtask': true,
          });
          rowIndex++;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: [
          _buildTimelineHeader(
            context,
            dateRange,
            colWidth,
            viewMode,
            showWeekends,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: daysDiff * colWidth,
                  height: visibleTasks.length * 50.0,
                  child: Stack(
                    children: [
                      // Task bars
                      ...visibleTasks.map((item) {
                        final task = item['task'] as Task;
                        final index = item['index'] as int;
                        final isSubtask = item['isSubtask'] as bool;

                        return Positioned(
                          top: index * 50.0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: _buildTaskBar(
                            context,
                            task,
                            dateRange,
                            colWidth,
                            selectedTaskId,
                            ref,
                            showWeekends,
                            isSubtask: isSubtask,
                          ),
                        );
                      }),
                      // Dependency lines
                      CustomPaint(
                        size: Size(
                          daysDiff * colWidth,
                          visibleTasks.length * 50.0,
                        ),
                        painter: DependencyLinesPainter(
                          tasks: tasks,
                          visibleTasks: visibleTasks,
                          dateRange: dateRange,
                          colWidth: colWidth,
                          collapsedTasks: collapsedTasks,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
    bool showWeekends,
  ) {
    final days = dateRange.end.difference(dateRange.start).inDays;
    final dateFormat = DateFormat('MMM d');
    final weekdayFormat = DateFormat('EEE');
    final today = DateTime.now();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 2),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    (days / (viewMode == ViewMode.day ? 1 : 7)).ceil(),
                    (i) {
                      final date = dateRange.start.add(
                        Duration(days: i * (viewMode == ViewMode.day ? 1 : 7)),
                      );
                      final width =
                          viewMode == ViewMode.day ? colWidth : colWidth * 7;
                      return Container(
                        width: width,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          viewMode == ViewMode.day
                              ? dateFormat.format(date)
                              : 'Week ${_getWeekNumber(date)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            height: 35,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(days, (i) {
                  final date = dateRange.start.add(Duration(days: i));
                  final isToday = _isSameDay(date, today);
                  final isWeekend = _isWeekend(date);

                  return Container(
                    width: colWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isToday
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                              : null,
                      border: Border(
                        right: BorderSide(
                          color:
                              isWeekend
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayFormat.format(date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color:
                                isWeekend
                                    ? Colors.red.shade700
                                    : isToday
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color:
                                isToday
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          if (_isDateInRange(today, dateRange))
            Positioned(
              left:
                  _getDayPosition(today, dateRange.start) * colWidth +
                  colWidth / 2,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTaskBar(
    BuildContext context,
    Task task,
    DateTimeRange dateRange,
    double colWidth,
    String? selectedTaskId,
    WidgetRef ref,
    bool showWeekends, {
    bool isSubtask = false,
  }) {
    final taskStart = _getDayPosition(task.startDate, dateRange.start);
    final taskDuration = task.endDate.difference(task.startDate).inDays + 1;
    final isSelected = task.id == selectedTaskId;
    final today = DateTime.now();
    final dependencyMode = ref.watch(dependencyModeProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onSecondaryTapDown: (details) {
          _showTaskContextMenu(context, ref, task, details.globalPosition);
        },
        child: Container(
          height: 50,
          margin: EdgeInsets.only(left: isSubtask ? 32 : 0),
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: List.generate(
                    dateRange.end.difference(dateRange.start).inDays,
                    (i) {
                      final date = dateRange.start.add(Duration(days: i));
                      final isToday = _isSameDay(date, today);
                      final isWeekend = _isWeekend(date);

                      return Container(
                        width: colWidth,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          color:
                              isToday
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.05)
                                  : isWeekend
                                  ? Colors.grey.withValues(alpha: 0.05)
                                  : Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_isDateInRange(today, dateRange))
                Positioned(
                  left:
                      _getDayPosition(today, dateRange.start) * colWidth +
                      colWidth / 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              Positioned(
                left: math.max(0, taskStart * colWidth),
                top: 12,
                height: 26,
                width: math.max(colWidth * 0.5, taskDuration * colWidth),
                child: Draggable<Map<String, dynamic>>(
                  data: {'taskId': task.id, 'duration': taskDuration},
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: taskDuration * colWidth,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            task.color.withValues(alpha: 0.9),
                            task.color.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildTaskBarContent(
                      context,
                      task,
                      isSelected,
                      taskDuration * colWidth,
                    ),
                  ),
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) => data?['taskId'] != task.id,
                    onAccept: (data) {
                      final draggedTaskId = data['taskId'] as String;
                      final duration = data['duration'] as int;

                      final newStart = task.startDate;
                      final newEnd = newStart.add(Duration(days: duration - 1));

                      ref
                          .read(tasksProvider.notifier)
                          .updateTaskDates(draggedTaskId, newStart, newEnd);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task moved to ${DateFormat('MMM d').format(newStart)}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: () {
                          if (dependencyMode != null &&
                              dependencyMode != task.id) {
                            ref
                                .read(tasksProvider.notifier)
                                .addDependency(dependencyMode, task.id);
                            ref.read(dependencyModeProvider.notifier).state =
                                null;

                            final sourceTask = _findTaskById(
                              ref.read(tasksProvider),
                              dependencyMode,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Dependency created: ${sourceTask?.title} → ${task.title}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ref.read(selectedTaskProvider.notifier).state =
                                task.id;
                          }
                        },
                        child: _buildTaskBarContent(
                          context,
                          task,
                          isSelected,
                          taskDuration * colWidth,
                          isHovered: candidateData.isNotEmpty,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskBarContent(
    BuildContext context,
    Task task,
    bool isSelected,
    double width, {
    bool isHovered = false,
  }) {
    return Tooltip(
      message:
          '${task.title}\n${DateFormat('MMM d').format(task.startDate)} - ${DateFormat('MMM d').format(task.endDate)}\n${task.durationInDays} days • ${(task.progress * 100).toInt()}% complete\n\nDrag to move • Right-click for options',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [
              task.color.withValues(alpha: isHovered ? 1.0 : 0.8),
              task.color.withValues(alpha: isHovered ? 0.8 : 0.6),
            ],
          ),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : isHovered
                    ? Colors.white
                    : task.color.withValues(alpha: 0.8),
            width:
                isSelected
                    ? 2.5
                    : isHovered
                    ? 2
                    : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: task.color.withValues(alpha: isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 6 : 3,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: task.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [task.color, task.color.withValues(alpha: 0.9)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (task.priority == TaskPriority.critical)
                      const Icon(
                        Icons.priority_high,
                        size: 14,
                        color: Colors.white,
                      )
                    else if (task.priority == TaskPriority.high)
                      const Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: Colors.white,
                      ),
                    if (task.priority == TaskPriority.critical ||
                        task.priority == TaskPriority.high)
                      const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (task.isComplete)
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.white,
                      )
                    else if (task.isOverdue)
                      const Icon(Icons.warning, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetailsPanel(
    BuildContext context,
    Task? task,
    WidgetRef ref,
  ) {
    if (task == null) return const SizedBox.shrink();

    final taskNotifier = ref.read(tasksProvider.notifier);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditTaskDialog(context, task, ref),
                tooltip: 'Edit Task',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: Text(
                            'Are you sure you want to delete "${task.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                taskNotifier.deleteTask(task.id);
                                ref.read(selectedTaskProvider.notifier).state =
                                    null;
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                },
                tooltip: 'Delete Task',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedTaskProvider.notifier).state = null;
                },
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildDetailChip(
                context,
                Icons.calendar_today,
                'Start',
                DateFormat('MMM d, yyyy').format(task.startDate),
              ),
              _buildDetailChip(
                context,
                Icons.event,
                'End',
                DateFormat('MMM d, yyyy').format(task.endDate),
              ),
              _buildDetailChip(
                context,
                Icons.timer,
                'Duration',
                '${task.durationInDays} days',
              ),
              if (task.assignee != null)
                _buildDetailChip(
                  context,
                  Icons.person,
                  'Assignee',
                  task.assignee!,
                ),
              _buildDetailChip(
                context,
                Icons.flag,
                'Priority',
                task.priority.name.toUpperCase(),
                color: _getPriorityColor(task.priority),
              ),
              if (task.dependsOn.isNotEmpty)
                _buildDetailChip(
                  context,
                  Icons.link,
                  'Dependencies',
                  task.dependsOn.length.toString(),
                ),
              if (task.isOverdue)
                _buildDetailChip(
                  context,
                  Icons.warning,
                  'Status',
                  'OVERDUE',
                  color: Colors.red,
                ),
              if (task.isComplete)
                _buildDetailChip(
                  context,
                  Icons.check_circle,
                  'Status',
                  'COMPLETED',
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Progress: ${(task.progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: task.color,
                    activeTrackColor: task.color,
                    inactiveTrackColor: task.color.withValues(alpha: 0.2),
                    overlayColor: task.color.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: task.progress,
                    onChanged: (value) {
                      taskNotifier.updateTaskProgress(task.id, value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!task.id.contains('.'))
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                  onPressed: () => _showAddSubtaskDialog(context, task, ref),
                ),
              const SizedBox(width: 12),
              if (!task.isComplete)
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Complete'),
                  onPressed: () {
                    taskNotifier.updateTaskProgress(task.id, 1.0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Reopen'),
                  onPressed: () {
                    taskNotifier.updateTaskProgress(task.id, 0.8);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Theme.of(context).colorScheme.primary).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

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
    _showTaskDialog(context, ref, null);
  }

  void _showEditTaskDialog(BuildContext context, Task task, WidgetRef ref) {
    _showTaskDialog(context, ref, task);
  }

  void _showTaskDialog(
    BuildContext context,
    WidgetRef ref,
    Task? existingTask,
  ) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController(
      text: existingTask?.title,
    );
    final descriptionController = TextEditingController(
      text: existingTask?.description,
    );
    final assigneeController = TextEditingController(
      text: existingTask?.assignee,
    );
    final startDateController = TextEditingController(
      text:
          existingTask != null
              ? DateFormat('MMM d, yyyy').format(existingTask.startDate)
              : '',
    );
    final endDateController = TextEditingController(
      text:
          existingTask != null
              ? DateFormat('MMM d, yyyy').format(existingTask.endDate)
              : '',
    );

    DateTime? startDate = existingTask?.startDate;
    DateTime? endDate = existingTask?.endDate;
    Color taskColor = existingTask?.color ?? Colors.blue;
    TaskPriority priority = existingTask?.priority ?? TaskPriority.medium;

    final tasksData = ref.read(tasksProvider);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    existingTask == null ? 'Add New Task' : 'Edit Task',
                  ),
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
                              prefixIcon: Icon(Icons.title),
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
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: assigneeController,
                            decoration: const InputDecoration(
                              labelText: 'Assignee (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
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
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );

                              if (date != null) {
                                setState(() {
                                  startDate = date;
                                  startDateController.text = DateFormat(
                                    'MMM d, yyyy',
                                  ).format(date);
                                });
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
                              suffixIcon: Icon(Icons.event),
                            ),
                            readOnly: true,
                            onTap: () async {
                              if (startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a start date first',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    endDate ??
                                    startDate!.add(const Duration(days: 1)),
                                firstDate: startDate!,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );

                              if (date != null) {
                                setState(() {
                                  endDate = date;
                                  endDateController.text = DateFormat(
                                    'MMM d, yyyy',
                                  ).format(date);
                                });
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
                          DropdownButtonFormField<TaskPriority>(
                            value: priority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.flag),
                            ),
                            items:
                                TaskPriority.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getPriorityIcon(p),
                                          size: 18,
                                          color: _getPriorityColor(p),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(p.name.toUpperCase()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  priority = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Task Color: '),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Select Color'),
                                          content: Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children:
                                                [
                                                      Colors.blue,
                                                      Colors.green,
                                                      Colors.orange,
                                                      Colors.purple,
                                                      Colors.red,
                                                      Colors.teal,
                                                      Colors.pink,
                                                      Colors.indigo,
                                                      Colors.amber,
                                                      Colors.cyan,
                                                    ]
                                                    .map(
                                                      (color) => _colorOption(
                                                        context,
                                                        color,
                                                        () {
                                                          setState(() {
                                                            taskColor = color;
                                                          });
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: taskColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: taskColor.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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
                            final task = Task(
                              id:
                                  existingTask?.id ??
                                  (tasksData.length + 1).toString(),
                              title: taskTitleController.text,
                              startDate: startDate!,
                              endDate: endDate!,
                              progress: existingTask?.progress ?? 0.0,
                              color: taskColor,
                              dependsOn: existingTask?.dependsOn ?? [],
                              description:
                                  descriptionController.text.isEmpty
                                      ? null
                                      : descriptionController.text,
                              assignee:
                                  assigneeController.text.isEmpty
                                      ? null
                                      : assigneeController.text,
                              priority: priority,
                              subtasks: existingTask?.subtasks ?? [],
                            );

                            if (existingTask == null) {
                              ref.read(tasksProvider.notifier).addTask(task);
                            } else {
                              ref.read(tasksProvider.notifier).updateTask(task);
                            }
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text(
                        existingTask == null ? 'Add Task' : 'Update Task',
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }

  void _showAddSubtaskDialog(
    BuildContext context,
    Task parentTask,
    WidgetRef ref,
  ) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController();
    final assigneeController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    Color taskColor = parentTask.color.withValues(alpha: 0.7);
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Add Subtask to "${parentTask.title}"'),
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
                              prefixIcon: Icon(Icons.title),
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
                            controller: assigneeController,
                            decoration: const InputDecoration(
                              labelText: 'Assignee (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
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
                                setState(() {
                                  startDate = date;
                                  startDateController.text = DateFormat(
                                    'MMM d, yyyy',
                                  ).format(date);
                                });
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
                              suffixIcon: Icon(Icons.event),
                            ),
                            readOnly: true,
                            onTap: () async {
                              if (startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a start date first',
                                    ),
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
                                setState(() {
                                  endDate = date;
                                  endDateController.text = DateFormat(
                                    'MMM d, yyyy',
                                  ).format(date);
                                });
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
                          DropdownButtonFormField<TaskPriority>(
                            value: priority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.flag),
                            ),
                            items:
                                TaskPriority.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getPriorityIcon(p),
                                          size: 18,
                                          color: _getPriorityColor(p),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(p.name.toUpperCase()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  priority = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Color: '),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Select Color'),
                                          content: Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children:
                                                [
                                                      Colors.blue.shade300,
                                                      Colors.green.shade300,
                                                      Colors.orange.shade300,
                                                      Colors.purple.shade300,
                                                      Colors.red.shade300,
                                                      Colors.teal.shade300,
                                                    ]
                                                    .map(
                                                      (color) => _colorOption(
                                                        context,
                                                        color,
                                                        () {
                                                          setState(() {
                                                            taskColor = color;
                                                          });
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: taskColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
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
                              id:
                                  '${parentTask.id}.${parentTask.subtasks.length + 1}',
                              title: taskTitleController.text,
                              startDate: startDate!,
                              endDate: endDate!,
                              color: taskColor,
                              assignee:
                                  assigneeController.text.isEmpty
                                      ? null
                                      : assigneeController.text,
                              priority: priority,
                            );

                            final updatedTask = parentTask.copyWith(
                              subtasks: [...parentTask.subtasks, newSubtask],
                            );

                            ref
                                .read(tasksProvider.notifier)
                                .updateTask(updatedTask);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text('Add Subtask'),
                    ),
                  ],
                ),
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
