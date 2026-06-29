import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_history_models.dart';

class EmployeeJobHistoryEventForm extends StatelessWidget {
  final EmployeeJobHistoryEventDraft draft;
  final TextEditingController titleController;
  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController ownerController;
  final TextEditingController noteController;
  final TextEditingController evidenceController;
  final ValueChanged<EmployeeJobHistoryEventType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final ValueChanged<EmployeeJobHistorySource> onSourceChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<String> onEvidenceChanged;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onAdd;

  const EmployeeJobHistoryEventForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.fromController,
    required this.toController,
    required this.ownerController,
    required this.noteController,
    required this.evidenceController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSourceChanged,
    required this.onOwnerChanged,
    required this.onNoteChanged,
    required this.onEvidenceChanged,
    required this.onSelectEffectiveDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeJobHistoryEventType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Event type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                EmployeeJobHistoryEventType.values
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
              labelText: 'Event title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fromController,
            decoration: const InputDecoration(
              labelText: 'Previous value',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.history_toggle_off_outlined),
            ),
            onChanged: onFromChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: toController,
            decoration: const InputDecoration(
              labelText: 'New value',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.arrow_forward_outlined),
            ),
            onChanged: onToChanged,
          ),
          const SizedBox(height: 12),
          _EffectiveDateField(draft: draft, onTap: onSelectEffectiveDate),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeJobHistorySource>(
            initialValue: draft.source,
            decoration: const InputDecoration(
              labelText: 'Source workflow',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            items:
                EmployeeJobHistorySource.values
                    .map(
                      (source) => DropdownMenuItem(
                        value: source,
                        child: Text(source.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onSourceChanged(value);
            },
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
          TextField(
            controller: evidenceController,
            decoration: const InputDecoration(
              labelText: 'Evidence reference',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
            onChanged: onEvidenceChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'History note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
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
                onPressed: draft.isReadyToAdd ? onAdd : null,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add history event'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EffectiveDateField extends StatelessWidget {
  final EmployeeJobHistoryEventDraft draft;
  final VoidCallback onTap;

  const _EffectiveDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = draft.effectiveDate;
    final label =
        date == null ? 'Select date' : DateFormat('MMM d, yyyy').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
