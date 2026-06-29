import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../color_option.dart';

class TaskEdit extends StatelessWidget {
  final Task task;
  final List<Task> tasksData;
  final void Function(Task? updatedTask) onPressed;
  const TaskEdit({
    super.key,
    required this.task,
    required this.onPressed,
    required this.tasksData,
  });

  @override
  Widget build(BuildContext context) {
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

    return AlertDialog(
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
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                                    ColorOption(
                                      color: Colors.blue,
                                      onSelect: () {
                                        taskColor = Colors.blue;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.green,
                                      onSelect: () {
                                        taskColor = Colors.green;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.orange,
                                      onSelect: () {
                                        taskColor = Colors.orange;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.purple,
                                      onSelect: () {
                                        taskColor = Colors.purple;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.red,
                                      onSelect: () {
                                        taskColor = Colors.red;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.teal,
                                      onSelect: () {
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
                onPressed(updatedTask);
                //ref.read(tasksProvider.notifier).updateTask(updatedTask);
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Update Task'),
        ),
      ],
    );
  }
}
