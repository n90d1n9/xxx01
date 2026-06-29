import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_case_log_models.dart';
import 'employee_case_log_styles.dart';

class EmployeeHrCaseIntakeForm extends StatelessWidget {
  final EmployeeHrCaseIntakeDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController summaryController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onSummaryChanged;
  final ValueChanged<EmployeeHrCaseType> onTypeChanged;
  final ValueChanged<EmployeeHrCasePriority> onPriorityChanged;
  final ValueChanged<EmployeeHrCaseConfidentiality> onConfidentialityChanged;
  final VoidCallback onPickFollowUp;
  final VoidCallback onCreate;

  const EmployeeHrCaseIntakeForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.summaryController,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onSummaryChanged,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onConfidentialityChanged,
    required this.onPickFollowUp,
    required this.onCreate,
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
                    _ownerField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _titleField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _ownerField()),
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
                    _TypePicker(draft: draft, onChanged: onTypeChanged),
                    const SizedBox(height: 12),
                    _PriorityPicker(draft: draft, onChanged: onPriorityChanged),
                    const SizedBox(height: 12),
                    _ConfidentialityPicker(
                      draft: draft,
                      onChanged: onConfidentialityChanged,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _TypePicker(draft: draft, onChanged: onTypeChanged),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriorityPicker(
                      draft: draft,
                      onChanged: onPriorityChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ConfidentialityPicker(
                      draft: draft,
                      onChanged: onConfidentialityChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: summaryController,
            minLines: 2,
            maxLines: 4,
            onChanged: onSummaryChanged,
            decoration: const InputDecoration(
              labelText: 'Case summary',
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
                onPressed: onPickFollowUp,
                icon: const Icon(Icons.event_repeat_outlined),
                label: Text(_followUpLabel(draft.followUpDate)),
              ),
              FilledButton.icon(
                onPressed: draft.isReadyToCreate ? onCreate : null,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('Create case'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToCreate
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
        labelText: 'Case title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder_shared_outlined),
      ),
    );
  }

  Widget _ownerField() {
    return TextField(
      controller: ownerController,
      onChanged: onOwnerChanged,
      decoration: const InputDecoration(
        labelText: 'Case owner',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  String _followUpLabel(DateTime? date) {
    if (date == null) return 'Select follow-up';
    return 'Follow-up ${DateFormat('MMM d, yyyy').format(date)}';
  }
}

class _TypePicker extends StatelessWidget {
  final EmployeeHrCaseIntakeDraft draft;
  final ValueChanged<EmployeeHrCaseType> onChanged;

  const _TypePicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeHrCaseType>(
      initialValue: draft.type,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Case type',
        border: OutlineInputBorder(),
      ),
      items:
          EmployeeHrCaseType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(employeeHrCaseTypeIcon(type), size: 16),
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

class _PriorityPicker extends StatelessWidget {
  final EmployeeHrCaseIntakeDraft draft;
  final ValueChanged<EmployeeHrCasePriority> onChanged;

  const _PriorityPicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeHrCasePriority>(
      initialValue: draft.priority,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items:
          EmployeeHrCasePriority.values
              .map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        Icons.priority_high_outlined,
                        size: 16,
                        color: employeeHrCasePriorityColor(priority),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.label),
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

class _ConfidentialityPicker extends StatelessWidget {
  final EmployeeHrCaseIntakeDraft draft;
  final ValueChanged<EmployeeHrCaseConfidentiality> onChanged;

  const _ConfidentialityPicker({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeHrCaseConfidentiality>(
      initialValue: draft.confidentiality,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Confidentiality',
        border: OutlineInputBorder(),
      ),
      items:
          EmployeeHrCaseConfidentiality.values
              .map(
                (confidentiality) => DropdownMenuItem(
                  value: confidentiality,
                  child: Row(
                    children: [
                      Icon(
                        employeeHrCaseConfidentialityIcon(confidentiality),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          confidentiality.label,
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
