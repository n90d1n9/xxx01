import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_relations_models.dart';

class EmployeeRelationsEventForm extends StatelessWidget {
  final EmployeeRelationsEventDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController summaryController;
  final ValueChanged<EmployeeRelationsEventType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onSummaryChanged;
  final ValueChanged<EmployeeRelationsSeverity> onSeverityChanged;
  final ValueChanged<EmployeeRelationsVisibility> onVisibilityChanged;
  final VoidCallback onSelectOccurredAt;
  final VoidCallback onSelectFollowUpDate;
  final VoidCallback onSubmit;

  const EmployeeRelationsEventForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.summaryController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onSummaryChanged,
    required this.onSeverityChanged,
    required this.onVisibilityChanged,
    required this.onSelectOccurredAt,
    required this.onSelectFollowUpDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<EmployeeRelationsEventType>(
                  initialValue: draft.type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Event type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items:
                      EmployeeRelationsEventType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onTypeChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<EmployeeRelationsVisibility>(
                  initialValue: draft.visibility,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Visibility',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.visibility_outlined),
                  ),
                  items:
                      EmployeeRelationsVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(
                                visibility.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onVisibilityChanged(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RelationsDateField(
                  label: 'Occurred',
                  date: draft.occurredAt,
                  onTap: onSelectOccurredAt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RelationsDateField(
                  label: 'Follow-up',
                  date: draft.followUpDate,
                  onTap: onSelectFollowUpDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeRelationsSeverity>(
            initialValue: draft.severity,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Severity',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeRelationsSeverity.values
                    .map(
                      (severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onSeverityChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _RelationsTextField(
            controller: titleController,
            label: 'Event title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _RelationsTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.person_outline,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _RelationsTextField(
            controller: summaryController,
            label: 'Summary',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onSummaryChanged,
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToAdd ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Record event'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationsDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _RelationsDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _RelationsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _RelationsTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
