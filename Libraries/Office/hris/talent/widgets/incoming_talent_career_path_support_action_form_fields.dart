import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_support_action_models.dart';

class IncomingTalentCareerPathSupportActionTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentCareerPathSupportActionTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class IncomingTalentCareerPathSupportActionStatusFields
    extends StatelessWidget {
  final IncomingTalentCareerPathSupportActionDraft draft;
  final ValueChanged<IncomingTalentCareerPathSupportActionType> onTypeChanged;
  final ValueChanged<IncomingTalentCareerPathSupportActionPriority>
  onPriorityChanged;
  final ValueChanged<IncomingTalentCareerPathSupportActionStatus>
  onStatusChanged;

  const IncomingTalentCareerPathSupportActionStatusFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<IncomingTalentCareerPathSupportActionType>(
        initialValue: draft.actionType,
        decoration: const InputDecoration(
          labelText: 'Action type',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.build_circle_outlined),
        ),
        items:
            IncomingTalentCareerPathSupportActionType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) onTypeChanged(value);
        },
        validator: validateIncomingTalentCareerPathSupportActionType,
      ),
      DropdownButtonFormField<IncomingTalentCareerPathSupportActionPriority>(
        initialValue: draft.priority,
        decoration: const InputDecoration(
          labelText: 'Priority',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.priority_high_outlined),
        ),
        items:
            IncomingTalentCareerPathSupportActionPriority.values
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
        validator: validateIncomingTalentCareerPathSupportActionPriority,
      ),
      DropdownButtonFormField<IncomingTalentCareerPathSupportActionStatus>(
        initialValue: draft.status,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.flag_outlined),
        ),
        items:
            IncomingTalentCareerPathSupportActionStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) onStatusChanged(value);
        },
        validator: validateIncomingTalentCareerPathSupportActionStatus,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              Expanded(child: fields[index]),
              if (index < fields.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class IncomingTalentCareerPathSupportActionDueDateField
    extends StatelessWidget {
  final IncomingTalentCareerPathSupportActionDraft draft;
  final VoidCallback onTap;

  const IncomingTalentCareerPathSupportActionDueDateField({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = draft.dueDate;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: validateIncomingTalentCareerPathSupportActionDueDate(
            value,
            draft.asOfDate,
          ),
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
