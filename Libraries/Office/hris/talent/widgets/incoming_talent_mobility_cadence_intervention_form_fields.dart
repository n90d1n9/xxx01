import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceInterventionTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityCadenceInterventionTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
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

class IncomingTalentMobilityCadenceInterventionSignalFields
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionDraft draft;
  final ValueChanged<IncomingTalentMobilityCadenceInterventionType>
  onTypeChanged;
  final ValueChanged<IncomingTalentMobilityCadenceInterventionPriority>
  onPriorityChanged;
  final ValueChanged<IncomingTalentMobilityCadenceInterventionStatus>
  onStatusChanged;

  const IncomingTalentMobilityCadenceInterventionSignalFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeField =
        DropdownButtonFormField<IncomingTalentMobilityCadenceInterventionType>(
          initialValue: draft.interventionType,
          decoration: const InputDecoration(
            labelText: 'Intervention type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tune_outlined),
          ),
          items:
              IncomingTalentMobilityCadenceInterventionType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator:
              IncomingTalentMobilityCadenceInterventionDraft
                  .validateInterventionType,
        );
    final priorityField = DropdownButtonFormField<
      IncomingTalentMobilityCadenceInterventionPriority
    >(
      initialValue: draft.priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high_outlined),
      ),
      items:
          IncomingTalentMobilityCadenceInterventionPriority.values
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
      validator:
          IncomingTalentMobilityCadenceInterventionDraft.validatePriority,
    );
    final statusField = DropdownButtonFormField<
      IncomingTalentMobilityCadenceInterventionStatus
    >(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.track_changes_outlined),
      ),
      items:
          IncomingTalentMobilityCadenceInterventionStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
      validator: IncomingTalentMobilityCadenceInterventionDraft.validateStatus,
    );

    return _ResponsiveFields(children: [typeField, priorityField, statusField]);
  }
}

class IncomingTalentMobilityCadenceInterventionDueDateField
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionDraft draft;
  final VoidCallback onSelectDueDate;

  const IncomingTalentMobilityCadenceInterventionDueDateField({
    super.key,
    required this.draft,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectDueDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText:
              IncomingTalentMobilityCadenceInterventionDraft.validateDueDate(
                draft.dueDate,
                draft.asOfDate,
              ),
        ),
        child: Text(
          draft.dueDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.dueDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.dueDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                children[index],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}
