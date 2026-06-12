import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Models
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int priority; // 1-3 (Low, Medium, High)
  final List<String> dependencyIds;
  final bool isCompleted;
  final Map<String, Duration> timeTrackingEntries;
  final Duration totalTimeSpent;
  final String columnId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    required this.priority,
    required this.dependencyIds,
    required this.isCompleted,
    required this.timeTrackingEntries,
    required this.totalTimeSpent,
    required this.columnId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    List<String>? dependencyIds,
    bool? isCompleted,
    Map<String, Duration>? timeTrackingEntries,
    Duration? totalTimeSpent,
    String? columnId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      isCompleted: isCompleted ?? this.isCompleted,
      timeTrackingEntries: timeTrackingEntries ?? this.timeTrackingEntries,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      columnId: columnId ?? this.columnId,
    );
  }
}

class TaskColumn {
  final String id;
  final String title;
  final List<String> taskIds;
  final Color color;

  TaskColumn({
    required this.id,
    this.title = '',
    this.taskIds = const [],
    this.color = Colors.grey,
  });

  TaskColumn copyWith({
    String? id,
    String? title,
    List<String>? taskIds,
    Color? color,
  }) {
    return TaskColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      taskIds: taskIds ?? this.taskIds,
      color: color ?? this.color,
    );
  }
}

// Providers
final taskColumnsProvider =
    StateNotifierProvider<TaskColumnsNotifier, List<TaskColumn>>((ref) {
      return TaskColumnsNotifier();
    });

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

final filteredTasksProvider = Provider.family<List<Task>, String>((
  ref,
  columnId,
) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((task) => task.columnId == columnId).toList();
});

final runningTaskProvider = StateProvider<String?>((ref) => null);

final elapsedTimeProvider = StreamProvider.family<Duration, String>((
  ref,
  taskId,
) async* {
  final runningTaskId = ref.watch(runningTaskProvider);

  if (runningTaskId != taskId) {
    yield Duration.zero;
    return;
  }

  Duration elapsed = Duration.zero;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    elapsed += const Duration(seconds: 1);
    yield elapsed;
  }
});

final dependencyTasksProvider = Provider.family<List<Task>, String>((
  ref,
  taskId,
) {
  final task = ref.watch(tasksProvider).firstWhere((t) => t.id == taskId);
  final allTasks = ref.watch(tasksProvider);

  return allTasks.where((t) => task.dependencyIds.contains(t.id)).toList();
});

// Notifiers
class TaskColumnsNotifier extends StateNotifier<List<TaskColumn>> {
  TaskColumnsNotifier()
    : super([
        TaskColumn(
          id: 'column-1',
          title: 'To Do',
          taskIds: [],
          color: Colors.grey,
        ),
        TaskColumn(
          id: 'column-2',
          title: 'In Progress',
          taskIds: [],
          color: Colors.blue,
        ),
        TaskColumn(
          id: 'column-3',
          title: 'Done',
          taskIds: [],
          color: Colors.green,
        ),
      ]);

  void addColumn(String title, Color color) {
    final newColumn = TaskColumn(
      id: 'column-${const Uuid().v4()}',
      title: title,
      taskIds: [],
      color: color,
    );
    state = [...state, newColumn];
  }

  void updateColumn(TaskColumn updatedColumn) {
    state = state.map((column) {
      return column.id == updatedColumn.id ? updatedColumn : column;
    }).toList();
  }

  void deleteColumn(String columnId) {
    state = state.where((column) => column.id != columnId).toList();
  }

  void addTaskToColumn(String columnId, String taskId) {
    state = state.map((column) {
      if (column.id == columnId) {
        return column.copyWith(taskIds: [...column.taskIds, taskId]);
      }
      return column;
    }).toList();
  }

  void removeTaskFromColumn(String columnId, String taskId) {
    state = state.map((column) {
      if (column.id == columnId) {
        return column.copyWith(
          taskIds: column.taskIds.where((id) => id != taskId).toList(),
        );
      }
      return column;
    }).toList();
  }

