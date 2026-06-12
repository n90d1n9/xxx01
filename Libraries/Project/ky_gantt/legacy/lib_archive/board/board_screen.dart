import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../task/task.dart';
import 'task_column.dart';
import 'task_provider.dart';
/* 
class ScrumBoardScreen extends ConsumerWidget {
  const ScrumBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrum Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/new-task'),
          ),
        ],
      ),
      body: Row(
        children: TaskStatus.values.map((status) {
          final columnTasks = tasks.where((task) => task.status == status).toList();
          return Expanded(
            child: TaskColumn(
              status: status,
              tasks: columnTasks,
            ),
          );
        }).toList(),
      ),
    );
  }
} */

class ScrumBoardScreen extends ConsumerWidget {
  const ScrumBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final tasks = ref.watch(filteredTasksProvider);

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrum Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/new-task'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          Expanded(
            child: Row(
              children: TaskStatus.values.map((status) {
                final columnTasks =
                    tasks.where((task) => task.status == status).toList();
                return Expanded(
                  child: TaskColumn(
                    status: status,
                    tasks: columnTasks,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context, WidgetRef ref) async {
    final currentFilter = ref.read(taskFilterProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskPriority>(
              value: currentFilter.priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) {
                ref.read(taskFilterProvider.notifier).state =
                    TaskFilter(priority: value);
              },
            ),
            // Add more filter options here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(taskFilterProvider.notifier).state = const TaskFilter();
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
