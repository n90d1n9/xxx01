// Enhanced Task Dialog
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../color/color_picker.dart';
import '../comment/comment_section.dart';
import '../date/datetime_picker.dart';
import '../attachment/attachment.dart';
import 'task.dart';
import '../milestone/priority_selector.dart';
import '../milestone/reminder_selector.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;

  final Task? initialTask;

  const TaskDialog(
      {super.key,
      this.task,
      this.initialTask,
      required Null Function(dynamic updatedTask) onTaskSaved});

  @override
  TaskDialogState createState() => TaskDialogState();
}

class TaskDialogState extends State<TaskDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late Color _selectedColor;
  late TaskPriority _priority;
  late bool _isMillestone;
  DateTime? _reminderDate;
  late TextEditingController _titleController;

  final List<TaskAttachment> _attachments = [];
  final List<TaskComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialTask?.description ?? '');
    _startDate = widget.initialTask?.startDate ?? DateTime.now();
    _endDate =
        widget.initialTask?.endDate ?? DateTime.now().add(Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            DateTimePicker(
              labelText: 'Start Date',
              selectedDate: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
            ),
            DateTimePicker(
              labelText: 'End Date',
              selectedDate: _endDate,
              onChanged: (date) => setState(() => _endDate = date),
            ),
            ColorPickerButton(
              color: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
            ),
            PrioritySelector(
              priority: _priority,
              onChanged: (priority) => setState(() => _priority = TaskPriority.low),
            ),
            SwitchListTile(
              title: const Text('Is Milestone'),
              value: _isMillestone,
              onChanged: (value) => setState(() => _isMillestone = value),
            ),
            ReminderSelector(
              reminderDate: _reminderDate,
              onChanged: (date) => setState(() => _reminderDate = date),
            ),
            /* AttachmentList(
              attachments: widget.task?.attachments ?? [],
              onAdd: _addAttachment,
              onRemove: _removeAttachment,
            ), */
            CommentSection(
              comments: widget.task?.comments ?? [],
              onAddComment: _addComment,
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
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Add attachment method
  Future<void> _addAttachment() async {
    // Use file_picker to select attachments
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null) {
      final attachment = TaskAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result.files.single.name,
        type: _getAttachmentType(result.files.single.extension ?? ''),
        url: result.files.single.path ?? '',
      );

      setState(() {
        _attachments.add(attachment);
      });
    }
  }

  // Remove attachment method
  void _removeAttachment(TaskAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
    });
  }

  // Add comment method
  void _addComment(String commentText) {
    if (commentText.trim().isNotEmpty) {
      final comment = TaskComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'Current User', // Replace with actual user
        content: commentText,
      );

      setState(() {
        _comments.add(comment);
      });
    }
  }

  // Save task method
  void _saveTask() {
    // Validate and save task
    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      attachments: _attachments,
      comments: _comments,
    );

    // Here you would typically call a method to save the task
    // to your state management or database
    Navigator.of(context).pop(task);
  }

  // Helper method to determine attachment type
  AttachmentType _getAttachmentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'png':
      case 'gif':
        return AttachmentType.image;
      case 'pdf':
      case 'doc':
      case 'docx':
        return AttachmentType.file;
      default:
        return AttachmentType.link;
    }
  }
}
