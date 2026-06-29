import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../color_option.dart';

class SubTaskAdd extends StatelessWidget {
  final Task parentTask;

  final void Function(Task? updatedTask) onPressed;
  const SubTaskAdd({
    super.key,
    required this.parentTask,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final taskTitleController = TextEditingController();
    final startDateController = TextEditingController();

    final endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    Color taskColor = parentTask.color;
    return AlertDialog(
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
                                    ColorOption(
                                      color: Colors.blue.shade300,
                                      onSelect: () {
                                        taskColor = Colors.blue.shade300;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.green.shade300,
                                      onSelect: () {
                                        taskColor = Colors.green.shade300;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.orange.shade300,
                                      onSelect: () {
                                        taskColor = Colors.orange.shade300;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.purple.shade300,
                                      onSelect: () {
                                        taskColor = Colors.purple.shade300;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.red.shade300,
                                      onSelect: () {
                                        taskColor = Colors.red.shade300;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ColorOption(
                                      color: Colors.teal.shade300,
                                      onSelect: () {
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
                onPressed(updatedTask);
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Add Subtask'),
        ),
      ],
    );
  }
}
