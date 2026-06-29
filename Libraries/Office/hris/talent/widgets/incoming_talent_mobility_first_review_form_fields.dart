import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityFirstReviewTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityFirstReviewTextInput({
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

class IncomingTalentMobilityFirstReviewSignalFields extends StatelessWidget {
  final IncomingTalentMobilityFirstReviewDraft draft;
  final ValueChanged<IncomingTalentMobilityFirstReviewOutcome> onOutcomeChanged;
  final ValueChanged<int> onConfidenceChanged;
  final ValueChanged<IncomingTalentMobilityFirstReviewRetentionRisk>
  onRetentionRiskChanged;

  const IncomingTalentMobilityFirstReviewSignalFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onConfidenceChanged,
    required this.onRetentionRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outcomeField =
        DropdownButtonFormField<IncomingTalentMobilityFirstReviewOutcome>(
          initialValue: draft.outcome,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up_outlined),
          ),
          items:
              IncomingTalentMobilityFirstReviewOutcome.values
                  .map(
                    (outcome) => DropdownMenuItem(
                      value: outcome,
                      child: Text(outcome.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onOutcomeChanged(value);
          },
          validator: IncomingTalentMobilityFirstReviewDraft.validateOutcome,
        );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.hostConfidenceScore >= 1 && draft.hostConfidenceScore <= 5
              ? draft.hostConfidenceScore
              : null,
      decoration: const InputDecoration(
        labelText: 'Host confidence',
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
              IncomingTalentMobilityFirstReviewDraft.validateHostConfidenceScore(
                value ?? 0,
              ),
    );
    final riskField =
        DropdownButtonFormField<IncomingTalentMobilityFirstReviewRetentionRisk>(
          initialValue: draft.retentionRisk,
          decoration: const InputDecoration(
            labelText: 'Retention risk',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shield_outlined),
          ),
          items:
              IncomingTalentMobilityFirstReviewRetentionRisk.values
                  .map(
                    (risk) =>
                        DropdownMenuItem(value: risk, child: Text(risk.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onRetentionRiskChanged(value);
          },
          validator:
              IncomingTalentMobilityFirstReviewDraft.validateRetentionRisk,
        );

    return _ResponsiveFields(
      children: [outcomeField, confidenceField, riskField],
    );
  }
}

class IncomingTalentMobilityFirstReviewDateFields extends StatelessWidget {
  final IncomingTalentMobilityFirstReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectFollowUpDate;

  const IncomingTalentMobilityFirstReviewDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectFollowUpDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveFields(
      children: [
        _ReviewDateField(
          label: 'Review date',
          icon: Icons.event_available_outlined,
          value: draft.reviewDate,
          error: IncomingTalentMobilityFirstReviewDraft.validateReviewDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
          onTap: onSelectReviewDate,
        ),
        _ReviewDateField(
          label: 'Follow-up date',
          icon: Icons.update_outlined,
          value: draft.followUpDate,
          error: IncomingTalentMobilityFirstReviewDraft.validateFollowUpDate(
            draft.reviewDate,
            draft.followUpDate,
          ),
          onTap: onSelectFollowUpDate,
        ),
      ],
    );
  }
}

class IncomingTalentMobilityFirstReviewDraftReadiness extends StatelessWidget {
  final IncomingTalentMobilityFirstReviewDraft draft;

  const IncomingTalentMobilityFirstReviewDraftReadiness({
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

class _ReviewDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ReviewDateField({
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