  void reorderTasksInColumn(String columnId, int oldIndex, int newIndex) {
    final column = state.firstWhere((column) => column.id == columnId);
    final taskIds = List<String>.from(column.taskIds);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = taskIds.removeAt(oldIndex);
    taskIds.insert(newIndex, item);

    state = state.map((c) {
      return c.id == columnId ? c.copyWith(taskIds: taskIds) : c;
    }).toList();
  }
}

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state = state.map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void moveTaskToColumn(String taskId, String newColumnId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(columnId: newColumnId);
      }
      return task;
    }).toList();
  }

  void toggleTaskCompletion(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }

  void changePriority(String taskId, int priority) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(priority: priority);
      }
      return task;
    }).toList();
  }

  void startTimeTracking(String taskId) {
    final now = DateTime.now();
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedEntries = Map<String, Duration>.from(
          task.timeTrackingEntries,
        );
        updatedEntries[now.toIso8601String()] = Duration.zero;
        return task.copyWith(timeTrackingEntries: updatedEntries);
      }
      return task;
    }).toList();
  }

  void stopTimeTracking(String taskId, Duration elapsed) {
    state = state.map((task) {
      if (task.id == taskId) {
        final entries = Map<String, Duration>.from(task.timeTrackingEntries);

        // Find the last entry with zero duration and update it
        final lastEntryKey = entries.entries
            .lastWhere((entry) => entry.value == Duration.zero)
            .key;

        entries[lastEntryKey] = elapsed;

        return task.copyWith(
          timeTrackingEntries: entries,
          totalTimeSpent: task.totalTimeSpent + elapsed,
        );
      }
      return task;
    }).toList();
  }

  void addDependency(String taskId, String dependencyId) {
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedDependencies = List<String>.from(task.dependencyIds);
        if (!updatedDependencies.contains(dependencyId)) {
          updatedDependencies.add(dependencyId);
        }
        return task.copyWith(dependencyIds: updatedDependencies);
      }
      return task;
    }).toList();
  }

  void removeDependency(String taskId, String dependencyId) {
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedDependencies = List<String>.from(task.dependencyIds);
        updatedDependencies.remove(dependencyId);
        return task.copyWith(dependencyIds: updatedDependencies);
      }
      return task;
    }).toList();
  }
}

