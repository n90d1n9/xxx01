import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_exit_readiness_models.dart';

class EmployeeExitClearanceForm extends StatelessWidget {
  final EmployeeExitClearanceDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController noteController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<EmployeeExitClearanceCategory> onCategoryChanged;
  final ValueChanged<EmployeeExitRisk> onRiskChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onAdd;

  const EmployeeExitClearanceForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.noteController,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onCategoryChanged,
    required this.onRiskChanged,
    required this.onNoteChanged,
    required this.onSelectDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Clearance title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.playlist_add_check_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeExitClearanceCategory>(
            initialValue: draft.category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                EmployeeExitClearanceCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeExitRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeExitRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(risk.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _DueDateField(draft: draft, onTap: onSelectDate),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Clearance note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...errors.map(
              (error) => Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HrisProgressBar(
                  value: draft.completionRatio,
                  color:
                      draft.isReadyToAdd
                          ? const Color(0xFF15803D)
                          : HrisColors.primary,
                  label: '${(draft.completionRatio * 100).round()}% ready',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add clearance'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  final EmployeeExitClearanceDraft draft;
  final VoidCallback onTap;

  const _DueDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          draft.dueDate == null
              ? 'Select date'
              : DateFormat('MMM d, yyyy').format(draft.dueDate!),
        ),
      ),
    );
  }
}
