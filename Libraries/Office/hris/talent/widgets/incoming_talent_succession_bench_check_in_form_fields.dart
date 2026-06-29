import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionBenchCheckInTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionBenchCheckInTextInput({
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

class IncomingTalentSuccessionBenchCheckInSignalFields extends StatelessWidget {
  final IncomingTalentSuccessionBenchCheckInDraft draft;
  final ValueChanged<IncomingTalentSuccessionBenchCheckInHealth>
  onHealthChanged;
  final ValueChanged<int> onSuccessorSlateChanged;
  final ValueChanged<int> onReadyNowChanged;
  final ValueChanged<int> onReadinessChanged;

  const IncomingTalentSuccessionBenchCheckInSignalFields({
    super.key,
    required this.draft,
    required this.onHealthChanged,
    required this.onSuccessorSlateChanged,
    required this.onReadyNowChanged,
    required this.onReadinessChanged,
  });

  @override
  Widget build(BuildContext context) {
    final healthField =
        DropdownButtonFormField<IncomingTalentSuccessionBenchCheckInHealth>(
          initialValue: draft.health,
          decoration: const InputDecoration(
            labelText: 'Bench health',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monitor_heart_outlined),
          ),
          items:
              IncomingTalentSuccessionBenchCheckInHealth.values
                  .map(
                    (health) => DropdownMenuItem(
                      value: health,
                      child: Text(health.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onHealthChanged(value);
          },
          validator: IncomingTalentSuccessionBenchCheckInDraft.validateHealth,
        );
    final slateField = _NumberField(
      label: 'Successor slate',
      value: draft.successorSlateCount,
      values: List<int>.generate(20, (index) => index + 1),
      onChanged: onSuccessorSlateChanged,
      validator:
          (value) =>
              IncomingTalentSuccessionBenchCheckInDraft.validateSuccessorSlateCount(
                value ?? 0,
              ),
    );
    final readyNowField = _NumberField(
      label: 'Ready now',
      value: draft.readyNowCount,
      values: List<int>.generate(
        draft.successorSlateCount + 1,
        (index) => index,
      ),
      onChanged: onReadyNowChanged,
      validator:
          (value) =>
              IncomingTalentSuccessionBenchCheckInDraft.validateReadyNowCount(
                value ?? -1,
                draft.successorSlateCount,
              ),
    );
    final readinessField = _NumberField(
      label: 'Readiness',
      value: draft.readinessScore,
      values: const [1, 2, 3, 4, 5],
      onChanged: onReadinessChanged,
      suffix: '/ 5',
      validator:
          (value) =>
              IncomingTalentSuccessionBenchCheckInDraft.validateReadinessScore(
                value ?? 0,
              ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              healthField,
              const SizedBox(height: 12),
              slateField,
              const SizedBox(height: 12),
              readyNowField,
              const SizedBox(height: 12),
              readinessField,
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: healthField),
                const SizedBox(width: 12),
                Expanded(child: readinessField),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: slateField),
                const SizedBox(width: 12),
                Expanded(child: readyNowField),
              ],
            ),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionBenchCheckInDateFields extends StatelessWidget {
  final IncomingTalentSuccessionBenchCheckInDraft draft;
  final VoidCallback onSelectCheckInDate;
  final VoidCallback onSelectNextCheckInDate;

  const IncomingTalentSuccessionBenchCheckInDateFields({
    super.key,
    required this.draft,
    required this.onSelectCheckInDate,
    required this.onSelectNextCheckInDate,
  });

  @override
  Widget build(BuildContext context) {
    final checkInField = _CheckInDateField(
      label: 'Check-in date',
      icon: Icons.event_available_outlined,
      value: draft.checkInDate,
      error: IncomingTalentSuccessionBenchCheckInDraft.validateCheckInDate(
        draft.checkInDate,
        draft.asOfDate,
      ),
      onTap: onSelectCheckInDate,
    );
    final nextField = _CheckInDateField(
      label: 'Next check-in',
      icon: Icons.update_outlined,
      value: draft.nextCheckInDate,
      error: IncomingTalentSuccessionBenchCheckInDraft.validateNextCheckInDate(
        draft.checkInDate,
        draft.nextCheckInDate,
      ),
      onTap: onSelectNextCheckInDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [checkInField, const SizedBox(height: 12), nextField],
          );
        }

        return Row(
          children: [
            Expanded(child: checkInField),
            const SizedBox(width: 12),
            Expanded(child: nextField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionBenchCheckInDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionBenchCheckInDraft draft;

  const IncomingTalentSuccessionBenchCheckInDraftReadiness({
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

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final List<int> values;
  final String suffix;
  final ValueChanged<int> onChanged;
  final String? Function(int?) validator;

  const _NumberField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.validator,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: values.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.speed_outlined),
      ),
      items:
          values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(suffix.isEmpty ? '$item' : '$item $suffix'),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: validator,
    );
  }
}

class _CheckInDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CheckInDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.error,
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
          prefixIcon: Icon(icon),
          errorText: error,
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
