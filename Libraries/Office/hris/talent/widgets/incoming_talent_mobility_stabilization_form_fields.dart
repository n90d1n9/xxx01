import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityStabilizationTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityStabilizationTextInput({
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

class IncomingTalentMobilityStabilizationActionFields extends StatelessWidget {
  final IncomingTalentMobilityStabilizationActionDraft draft;
  final ValueChanged<IncomingTalentMobilityStabilizationActionType>
  onActionTypeChanged;
  final ValueChanged<IncomingTalentMobilityStabilizationStatus> onStatusChanged;

  const IncomingTalentMobilityStabilizationActionFields({
    super.key,
    required this.draft,
    required this.onActionTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeField =
        DropdownButtonFormField<IncomingTalentMobilityStabilizationActionType>(
          initialValue: draft.actionType,
          decoration: const InputDecoration(
            labelText: 'Action type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tune_outlined),
          ),
          items:
              IncomingTalentMobilityStabilizationActionType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onActionTypeChanged(value);
          },
          validator:
              IncomingTalentMobilityStabilizationActionDraft.validateActionType,
        );
    final statusField = DropdownButtonFormField<
      IncomingTalentMobilityStabilizationStatus
    >(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.track_changes_outlined),
      ),
      items:
          IncomingTalentMobilityStabilizationStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
      validator: IncomingTalentMobilityStabilizationActionDraft.validateStatus,
    );

    return _ResponsivePair(left: typeField, right: statusField);
  }
}

class IncomingTalentMobilityStabilizationDueDateField extends StatelessWidget {
  final IncomingTalentMobilityStabilizationActionDraft draft;
  final VoidCallback onSelectDueDate;

  const IncomingTalentMobilityStabilizationDueDateField({
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
              IncomingTalentMobilityStabilizationActionDraft.validateDueDate(
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

class IncomingTalentMobilityStabilizationDraftReadiness
    extends StatelessWidget {
  final IncomingTalentMobilityStabilizationActionDraft draft;

  const IncomingTalentMobilityStabilizationDraftReadiness({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% complete',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ResponsivePair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }

        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
