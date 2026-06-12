import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageActionOutcomeSignalFields
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageActionOutcomeDraft draft;
  final ValueChanged<IncomingTalentSuccessionCoverageActionOutcomeDecision>
  onDecisionChanged;
  final ValueChanged<IncomingTalentSuccessionCoverageActionResidualRisk>
  onRiskChanged;
  final ValueChanged<int> onCoverageScoreChanged;

  const IncomingTalentSuccessionCoverageActionOutcomeSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onRiskChanged,
    required this.onCoverageScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = DropdownButtonFormField<
      IncomingTalentSuccessionCoverageActionOutcomeDecision
    >(
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Outcome decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.insights_outlined),
      ),
      items:
          IncomingTalentSuccessionCoverageActionOutcomeDecision.values
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
      validator: validateCoverageActionOutcomeDecision,
    );
    final riskField = DropdownButtonFormField<
      IncomingTalentSuccessionCoverageActionResidualRisk
    >(
      initialValue: draft.residualRisk,
      decoration: const InputDecoration(
        labelText: 'Residual risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentSuccessionCoverageActionResidualRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onRiskChanged(value);
      },
      validator: validateCoverageActionOutcomeResidualRisk,
    );
    final coverageScoreField = _CoverageScoreField(
      value: draft.coverageScoreAfter,
      onChanged: onCoverageScoreChanged,
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
              coverageScoreField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: riskField),
            const SizedBox(width: 12),
            Expanded(child: coverageScoreField),
          ],
        );
      },
    );
  }
}

class _CoverageScoreField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CoverageScoreField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value >= 0 && value <= 100 && value % 5 == 0 ? value : null,
      decoration: const InputDecoration(
        labelText: 'Coverage after',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          List<int>.generate(21, (index) => index * 5)
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score%')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator:
          (value) => validateCoverageActionOutcomeScoreAfter(value ?? -1),
    );
  }
}
