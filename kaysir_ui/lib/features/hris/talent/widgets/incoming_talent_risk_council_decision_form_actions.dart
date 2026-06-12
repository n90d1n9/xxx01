import 'package:flutter/material.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';

class IncomingTalentRiskCouncilDecisionFormActions extends StatelessWidget {
  final IncomingTalentRiskCouncilDecisionDraft draft;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentRiskCouncilDecisionFormActions({
    super.key,
    required this.draft,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onClear, child: const Text('Clear')),
        const SizedBox(width: 10),
        FilledButton.icon(
          key: const Key('incoming-talent-risk-council-decision-submit'),
          onPressed: draft.isReadyToSubmit ? onSubmit : null,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Record decision'),
        ),
      ],
    );
  }
}
