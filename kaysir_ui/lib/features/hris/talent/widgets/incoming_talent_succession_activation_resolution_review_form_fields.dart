import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionActivationResolutionReviewTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionActivationResolutionReviewTextInput({
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

class IncomingTalentSuccessionActivationResolutionReviewSignalFields
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationResolutionReviewDraft draft;
  final ValueChanged<IncomingTalentSuccessionActivationResolutionOutcome>
  onOutcomeChanged;
  final ValueChanged<IncomingTalentSuccessionActivationResidualRisk>
  onRiskChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentSuccessionActivationResolutionReviewSignalFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onRiskChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outcomeField = DropdownButtonFormField<
      IncomingTalentSuccessionActivationResolutionOutcome
    >(
      initialValue: draft.outcome,
      decoration: const InputDecoration(
        labelText: 'Outcome',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          IncomingTalentSuccessionActivationResolutionOutcome.values
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
      validator:
          IncomingTalentSuccessionActivationResolutionReviewDraft
              .validateOutcome,
    );
    final riskField =
        DropdownButtonFormField<IncomingTalentSuccessionActivationResidualRisk>(
          initialValue: draft.residualRisk,
          decoration: const InputDecoration(
            labelText: 'Residual risk',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shield_outlined),
          ),
          items:
              IncomingTalentSuccessionActivationResidualRisk.values
                  .map(
                    (risk) =>
                        DropdownMenuItem(value: risk, child: Text(risk.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onRiskChanged(value);
          },
          validator:
              IncomingTalentSuccessionActivationResolutionReviewDraft
                  .validateResidualRisk,
        );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.finalConfidenceScore >= 1 && draft.finalConfidenceScore <= 5
              ? draft.finalConfidenceScore
              : null,
      decoration: const InputDecoration(
        labelText: 'Final confidence',
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
              IncomingTalentSuccessionActivationResolutionReviewDraft.validateFinalConfidenceScore(
                value ?? 0,
              ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              outcomeField,
              const SizedBox(height: 12),
              riskField,
              const SizedBox(height: 12),
              confidenceField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: outcomeField),
            const SizedBox(width: 12),
            Expanded(child: riskField),
            const SizedBox(width: 12),
            Expanded(child: confidenceField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionActivationResolutionReviewDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationResolutionReviewDraft draft;
  final VoidCallback onSelectResolutionDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentSuccessionActivationResolutionReviewDateFields({
    super.key,
    required this.draft,
    required this.onSelectResolutionDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final resolutionField = _ResolutionReviewDateField(
      label: 'Resolution date',
      icon: Icons.event_available_outlined,
      value: draft.resolutionDate,
      error:
          IncomingTalentSuccessionActivationResolutionReviewDraft.validateResolutionDate(
            draft.resolutionDate,
            draft.asOfDate,
          ),
      onTap: onSelectResolutionDate,
    );
    final nextReviewField = _ResolutionReviewDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error:
          IncomingTalentSuccessionActivationResolutionReviewDraft.validateNextReviewDate(
            draft.resolutionDate,
            draft.nextReviewDate,
          ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              resolutionField,
              const SizedBox(height: 12),
              nextReviewField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: resolutionField),
            const SizedBox(width: 12),
            Expanded(child: nextReviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionActivationResolutionReviewDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationResolutionReviewDraft draft;

  const IncomingTalentSuccessionActivationResolutionReviewDraftReadiness({
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

class _ResolutionReviewDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ResolutionReviewDateField({
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
