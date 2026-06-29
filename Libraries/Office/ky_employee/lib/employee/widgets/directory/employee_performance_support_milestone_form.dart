import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_performance_support_models.dart';

class EmployeePerformanceSupportMilestoneForm extends StatelessWidget {
  final EmployeePerformanceSupportMilestoneDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController metricController;
  final TextEditingController notesController;
  final ValueChanged<EmployeePerformanceMilestoneType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<EmployeePerformanceSupportRisk> onRiskChanged;
  final ValueChanged<String> onMetricChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onAdd;

  const EmployeePerformanceSupportMilestoneForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.metricController,
    required this.notesController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onRiskChanged,
    required this.onMetricChanged,
    required this.onNotesChanged,
    required this.onSelectDueDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeePerformanceMilestoneType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Milestone type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                EmployeePerformanceMilestoneType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Milestone title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Milestone owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeePerformanceSupportRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeePerformanceSupportRisk.values
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
          _DueDateField(draft: draft, onTap: onSelectDueDate),
          const SizedBox(height: 12),
          TextField(
            controller: metricController,
            decoration: const InputDecoration(
              labelText: 'Success metric',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.checklist_outlined),
            ),
            onChanged: onMetricChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Milestone notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNotesChanged,
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
                label: const Text('Add milestone'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  final EmployeePerformanceSupportMilestoneDraft draft;
  final VoidCallback onTap;

  const _DueDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Milestone due date',
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
