import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task.dart';
import 'task_bloc.dart';


class GanttChartScreen extends ConsumerWidget {
  const GanttChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gantt Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTaskDialog(context, ref);
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, watch, child) {
          final tasks = ref.watch(taskProvider);
          return SingleChildScrollView(
            child: Column(
              children: tasks.map((task) => TaskRow(task: task)).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, ref) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Start Date (yyyy-MM-dd)'),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  startDate = DateTime.tryParse(value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'End Date (yyyy-MM-dd)'),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  endDate = DateTime.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty && startDate != null && endDate != null) {
                  final task = Task(
                    name: nameController.text,
                    startDate: startDate!,
                    endDate: endDate!, id: '', color: Colors.cyanAccent,
                  );
                  ref.read(taskProvider.notifier).addTask(task);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class TaskRow extends StatelessWidget {
  final Task task;

  const TaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final totalDays = DateTime.now().difference(DateTime(2000, 1, 1)).inDays;
    final startDay = task.startDate.difference(DateTime(2000, 1, 1)).inDays;
    final duration = task.endDate.difference(task.startDate).inDays;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [

Expanded(
            child: Text(task.name),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 20,
            child: Stack(
              children: [
                Positioned(
                  left: (startDay / totalDays) * MediaQuery.of(context).size.width * 0.6,
                  child: Container(
                    width: (duration / totalDays) * MediaQuery.of(context).size.width * 0.6,
                    color: Colors.blue,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
