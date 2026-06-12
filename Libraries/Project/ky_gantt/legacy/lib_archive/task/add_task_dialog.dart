// Add Task Dialog
import 'package:flutter/material.dart';

import 'task.dart';

class AddTaskDialog extends StatefulWidget {
  final Task task;
  final void Function()? onPressed;
  const AddTaskDialog({super.key, required this.task, this.onPressed});

  @override
  AddTaskDialogState createState() => AddTaskDialogState();
}

class AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedParentId;
  String? _selectedAssigneeId;

/* GanttTask(
        id: const Uuid().v4(),
        name: '_nameController.text',
        startDate:  DateTime.now(),
        endDate: DateTime.now(),
        assigneeId:   '',
        assigneeName: 'Assignee Name',
        assigneeAvatar: 'https://placeholder.com/avatar.jpg',
        parentId: _selectedParentId,
      ) */

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a task name' : null,
            ),
            // Add more form fields for dates, assignee, etc.
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.onPressed, //_submitForm()
          child: const Text('Add'),
        ),
      ],
    );
  }

  /* void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final ganttState = context.read<GanttState>();
      
      ganttState.addTask(widget.task);
      Navigator.pop(context);
    }
  } */

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
