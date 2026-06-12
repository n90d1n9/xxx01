import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionBenchReplenishmentTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionBenchReplenishmentTextInput({
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

class IncomingTalentSuccessionBenchReplenishmentControlFields
    extends StatelessWidget {
  final IncomingTalentSuccessionBenchReplenishmentDraft draft;
  final ValueChanged<IncomingTalentSuccessionBenchReplenishmentPriority>
  onPriorityChanged;
  final VoidCallback onSelectTargetReadyDate;

  const IncomingTalentSuccessionBenchReplenishmentControlFields({
    super.key,
    required this.draft,
    required this.onPriorityChanged,
    required this.onSelectTargetReadyDate,
  });

  @override
  Widget build(BuildContext context) {
    final priorityField = DropdownButtonFormField<
      IncomingTalentSuccessionBenchReplenishmentPriority
    >(
      initialValue: draft.priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high_outlined),
      ),
      items:
          IncomingTalentSuccessionBenchReplenishmentPriority.values
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
          IncomingTalentSuccessionBenchReplenishmentDraft.validatePriority,
    );
    final targetDateField = _BenchTargetDateField(
      draft: draft,
      onSelectTargetReadyDate: onSelectTargetReadyDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              priorityField,
              const SizedBox(height: 12),
              targetDateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: priorityField),
            const SizedBox(width: 12),
            Expanded(child: targetDateField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionBenchReplenishmentDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionBenchReplenishmentDraft draft;

  const IncomingTalentSuccessionBenchReplenishmentDraftReadiness({
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

class _BenchTargetDateField extends StatelessWidget {
  final IncomingTalentSuccessionBenchReplenishmentDraft draft;
  final VoidCallback onSelectTargetReadyDate;

  const _BenchTargetDateField({
    required this.draft,
    required this.onSelectTargetReadyDate,
  });

  @override
  Widget build(BuildContext context) {
    final error =
        IncomingTalentSuccessionBenchReplenishmentDraft.validateTargetReadyDate(
          draft.targetReadyDate,
          draft.asOfDate,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectTargetReadyDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Target ready date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.targetReadyDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.targetReadyDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                draft.targetReadyDate == null
                    ? HrisColors.muted
                    : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
