import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_activity_models.dart';
import '../../models/employee_action_workflow_models.dart';
import 'employee_action_activity_styles.dart';

class EmployeeActionActivityForm extends StatelessWidget {
  final EmployeeActionActivityDraft draft;
  final List<EmployeeActionTask> tasks;
  final TextEditingController authorController;
  final TextEditingController bodyController;
  final ValueChanged<String> onTaskChanged;
  final ValueChanged<String> onAuthorChanged;
  final ValueChanged<String> onBodyChanged;
  final ValueChanged<EmployeeActionActivityType> onTypeChanged;
  final ValueChanged<EmployeeActionActivityVisibility> onVisibilityChanged;
  final VoidCallback onSubmit;

  const EmployeeActionActivityForm({
    super.key,
    required this.draft,
    required this.tasks,
    required this.authorController,
    required this.bodyController,
    required this.onTaskChanged,
    required this.onAuthorChanged,
    required this.onBodyChanged,
    required this.onTypeChanged,
    required this.onVisibilityChanged,
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
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _TaskPicker(
                      draft: draft,
                      tasks: tasks,
                      onChanged: onTaskChanged,
                    ),
                    const SizedBox(height: 12),
                    _authorField(),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _TaskPicker(
                      draft: draft,
                      tasks: tasks,
                      onChanged: onTaskChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _authorField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyController,
            minLines: 2,
            maxLines: 4,
            onChanged: onBodyChanged,
            decoration: const InputDecoration(
              labelText: 'Activity update',
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
                width: 190,
                child: _TypePicker(draft: draft, onChanged: onTypeChanged),
              ),
              SegmentedButton<EmployeeActionActivityVisibility>(
                showSelectedIcon: false,
                segments:
                    EmployeeActionActivityVisibility.values
                        .map(
                          (visibility) => ButtonSegment(
                            value: visibility,
                            icon: Icon(
                              visibility ==
                                      EmployeeActionActivityVisibility.private
                                  ? Icons.lock_outline
                                  : Icons.groups_outlined,
                              size: 16,
                            ),
                            label: Text(visibility.label),
                          ),
                        )
                        .toList(),
                selected: {draft.visibility},
                onSelectionChanged:
                    (selection) => onVisibilityChanged(selection.single),
              ),
              FilledButton.icon(
                onPressed: draft.isReadyToAdd ? onSubmit : null,
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('Add update'),
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

  Widget _authorField() {
    return TextField(
      controller: authorController,
      onChanged: onAuthorChanged,
      decoration: const InputDecoration(
        labelText: 'Author',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _TaskPicker extends StatelessWidget {
  final EmployeeActionActivityDraft draft;
  final List<EmployeeActionTask> tasks;
  final ValueChanged<String> onChanged;

  const _TaskPicker({
    required this.draft,
    required this.tasks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTaskId =
        tasks.any((task) => task.id == draft.taskId) ? draft.taskId : null;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Workflow task',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTaskId,
          isExpanded: true,
          hint: const Text('Select task'),
          items:
              tasks
                  .map(
                    (task) => DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  final EmployeeActionActivityDraft draft;
  final ValueChanged<EmployeeActionActivityType> onChanged;

  const _TypePicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EmployeeActionActivityType>(
          value: draft.type,
          isExpanded: true,
          items:
              EmployeeActionActivityType.values
                  .where((type) => type != EmployeeActionActivityType.system)
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            employeeActionActivityTypeIcon(type),
                            size: 16,
                            color: employeeActionActivityTypeColor(type),
                          ),
                          const SizedBox(width: 8),
                          Text(type.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
