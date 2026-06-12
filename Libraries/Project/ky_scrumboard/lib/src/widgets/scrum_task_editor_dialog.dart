import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'task_editor_accent_picker.dart';
import 'task_editor_fields.dart';
import 'task_editor_validation.dart';
import 'task_editor_workflow_fields.dart';

/// Opens a modal task editor and returns the created or updated task.
Future<ScrumTask?> showScrumTaskEditor(
  BuildContext context, {
  ScrumTask? task,
  ScrumTaskStatus initialStatus = ScrumTaskStatus.todo,
  List<ScrumTaskStatus> statuses = defaultEditorStatuses,
  String Function(ScrumTaskStatus status) statusLabelFor =
      defaultEditorStatusLabel,
}) {
  return showDialog<ScrumTask>(
    context: context,
    builder: (context) => ScrumTaskEditorDialog(
      task: task,
      initialStatus: initialStatus,
      statuses: statuses,
      statusLabelFor: statusLabelFor,
    ),
  );
}

/// Default board lanes offered by the task editor.
const defaultEditorStatuses = defaultTaskEditorStatuses;

/// Default label resolver for task editor lane fields.
String defaultEditorStatusLabel(ScrumTaskStatus status) => status.label;

/// Composed dialog for creating or editing a board task.
class ScrumTaskEditorDialog extends StatefulWidget {
  const ScrumTaskEditorDialog({
    super.key,
    this.task,
    required this.initialStatus,
    this.statuses = defaultEditorStatuses,
    this.statusLabelFor = defaultEditorStatusLabel,
  });

  final ScrumTask? task;
  final ScrumTaskStatus initialStatus;
  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;

  @override
  State<ScrumTaskEditorDialog> createState() => _ScrumTaskEditorDialogState();
}

class _ScrumTaskEditorDialogState extends State<ScrumTaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assigneeController;
  late final TextEditingController _storyPointsController;
  late final TextEditingController _labelController;
  late final TextEditingController _dueDateController;
  late final List<ScrumTaskStatus> _statuses;
  late ScrumTaskStatus _status;
  late ScrumTaskPriority _priority;
  late Color _accentColor;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _assigneeController = TextEditingController(text: task?.assignee ?? '');
    _storyPointsController = TextEditingController(
      text: task?.storyPoints.toString() ?? '3',
    );
    _labelController = TextEditingController(text: task?.label ?? '');
    _dueDateController = TextEditingController(
      text: formatTaskEditorDueDate(task?.dueAt),
    );
    _status = task?.status ?? widget.initialStatus;
    _statuses = normalizeTaskEditorStatuses(widget.statuses, _status);
    _priority = task?.priority ?? ScrumTaskPriority.medium;
    _accentColor = task?.accentColor ?? defaultTaskEditorAccentColors.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    _storyPointsController.dispose();
    _labelController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;

    return AlertDialog(
      title: Text(editing ? 'Edit task' : 'New task'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaskEditorTextSection(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 14),
                TaskEditorMetadataSection(
                  assigneeController: _assigneeController,
                  estimateController: _storyPointsController,
                  labelController: _labelController,
                  dueDateController: _dueDateController,
                ),
                const SizedBox(height: 14),
                TaskEditorWorkflowFields(
                  status: _status,
                  priority: _priority,
                  statuses: _statuses,
                  statusLabelFor: widget.statusLabelFor,
                  onStatusChanged: (status) => setState(() => _status = status),
                  onPriorityChanged: (priority) =>
                      setState(() => _priority = priority),
                ),
                const SizedBox(height: 18),
                TaskEditorAccentPicker(
                  colors: defaultTaskEditorAccentColors,
                  selectedColor: _accentColor,
                  onColorChanged: (color) =>
                      setState(() => _accentColor = color),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(editing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final task = widget.task;
    final label = _labelController.text.trim();
    Navigator.of(context).pop(
      ScrumTask(
        id: task?.id ?? newTaskEditorId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignee: _assigneeController.text.trim(),
        storyPoints: int.parse(_storyPointsController.text.trim()),
        createdAt: task?.createdAt ?? DateTime.now(),
        dueAt: parseTaskEditorDueDate(_dueDateController.text),
        status: _status,
        priority: _priority,
        label: label.isEmpty ? null : label,
        accentColor: _accentColor,
      ),
    );
  }
}

/// Preview for the composed task editor dialog.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task editor dialog',
  size: Size(680, 640),
)
Widget scrumTaskEditorDialogPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumTaskEditorDialog(initialStatus: ScrumTaskStatus.todo),
      ),
    ),
  );
}
