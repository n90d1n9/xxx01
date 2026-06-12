import 'package:flutter/material.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';

class IncomingTalentRiskCouncilDecisionOutcomeField extends StatelessWidget {
  final IncomingTalentRiskCouncilDecisionDraft draft;
  final ValueChanged<IncomingTalentRiskCouncilDecisionOutcome> onChanged;

  const IncomingTalentRiskCouncilDecisionOutcomeField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncomingTalentRiskCouncilDecisionOutcome>(
      key: ValueKey(
        'risk-council-decision-outcome-${draft.queueItemId}-${draft.outcome?.name}',
      ),
      initialValue: draft.outcome,
      decoration: const InputDecoration(
        labelText: 'Council decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          IncomingTalentRiskCouncilDecisionOutcome.values
              .map(
                (outcome) => DropdownMenuItem(
                  value: outcome,
                  child: Text(outcome.label),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: validateRiskCouncilDecisionOutcome,
    );
  }
}
