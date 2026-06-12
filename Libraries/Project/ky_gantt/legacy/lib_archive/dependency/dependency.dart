
// Dialog for selecting dependent tasks
import 'package:flutter/material.dart';

import '../task/task.dart';

class DependencySelectionDialog extends StatefulWidget {
  final Task currentTask;
  final Function(Task) onDependencyAdded;

  const DependencySelectionDialog({
    super.key,
    required this.currentTask,
    required this.onDependencyAdded,
  });

  @override
  DependencySelectionDialogState createState() => DependencySelectionDialogState();
}

class DependencySelectionDialogState extends State<DependencySelectionDialog> {
  Task? _selectedDependentTask;
  List<Task> _availableTasks = []; // Populate this with your existing tasks

  @override
  void initState() {
    super.initState();
    // TODO: Load available tasks that can be dependencies
    // This might come from a state management solution or database
    _loadAvailableTasks();
  }

  void _loadAvailableTasks() {
    // Example of loading tasks
    // In a real app, this would come from your data source
    setState(() {
      _availableTasks = [
        Task(
          title: 'Design Phase',
          description: 'Initial project design',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 7)),
        ),
        Task(
          title: 'Research Phase',
          description: 'Preliminary research',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 5)),
        ),
        // Add more tasks
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Dependency for "${widget.currentTask.title}"'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Select a task that this task depends on:'),
            DropdownButton<Task>(
              isExpanded: true,
              value: _selectedDependentTask,
              hint: const Text('Select Dependent Task'),
              onChanged: (Task? newValue) {
                setState(() {
                  _selectedDependentTask = newValue;
                });
              },
              items: _availableTasks
                  .where((task) => task.title != widget.currentTask.title)
                  .map<DropdownMenuItem<Task>>((Task task) {
                return DropdownMenuItem<Task>(
                  value: task,
                  child: Text(task.title),
                );
              }).toList(),
            ),
            if (_selectedDependentTask != null) ...[
              const SizedBox(height: 16),
              Text('Selected Dependency: ${_selectedDependentTask!.title}'),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Add Dependency'),
          onPressed: _selectedDependentTask != null
              ? () {
                  widget.onDependencyAdded(_selectedDependentTask!);
                }
              : null,
        ),
      ],
    );
  }
}