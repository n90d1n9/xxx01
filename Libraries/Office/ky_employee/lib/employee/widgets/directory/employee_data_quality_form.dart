import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_quality_models.dart';
import 'employee_data_quality_styles.dart';

class EmployeeDataQualityIssueForm extends StatelessWidget {
  final EmployeeDataQualityIssueDraft draft;
  final TextEditingController titleController;
  final TextEditingController fieldController;
  final TextEditingController ownerController;
  final TextEditingController detailController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onFieldChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onDetailChanged;
  final ValueChanged<EmployeeDataQualityIssueType> onTypeChanged;
  final ValueChanged<EmployeeDataQualitySeverity> onSeverityChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onAdd;

  const EmployeeDataQualityIssueForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.fieldController,
    required this.ownerController,
    required this.detailController,
    required this.onTitleChanged,
    required this.onFieldChanged,
    required this.onOwnerChanged,
    required this.onDetailChanged,
    required this.onTypeChanged,
    required this.onSeverityChanged,
    required this.onPickDueDate,
    required this.onAdd,
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
                    _titleField(),
                    const SizedBox(height: 12),
                    _fieldField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _titleField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _fieldField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _ownerField(),
                    const SizedBox(height: 12),
                    _TypePicker(draft: draft, onChanged: onTypeChanged),
                    const SizedBox(height: 12),
                    _SeverityPicker(draft: draft, onChanged: onSeverityChanged),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _ownerField()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypePicker(draft: draft, onChanged: onTypeChanged),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SeverityPicker(
                      draft: draft,
                      onChanged: onSeverityChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: detailController,
            minLines: 2,
            maxLines: 4,
            onChanged: onDetailChanged,
            decoration: const InputDecoration(
              labelText: 'Issue detail',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subject_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onPickDueDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(_dueDateLabel(draft.dueDate)),
              ),
              FilledButton.icon(
                onPressed: draft.isReadyToAdd ? onAdd : null,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add issue'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
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
        labelText: 'Issue title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rule_folder_outlined),
      ),
    );
  }

  Widget _fieldField() {
    return TextField(
      controller: fieldController,
      onChanged: onFieldChanged,
      decoration: const InputDecoration(
        labelText: 'Affected field',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.data_object_outlined),
      ),
    );
  }

  Widget _ownerField() {
    return TextField(
      controller: ownerController,
      onChanged: onOwnerChanged,
      decoration: const InputDecoration(
        labelText: 'Data owner',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  String _dueDateLabel(DateTime? date) {
    if (date == null) return 'Select due date';
    return 'Due ${DateFormat('MMM d, yyyy').format(date)}';
  }
}

class _TypePicker extends StatelessWidget {
  final EmployeeDataQualityIssueDraft draft;
  final ValueChanged<EmployeeDataQualityIssueType> onChanged;

  const _TypePicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeDataQualityIssueType>(
      initialValue: draft.type,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Issue type',
        border: OutlineInputBorder(),
      ),
      items:
          EmployeeDataQualityIssueType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(employeeDataQualityTypeIcon(type), size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _SeverityPicker extends StatelessWidget {
  final EmployeeDataQualityIssueDraft draft;
  final ValueChanged<EmployeeDataQualitySeverity> onChanged;

  const _SeverityPicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeDataQualitySeverity>(
      initialValue: draft.severity,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Severity',
        border: OutlineInputBorder(),
      ),
      items:
          EmployeeDataQualitySeverity.values
              .map(
                (severity) => DropdownMenuItem(
                  value: severity,
                  child: Row(
                    children: [
                      Icon(
                        Icons.priority_high_outlined,
                        size: 16,
                        color: employeeDataQualitySeverityColor(severity),
                      ),
                      const SizedBox(width: 8),
                      Text(severity.label),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
