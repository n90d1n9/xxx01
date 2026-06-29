import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionOutcomeField
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilDecisionDraft draft;
  final ValueChanged<IncomingTalentSuccessionCoverageCouncilDecisionOutcome>
  onChanged;

  const IncomingTalentSuccessionCoverageCouncilDecisionOutcomeField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
    >(
      initialValue: draft.outcome,
      decoration: const InputDecoration(
        labelText: 'Council decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome.values
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
      validator: validateCoverageCouncilDecisionOutcome,
    );
  }
}
