import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionActivationCheckInTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionActivationCheckInTextInput({
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

class IncomingTalentSuccessionActivationCheckInSignalFields
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationCheckInDraft draft;
  final ValueChanged<IncomingTalentSuccessionActivationCheckInTrend>
  onTrendChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentSuccessionActivationCheckInSignalFields({
    super.key,
    required this.draft,
    required this.onTrendChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final trendField = DropdownButtonFormField<
      IncomingTalentSuccessionActivationCheckInTrend
    >(
      initialValue: draft.trend,
      decoration: const InputDecoration(
        labelText: 'Trend',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.trending_up_outlined),
      ),
      items:
          IncomingTalentSuccessionActivationCheckInTrend.values
              .map(
                (trend) =>
                    DropdownMenuItem(value: trend, child: Text(trend.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onTrendChanged(value);
      },
      validator: IncomingTalentSuccessionActivationCheckInDraft.validateTrend,
    );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.confidenceScore >= 1 && draft.confidenceScore <= 5
              ? draft.confidenceScore
              : null,
      decoration: const InputDecoration(
        labelText: 'Confidence',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onConfidenceChanged(value);
      },
      validator:
          (value) =>
              IncomingTalentSuccessionActivationCheckInDraft.validateConfidenceScore(
                value ?? 0,
              ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [trendField, const SizedBox(height: 12), confidenceField],
          );
        }
        return Row(
          children: [
            Expanded(child: trendField),
            const SizedBox(width: 12),
            Expanded(child: confidenceField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionActivationCheckInDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationCheckInDraft draft;
  final VoidCallback onSelectCheckInDate;
  final VoidCallback onSelectNextCheckInDate;

  const IncomingTalentSuccessionActivationCheckInDateFields({
    super.key,
    required this.draft,
    required this.onSelectCheckInDate,
    required this.onSelectNextCheckInDate,
  });

  @override
  Widget build(BuildContext context) {
    final checkInField = _ActivationCheckInDateField(
      label: 'Check-in date',
      icon: Icons.event_available_outlined,
      value: draft.checkInDate,
      error: IncomingTalentSuccessionActivationCheckInDraft.validateCheckInDate(
        draft.checkInDate,
        draft.asOfDate,
      ),
      onTap: onSelectCheckInDate,
    );
    final nextField = _ActivationCheckInDateField(
      label: 'Next check-in',
      icon: Icons.update_outlined,
      value: draft.nextCheckInDate,
      error:
          IncomingTalentSuccessionActivationCheckInDraft.validateNextCheckInDate(
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

class IncomingTalentSuccessionActivationCheckInDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationCheckInDraft draft;

  const IncomingTalentSuccessionActivationCheckInDraftReadiness({
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

class _ActivationCheckInDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ActivationCheckInDateField({
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
