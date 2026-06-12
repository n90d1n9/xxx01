import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_workflow_models.dart';
import '../../models/employee_next_action_models.dart';
import 'employee_next_action_styles.dart';

class EmployeeActionWorkflowForm extends StatelessWidget {
  final EmployeeActionTaskDraft draft;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController ownerController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<EmployeeNextActionArea> onAreaChanged;
  final ValueChanged<EmployeeNextActionPriority> onPriorityChanged;
  final ValueChanged<DateTime> onDueDateChanged;
  final VoidCallback onSubmit;

  const EmployeeActionWorkflowForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.descriptionController,
    required this.ownerController,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onOwnerChanged,
    required this.onAreaChanged,
    required this.onPriorityChanged,
    required this.onDueDateChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    _titleField(),
                    const SizedBox(height: 12),
                    _ownerField(),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 2, child: _titleField()),
                  const SizedBox(width: 12),
                  Expanded(child: _ownerField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 3,
            onChanged: onDescriptionChanged,
            decoration: const InputDecoration(
              labelText: 'Follow-up',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<EmployeeNextActionArea>(
                  initialValue: draft.area,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      EmployeeNextActionArea.values
                          .map(
                            (area) => DropdownMenuItem(
                              value: area,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    employeeNextActionAreaIcon(area),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(area.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onAreaChanged(value);
                  },
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<EmployeeNextActionPriority>(
                  initialValue: draft.priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      EmployeeNextActionPriority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onPriorityChanged(value);
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDueDate(context),
                icon: const Icon(Icons.event_outlined),
                label: Text(_dueDateLabel),
              ),
              FilledButton.icon(
                onPressed: draft.isReadyToAdd ? onSubmit : null,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add task'),
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  errors
                      .take(3)
                      .map(
                        (error) => HrisStatusPill(
                          label: error,
                          color: const Color(0xFFB45309),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleField() {
    return TextField(
      controller: titleController,
      onChanged: onTitleChanged,
      decoration: const InputDecoration(
        labelText: 'Task title',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _ownerField() {
    return TextField(
      controller: ownerController,
      onChanged: onOwnerChanged,
      decoration: const InputDecoration(
        labelText: 'Owner',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (selected != null) {
      onDueDateChanged(selected);
    }
  }

  String get _dueDateLabel {
    final dueDate = draft.dueDate;
    if (dueDate == null) return 'Due date';
    return 'Due ${DateFormat('MMM d, yyyy').format(dueDate)}';
  }
}