// Widgets
class TaskBoard extends ConsumerWidget {
  const TaskBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = ref.watch(taskColumnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTaskDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.view_column),
            onPressed: () => _showCreateColumnDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: columns.isEmpty
            ? const Center(
                child: Text('No columns available. Create one to start.'),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: columns.length,
                itemBuilder: (context, index) {
                  final column = columns[index];
                  return TaskColumnWidget(column: column);
                },
              ),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    final columns = ref.read(taskColumnsProvider);
    if (columns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a column first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => TaskForm(initialColumnId: columns.first.id),
    );
  }

  void _showCreateColumnDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Column Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children:
                    [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.teal,
                      Colors.pink,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () => selectedColor = color,
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 16,
                          child: selectedColor == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref
                      .read(taskColumnsProvider.notifier)
                      .addColumn(titleController.text, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class TaskColumnWidget extends ConsumerWidget {
  final TaskColumn column;

  const TaskColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider(column.id));

    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: column.color.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  column.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${tasks.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onAccept: (taskId) {
                final tasksNotifier = ref.read(tasksProvider.notifier);
                final columnsNotifier = ref.read(taskColumnsProvider.notifier);

                // Get the task
                final task = ref
                    .read(tasksProvider)
                    .firstWhere((t) => t.id == taskId);

                // Remove from old column
                columnsNotifier.removeTaskFromColumn(task.columnId, taskId);

                // Add to new column
                columnsNotifier.addTaskToColumn(column.id, taskId);

                // Update task's column
                tasksNotifier.moveTaskToColumn(taskId, column.id);
              },
              builder: (context, candidateData, rejectedData) {
                return tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(taskColumnsProvider.notifier)
                              .reorderTasksInColumn(
                                column.id,
                                oldIndex,
                                newIndex,
                              );
                        },
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(key: ValueKey(task.id), task: task);
                        },
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: column.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showAddTaskDialog(context, ref, column.id),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref,
    String columnId,
  ) {
    showDialog(
      context: context,
      builder: (context) => TaskForm(initialColumnId: columnId),
    );
  }
}

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dependencyTasks = ref.watch(dependencyTasksProvider(task.id));
    final elapsedTime = ref.watch(elapsedTimeProvider(task.id));
    final isRunning = ref.watch(runningTaskProvider) == task.id;

    return Draggable<String>(
      data: task.id,
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: _buildCardContent(
            context,
            ref,
            dependencyTasks,
            elapsedTime,
            isRunning,
            true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(
          context,
          ref,
          dependencyTasks,
          elapsedTime,
          isRunning,
          false,
        ),
      ),
      child: _buildCardContent(
        context,
        ref,
        dependencyTasks,
        elapsedTime,
        isRunning,
        false,
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    WidgetRef ref,
    List<Task> dependencyTasks,
    AsyncValue<Duration> elapsedTime,
    bool isRunning,
    bool isDragging,
  ) {
    return Card(
      elevation: isDragging ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getPriorityColor(task.priority), width: 2),
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPriorityIndicator(task.priority),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          ref
                              .read(tasksProvider.notifier)
                              .toggleTaskCompletion(task.id);
                        },
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditTaskDialog(context, ref);
                          break;
                        case 'delete':
                          _deleteTask(context, ref);
                          break;
                        case 'dependencies':
                          _showDependenciesDialog(context, ref);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'dependencies',
                        child: Text('Manage Dependencies'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: _isDueDateNear(task.dueDate!)
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDueDateNear(task.dueDate!)
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              if (dependencyTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDependencyTags(dependencyTasks),
              ],
              const SizedBox(height: 8),
              _buildTimeTrackingWidget(context, ref, elapsedTime, isRunning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    String label;
    Color color;

    switch (priority) {
      case 1:
        label = 'LOW';
        color = Colors.green;
        break;
      case 2:
        label = 'MED';
        color = Colors.orange;
        break;
      case 3:
        label = 'HIGH';
        color = Colors.red;
        break;
      default:
        label = 'N/A';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _isDueDateNear(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 2 && difference >= 0;
  }

  Widget _buildDependencyTags(List<Task> dependencies) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: dependencies.map((dep) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 10, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                dep.title.length > 15
                    ? '${dep.title.substring(0, 15)}...'
                    : dep.title,
                style: TextStyle(fontSize: 10, color: Colors.blue[700]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeTrackingWidget(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Duration> elapsedTimeValue,
    bool isRunning,
  ) {
    final formattedTime = elapsedTimeValue.when(
      data: (duration) => _formatDuration(
        isRunning ? task.totalTimeSpent + duration : task.totalTimeSpent,
      ),
      loading: () => _formatDuration(task.totalTimeSpent),
      error: (_, __) => _formatDuration(task.totalTimeSpent),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        if (!task.isCompleted)
          IconButton(
            icon: Icon(
              isRunning ? Icons.stop_circle : Icons.play_circle,
              color: isRunning ? Colors.red : Colors.green,
            ),
            iconSize: 24,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: () {
              final tasksNotifier = ref.read(tasksProvider.notifier);
              final runningTaskNotifier = ref.read(
                runningTaskProvider.notifier,
              );

              if (isRunning) {
                // Stop time tracking
                elapsedTimeValue.whenData((elapsed) {
                  tasksNotifier.stopTimeTracking(task.id, elapsed);
                });
                runningTaskNotifier.state = null;
              } else {
                // Check if another task is running
                final currentRunningTask = ref.read(runningTaskProvider);
                if (currentRunningTask != null) {
                  // Stop the current task
                  ref.read(elapsedTimeProvider(currentRunningTask)).whenData((
                    elapsed,
                  ) {
                    tasksNotifier.stopTimeTracking(currentRunningTask, elapsed);
                  });
                }

                // Start tracking for this task
                tasksNotifier.startTimeTracking(task.id);
                runningTaskNotifier.state = task.id;
              }
            },
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showTaskDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Status',
                  task.isCompleted ? 'Completed' : 'In Progress',
                ),
                _buildDetailRow('Priority', _getPriorityLabel(task.priority)),
                _buildDetailRow(
                  'Created',
                  DateFormat('MMM dd, yyyy').format(task.createdAt),
                ),
                if (task.dueDate != null)
                  _buildDetailRow(
                    'Due Date',
                    DateFormat('MMM dd, yyyy').format(task.dueDate!),
                  ),
                _buildDetailRow(
                  'Time Spent',
                  _formatDuration(task.totalTimeSpent),
                ),
                const Divider(),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(task.description),
                if (ref.watch(dependencyTasksProvider(task.id)).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Dependencies',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ref.watch(dependencyTasksProvider(task.id)).map((
                      dep,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dep.title,
                                style: TextStyle(
                                  decoration: dep.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (task.timeTrackingEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Time Tracking History',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...task.timeTrackingEntries.entries.map((entry) {
                    final date = DateTime.parse(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd, HH:mm').format(date)),
                          Text(_formatDuration(entry.value)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditTaskDialog(context, ref);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) =>
          TaskForm(initialColumnId: task.columnId, existingTask: task),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              ref
                  .read(taskColumnsProvider.notifier)
                  .removeTaskFromColumn(task.columnId, task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDependenciesDialog(BuildContext context, WidgetRef ref) {
    final allTasks = ref.read(tasksProvider);
    final availableTasks = allTasks
        .where((t) => t.id != task.id && !task.dependencyIds.contains(t.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manage Dependencies'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Dependencies:'),
                const SizedBox(height: 8),
                if (task.dependencyIds.isEmpty)
                  const Text(
                    'No dependencies set',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ...ref.watch(dependencyTasksProvider(task.id)).map((dep) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(dep.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(tasksProvider.notifier)
                            .removeDependency(task.id, dep.id);
                        Navigator.pop(context);
                        _showDependenciesDialog(context, ref);
                      },
                    ),
                  );
                }),
                const Divider(),
                const Text('Add Dependency:'),
                const SizedBox(height: 8),
                if (availableTasks.isEmpty)
                  const Text(
                    'No available tasks to add',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ...availableTasks.map((t) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        ref
                            .read(tasksProvider.notifier)
                            .addDependency(task.id, t.id);
                        Navigator.pop(context);
                        _showDependenciesDialog(context, ref);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class TaskForm extends ConsumerWidget {
  final String initialColumnId;
  final Task? existingTask;

  const TaskForm({Key? key, required this.initialColumnId, this.existingTask})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = ref.watch(taskColumnsProvider);

    final titleController = useTextEditingController(
      text: existingTask?.title ?? '',
    );
    final descriptionController = useTextEditingController(
      text: existingTask?.description ?? '',
    );

    final selectedColumnId = useState(
      existingTask?.columnId ?? initialColumnId,
    );
    final selectedPriority = useState(existingTask?.priority ?? 2);
    final selectedDueDate = useState<DateTime?>(existingTask?.dueDate);

    return AlertDialog(
      title: Text(existingTask == null ? 'Create Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Column',
                border: OutlineInputBorder(),
              ),
              value: selectedColumnId.value,
              items: columns.map((column) {
                return DropdownMenuItem(
                  value: column.id,
                  child: Text(column.title),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedColumnId.value = value;
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: selectedPriority.value,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Low')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedPriority.value = value;
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      selectedDueDate.value ??
                      DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (pickedDate != null) {
                  selectedDueDate.value = pickedDate;
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: selectedDueDate.value != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => selectedDueDate.value = null,
                        )
                      : const Icon(Icons.calendar_today),
                ),
                child: Text(
                  selectedDueDate.value != null
                      ? DateFormat(
                          'MMM dd, yyyy',
                        ).format(selectedDueDate.value!)
                      : 'Select a date',
                  style: TextStyle(
                    color: selectedDueDate.value != null
                        ? null
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title is required')),
              );
              return;
            }

            final tasksNotifier = ref.read(tasksProvider.notifier);
            final columnsNotifier = ref.read(taskColumnsProvider.notifier);

            if (existingTask == null) {
              // Creating a new task
              final newTask = Task(
                id: const Uuid().v4(),
                title: titleController.text,
                description: descriptionController.text,
                createdAt: DateTime.now(),
                dueDate: selectedDueDate.value,
                priority: selectedPriority.value,
                dependencyIds: const [],
                isCompleted: false,
                timeTrackingEntries: {},
                totalTimeSpent: Duration.zero,
                columnId: selectedColumnId.value,
              );

              tasksNotifier.addTask(newTask);
              columnsNotifier.addTaskToColumn(
                selectedColumnId.value,
                newTask.id,
              );
            } else {
              // Updating existing task
              final updatedTask = existingTask!.copyWith(
                title: titleController.text,
                description: descriptionController.text,
                dueDate: selectedDueDate.value,
                priority: selectedPriority.value,
              );

              tasksNotifier.updateTask(updatedTask);

              // If column changed, update the columns
              if (updatedTask.columnId != selectedColumnId.value) {
                columnsNotifier.removeTaskFromColumn(
                  updatedTask.columnId,
                  updatedTask.id,
                );
                columnsNotifier.addTaskToColumn(
                  selectedColumnId.value,
                  updatedTask.id,
                );
                tasksNotifier.moveTaskToColumn(
                  updatedTask.id,
                  selectedColumnId.value,
                );
              }
            }

            Navigator.pop(context);
          },
          child: Text(existingTask == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

// Main App
class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Task Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: const TaskBoard(),
      ),
    );
  }
}

void main() {
  runApp(const TaskManagementApp());
}
