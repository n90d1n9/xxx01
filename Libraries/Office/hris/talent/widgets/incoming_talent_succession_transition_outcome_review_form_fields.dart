import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionTransitionOutcomeReviewTextInput({
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

class IncomingTalentSuccessionTransitionOutcomeReviewSignalFields
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionOutcomeReviewDraft draft;
  final ValueChanged<IncomingTalentSuccessionTransitionOutcomeDecision>
  onDecisionChanged;
  final ValueChanged<IncomingTalentSuccessionTransitionOutcomeResidualRisk>
  onRiskChanged;
  final ValueChanged<int> onStabilizationChanged;

  const IncomingTalentSuccessionTransitionOutcomeReviewSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onRiskChanged,
    required this.onStabilizationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = DropdownButtonFormField<
      IncomingTalentSuccessionTransitionOutcomeDecision
    >(
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Outcome decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.insights_outlined),
      ),
      items:
          IncomingTalentSuccessionTransitionOutcomeDecision.values
              .map(
                (decision) => DropdownMenuItem(
                  value: decision,
                  child: Text(decision.label),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onDecisionChanged(value);
      },
      validator:
          IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateDecision,
    );
    final riskField = DropdownButtonFormField<
      IncomingTalentSuccessionTransitionOutcomeResidualRisk
    >(
      initialValue: draft.residualRisk,
      decoration: const InputDecoration(
        labelText: 'Residual risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentSuccessionTransitionOutcomeResidualRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onRiskChanged(value);
      },
      validator:
          IncomingTalentSuccessionTransitionOutcomeReviewDraft
              .validateResidualRisk,
    );
    final stabilizationField = _OutcomeScoreField(
      label: 'Stabilization',
      value: draft.stabilizationScore,
      onChanged: onStabilizationChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              decisionField,
              const SizedBox(height: 12),
              riskField,
              const SizedBox(height: 12),
              stabilizationField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: riskField),
            const SizedBox(width: 12),
            Expanded(child: stabilizationField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionTransitionOutcomeReviewDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionOutcomeReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentSuccessionTransitionOutcomeReviewDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewField = _OutcomeDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error:
          IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateReviewDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
      onTap: onSelectReviewDate,
    );
    final nextReviewField = _OutcomeDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error:
          IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateNextReviewDate(
            draft.reviewDate,
            draft.nextReviewDate,
          ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              reviewField,
              const SizedBox(height: 12),
              nextReviewField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: reviewField),
            const SizedBox(width: 12),
            Expanded(child: nextReviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionTransitionOutcomeReviewDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionOutcomeReviewDraft draft;

  const IncomingTalentSuccessionTransitionOutcomeReviewDraftReadiness({
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

class _OutcomeScoreField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _OutcomeScoreField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value >= 1 && value <= 5 ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.speed_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator:
          (value) =>
              IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateStabilizationScore(
                value ?? 0,
              ),
    );
  }
}

class _OutcomeDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _OutcomeDateField({
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
