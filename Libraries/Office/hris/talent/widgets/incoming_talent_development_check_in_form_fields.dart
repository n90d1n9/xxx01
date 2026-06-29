import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_check_in_models.dart';

class IncomingTalentDevelopmentCheckInTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentCheckInTextInput({
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

class IncomingTalentDevelopmentCheckInDateFields extends StatelessWidget {
  final IncomingTalentDevelopmentCheckInDraft draft;
  final VoidCallback onSelectCheckInDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentDevelopmentCheckInDateFields({
    super.key,
    required this.draft,
    required this.onSelectCheckInDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final checkInField = _CheckInDateField(
      label: 'Check-in date',
      icon: Icons.event_available_outlined,
      value: draft.checkInDate,
      error: IncomingTalentDevelopmentCheckInDraft.validateCheckInDate(
        draft.checkInDate,
        draft.asOfDate,
      ),
      onTap: onSelectCheckInDate,
    );
    final reviewField = _CheckInDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: IncomingTalentDevelopmentCheckInDraft.validateNextReviewDate(
        draft.checkInDate,
        draft.nextReviewDate,
      ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [checkInField, const SizedBox(height: 12), reviewField],
          );
        }

        return Row(
          children: [
            Expanded(child: checkInField),
            const SizedBox(width: 12),
            Expanded(child: reviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentCheckInTrendFields extends StatelessWidget {
  final IncomingTalentDevelopmentCheckInDraft draft;
  final ValueChanged<IncomingTalentDevelopmentCheckInTrend> onTrendChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentDevelopmentCheckInTrendFields({
    super.key,
    required this.draft,
    required this.onTrendChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final trendField =
        DropdownButtonFormField<IncomingTalentDevelopmentCheckInTrend>(
          initialValue: draft.trend,
          decoration: const InputDecoration(
            labelText: 'Progress trend',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up_outlined),
          ),
          items:
              IncomingTalentDevelopmentCheckInTrend.values
                  .map(
                    (trend) => DropdownMenuItem(
                      value: trend,
                      child: Text(trend.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTrendChanged(value);
          },
          validator: IncomingTalentDevelopmentCheckInDraft.validateTrend,
        );
    final confidenceField = _ConfidenceScoreField(
      draft: draft,
      onChanged: onConfidenceChanged,
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

class IncomingTalentDevelopmentCheckInDraftReadiness extends StatelessWidget {
  final IncomingTalentDevelopmentCheckInDraft draft;

  const IncomingTalentDevelopmentCheckInDraftReadiness({
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

class _ConfidenceScoreField extends StatelessWidget {
  final IncomingTalentDevelopmentCheckInDraft draft;
  final ValueChanged<int> onChanged;

  const _ConfidenceScoreField({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final safeValue = draft.confidenceScore.clamp(1, 5);

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Confidence score',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      child: Row(
        children: [
          Text(
            '$safeValue/5',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: safeValue.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$safeValue/5',
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
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
