import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_timeline_models.dart';

class EmployeeTimelineEntryForm extends StatelessWidget {
  final EmployeeTimelineDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController detailController;
  final ValueChanged<EmployeeTimelineEventType> onTypeChanged;
  final ValueChanged<EmployeeTimelinePriority> onPriorityChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onDetailChanged;
  final ValueChanged<bool> onPinnedChanged;
  final VoidCallback onSelectOccurredAt;
  final VoidCallback onSelectDueAt;
  final VoidCallback onClearDueAt;
  final VoidCallback onSubmit;

  const EmployeeTimelineEntryForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.detailController,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onDetailChanged,
    required this.onPinnedChanged,
    required this.onSelectOccurredAt,
    required this.onSelectDueAt,
    required this.onClearDueAt,
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
                child: DropdownButtonFormField<EmployeeTimelineEventType>(
                  initialValue: draft.type,
                  decoration: const InputDecoration(
                    labelText: 'Event type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timeline_outlined),
                  ),
                  items:
                      EmployeeTimelineEventType.values
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
                child: DropdownButtonFormField<EmployeeTimelinePriority>(
                  initialValue: draft.priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items:
                      EmployeeTimelinePriority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onPriorityChanged(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimelineTextField(
            controller: titleController,
            label: 'Title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimelineDateField(
                  label: 'Event date',
                  date: draft.occurredAt,
                  onTap: onSelectOccurredAt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimelineDateField(
                  label: 'Follow-up',
                  date: draft.dueAt,
                  onTap: onSelectDueAt,
                  onClear: onClearDueAt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimelineTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.person_outline,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _TimelineTextField(
            controller: detailController,
            label: 'Detail',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onDetailChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pin to profile overview',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch.adaptive(value: draft.pinned, onChanged: onPinnedChanged),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
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
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add timeline entry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _TimelineDateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
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
          suffixIcon:
              date == null || onClear == null
                  ? null
                  : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_outlined),
                  ),
        ),
        child: Text(
          date == null ? 'None' : DateFormat('MMM d, yyyy').format(date!),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _TimelineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _TimelineTextField({
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
