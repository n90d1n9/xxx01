import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceInterventionOutcomeTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityCadenceInterventionOutcomeTextInput({
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

class IncomingTalentMobilityCadenceInterventionOutcomeSignalFields
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionOutcomeDraft draft;
  final ValueChanged<IncomingTalentMobilityCadenceInterventionOutcomeDecision>
  onDecisionChanged;
  final ValueChanged<IncomingTalentMobilityCadenceInterventionSustainability>
  onSustainabilityChanged;
  final ValueChanged<IncomingTalentMobilityStabilizationResidualRisk>
  onResidualRiskChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentMobilityCadenceInterventionOutcomeSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onSustainabilityChanged,
    required this.onResidualRiskChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = DropdownButtonFormField<
      IncomingTalentMobilityCadenceInterventionOutcomeDecision
    >(
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Outcome',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_outlined),
      ),
      items:
          IncomingTalentMobilityCadenceInterventionOutcomeDecision.values
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
          IncomingTalentMobilityCadenceInterventionOutcomeDraft
              .validateDecision,
    );
    final sustainabilityField = DropdownButtonFormField<
      IncomingTalentMobilityCadenceInterventionSustainability
    >(
      initialValue: draft.sustainability,
      decoration: const InputDecoration(
        labelText: 'Sustainability',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.eco_outlined),
      ),
      items:
          IncomingTalentMobilityCadenceInterventionSustainability.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onSustainabilityChanged(value);
      },
      validator:
          IncomingTalentMobilityCadenceInterventionOutcomeDraft
              .validateSustainability,
    );
    final riskField = DropdownButtonFormField<
      IncomingTalentMobilityStabilizationResidualRisk
    >(
      initialValue: draft.residualRiskAfter,
      decoration: const InputDecoration(
        labelText: 'Residual risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentMobilityStabilizationResidualRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onResidualRiskChanged(value);
      },
      validator:
          IncomingTalentMobilityCadenceInterventionOutcomeDraft
              .validateResidualRisk,
    );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.hostConfidenceAfter >= 1 && draft.hostConfidenceAfter <= 5
              ? draft.hostConfidenceAfter
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
              IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateHostConfidenceAfter(
                value ?? 0,
              ),
    );

    return _ResponsiveFields(
      children: [
        decisionField,
        sustainabilityField,
        riskField,
        confidenceField,
      ],
    );
  }
}

class IncomingTalentMobilityCadenceInterventionOutcomeDateFields
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionOutcomeDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentMobilityCadenceInterventionOutcomeDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveFields(
      children: [
        _OutcomeDateField(
          label: 'Review date',
          icon: Icons.event_available_outlined,
          value: draft.reviewDate,
          error:
              IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateReviewDate(
                draft.reviewDate,
                draft.asOfDate,
              ),
          onTap: onSelectReviewDate,
        ),
        _OutcomeDateField(
          label: 'Next review',
          icon: Icons.update_outlined,
          value: draft.nextReviewDate,
          error:
              IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateNextReviewDate(
                draft.reviewDate,
                draft.nextReviewDate,
              ),
          onTap: onSelectNextReviewDate,
        ),
      ],
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
