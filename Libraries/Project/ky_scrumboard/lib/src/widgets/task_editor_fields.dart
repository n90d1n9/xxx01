import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';
import 'task_editor_validation.dart';

/// Title and description fields for the task editor form.
class TaskEditorTextSection extends StatelessWidget {
  const TaskEditorTextSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: requiredTaskEditorText,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descriptionController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Description'),
          validator: requiredTaskEditorText,
        ),
      ],
    );
  }
}

/// Preview for core task-editor text fields.
@Preview(group: 'Ky Scrumboard', name: 'Task editor text', size: Size(620, 240))
Widget taskEditorTextSectionPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 560,
          child: TaskEditorTextSection(
            titleController: TextEditingController(
              text: 'Checkout readiness review',
            ),
            descriptionController: TextEditingController(
              text: 'Validate payment copy and final release signals.',
            ),
          ),
        ),
      ),
    ),
  );
}

/// Metadata fields for ownership, estimate, label, and optional due date.
class TaskEditorMetadataSection extends StatelessWidget {
  const TaskEditorMetadataSection({
    super.key,
    required this.assigneeController,
    required this.estimateController,
    required this.labelController,
    required this.dueDateController,
  });

  final TextEditingController assigneeController;
  final TextEditingController estimateController;
  final TextEditingController labelController;
  final TextEditingController dueDateController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final ownershipFields = [
          TextFormField(
            controller: assigneeController,
            decoration: const InputDecoration(labelText: 'Assignee'),
            validator: requiredTaskEditorText,
          ),
          TextFormField(
            controller: estimateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Estimate'),
            validator: validateTaskEditorEstimate,
          ),
        ];
        final planningFields = [
          TextFormField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
          TextFormField(
            controller: dueDateController,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Due date',
              hintText: 'YYYY-MM-DD',
              prefixIcon: Icon(Icons.event_rounded),
            ),
            validator: validateTaskEditorDueDate,
          ),
        ];

        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ownershipFields[0],
              const SizedBox(height: 14),
              ownershipFields[1],
              const SizedBox(height: 14),
              planningFields[0],
              const SizedBox(height: 14),
              planningFields[1],
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: ownershipFields[0]),
                const SizedBox(width: 14),
                Expanded(child: ownershipFields[1]),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: planningFields[0]),
                const SizedBox(width: 14),
                Expanded(child: planningFields[1]),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Preview for task ownership and planning fields.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task editor metadata',
  size: Size(620, 180),
)
Widget taskEditorMetadataSectionPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 560,
          child: TaskEditorMetadataSection(
            assigneeController: TextEditingController(text: 'Alya'),
            estimateController: TextEditingController(text: '5'),
            labelController: TextEditingController(text: 'Payments'),
            dueDateController: TextEditingController(text: '2026-01-12'),
          ),
        ),
      ),
    ),
  );
}
