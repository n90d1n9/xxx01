// Daily Tasks Page (Enhanced)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/daily_task.dart';
import '../states/daily_task_provider.dart';
import '../states/filter_task_provider.dart';

class DailyTasksPage extends ConsumerStatefulWidget {
  const DailyTasksPage({super.key});

  @override
  ConsumerState<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends ConsumerState<DailyTasksPage> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(filteredTasksProvider(_filter));
    final allTasks = ref.watch(dailyTasksProvider);
    final completedCount = allTasks.where((t) => t.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _filter = filter;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: TaskFilter.all,
                    child: Text('All Tasks'),
                  ),
                  const PopupMenuItem(
                    value: TaskFilter.active,
                    child: Text('Active'),
                  ),
                  const PopupMenuItem(
                    value: TaskFilter.completed,
                    child: Text('Completed'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: $completedCount/${allTasks.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (allTasks.isNotEmpty)
                  Text(
                    '${(completedCount / allTasks.length * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                tasks.isEmpty
                    ? Center(
                      child: Text(
                        _filter == TaskFilter.all
                            ? 'No tasks yet. Add one!'
                            : 'No ${_filter.name} tasks',
                      ),
                    )
                    : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            ref
                                .read(dailyTasksProvider.notifier)
                                .deleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${task.title} deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    ref
                                        .read(dailyTasksProvider.notifier)
                                        .updateTask(task);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.completed,
                                onChanged: (_) {
                                  ref
                                      .read(dailyTasksProvider.notifier)
                                      .toggleTask(task.id);
                                },
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        decoration:
                                            task.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                  ),
                                  _PriorityBadge(priority: task.priority),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(task.date),
                                  ),
                                  if (task.assignedTo != null)
                                    Text('Assigned to: ${task.assignedTo}'),
                                  if (task.notes != null) Text(task.notes!),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () =>
                                        _showEditTaskDialog(context, ref, task),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final notesController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    String? assignedTo;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Task'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Task name',
                          ),
                          autofocus: true,
                        ),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskPriority>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items:
                              TaskPriority.values
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              priority = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          ref
                              .read(dailyTasksProvider.notifier)
                              .addTask(controller.text, priority, assignedTo);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    DailyTask task,
  ) {
    final controller = TextEditingController(text: task.title);
    final notesController = TextEditingController(text: task.notes);
    TaskPriority priority = task.priority;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Task'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Task name',
                          ),
                        ),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(labelText: 'Notes'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskPriority>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items:
                              TaskPriority.values
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              priority = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          ref
                              .read(dailyTasksProvider.notifier)
                              .updateTask(
                                task.copyWith(
                                  title: controller.text,
                                  notes: notesController.text,
                                  priority: priority,
                                ),
                              );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
