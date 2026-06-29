import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_treeview/flutter_treeview.dart';

import 'task.dart';
import 'task_bloc.dart';

class GanttChart extends StatelessWidget {
  final List<Task> tasks;
  final DateTime startDate;
  final DateTime endDate;

  const GanttChart({super.key, required this.tasks, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /* Expanded(
          flex: 1,
          child: TreeView(
            nodes: _buildTreeNodes(tasks), controller: null,
          ),
        ), */
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1000, // Adjust width based on your need
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      ...List.generate(daysBetween(startDate, endDate), (index) {
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              startDate.add(Duration(days: index)).day.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  ...tasks.map((task) => _buildTaskRow(task)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* List<Node> _buildTreeNodes(List<Task> tasks) {
    return tasks.map((task) {
      return Node(
        label: task.name,
        key: task.id,
        children: _buildTreeNodes(task.subTasks),
      );
    }).toList();
  } */

  Widget _buildTaskRow(Task task) {
    int totalDays = daysBetween(startDate, endDate);
    int taskStart = daysBetween(startDate, task.startDate);
    int taskDuration = daysBetween(task.startDate, task.endDate);

    return Row(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(task.name),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 40,
              ),
              Positioned(
                left: (taskStart / totalDays) * 1000,
                child: Container(
                  width: (taskDuration / totalDays) * 1000,
                  height: 40,
                  color: task.color,
                  child: Center(
                    child: Text(
                      '${task.startDate.day}/${task.startDate.month} - ${task.endDate.day}/${task.endDate.month}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }
}


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gantt Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addTask(context,ref);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GanttChart(
          tasks: tasks,
          startDate: now.subtract(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 30)),
        ),
      ),
    );
  }

  void _addTask(BuildContext context,ref) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        DateTime startDate = DateTime.now();
        DateTime endDate = DateTime.now().add(const Duration(days: 7));
        final colorController = TextEditingController();
        final predecessorsController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final pickedStart = await _selectDate(context, startDate);
                    if (pickedStart != null) {
                      startDate = pickedStart;
                    }
                  },
                  child: const Text('Select Start Date'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedEnd = await _selectDate(context, endDate);
                    if (pickedEnd != null) {
                      endDate = pickedEnd;
                    }
                  },
                  child: const Text('Select End Date'),
                ),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color (Hex)'),
                ),
                TextField(
                  controller: predecessorsController,
                  decoration: const InputDecoration(labelText: 'Predecessors (comma-separated IDs)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final color = colorController.text.isNotEmpty
                    ? Color(int.parse(colorController.text, radix: 16))
                    : Colors.blue;

                final task = Task(
                  id: DateTime.now().toIso8601String(),
                  name: nameController.text,
                  startDate: startDate,
                  endDate: endDate,
                  color: color,
                  predecessors: predecessorsController.text.split(',').map((e) => e.trim()).toList(),
                );
                ref.read(taskProvider.notifier).addTask(task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
