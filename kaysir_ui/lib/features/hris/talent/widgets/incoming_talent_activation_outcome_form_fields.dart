import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_outcome_models.dart';

class IncomingTalentActivationOutcomeTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentActivationOutcomeTextInput({
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

class IncomingTalentActivationOutcomeDecisionFields extends StatelessWidget {
  final IncomingTalentActivationOutcomeDraft draft;
  final ValueChanged<IncomingTalentActivationOutcomeDecision> onDecisionChanged;
  final ValueChanged<IncomingTalentActivationRetentionRisk> onRiskChanged;

  const IncomingTalentActivationOutcomeDecisionFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final decisionField =
            DropdownButtonFormField<IncomingTalentActivationOutcomeDecision>(
              initialValue: draft.decision,
              decoration: const InputDecoration(
                labelText: 'Outcome decision',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fact_check_outlined),
              ),
              items:
                  IncomingTalentActivationOutcomeDecision.values
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
              validator: IncomingTalentActivationOutcomeDraft.validateDecision,
            );
        final riskField = DropdownButtonFormField<
          IncomingTalentActivationRetentionRisk
        >(
          initialValue: draft.retentionRisk,
          decoration: const InputDecoration(
            labelText: 'Retention risk',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.health_and_safety_outlined),
          ),
          items:
              IncomingTalentActivationRetentionRisk.values
                  .map(
                    (risk) =>
                        DropdownMenuItem(value: risk, child: Text(risk.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onRiskChanged(value);
          },
          validator: IncomingTalentActivationOutcomeDraft.validateRetentionRisk,
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [decisionField, const SizedBox(height: 12), riskField],
          );
        }

        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: riskField),
          ],
        );
      },
    );
  }
}

class IncomingTalentActivationOutcomeReviewDateField extends StatelessWidget {
  final IncomingTalentActivationOutcomeDraft draft;
  final VoidCallback onSelectReviewDate;

  const IncomingTalentActivationOutcomeReviewDateField({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final error = IncomingTalentActivationOutcomeDraft.validateReviewDate(
      draft.reviewDate,
      draft.asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectReviewDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Outcome review date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.reviewDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.reviewDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.reviewDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class IncomingTalentActivationOutcomeReadinessScore extends StatelessWidget {
  final IncomingTalentActivationOutcomeDraft draft;
  final ValueChanged<int> onChanged;

  const IncomingTalentActivationOutcomeReadinessScore({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = draft.readinessScore.clamp(1, 100);

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Readiness score',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      child: Row(
        children: [
          Text(
            '$safeValue%',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: safeValue.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '$safeValue%',
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class IncomingTalentActivationOutcomeDraftReadiness extends StatelessWidget {
  final IncomingTalentActivationOutcomeDraft draft;

  const IncomingTalentActivationOutcomeDraftReadiness({
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
