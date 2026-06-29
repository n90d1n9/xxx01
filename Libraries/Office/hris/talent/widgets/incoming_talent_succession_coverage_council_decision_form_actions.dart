import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionFormActions
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilDecisionDraft draft;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentSuccessionCoverageCouncilDecisionFormActions({
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
          key: const Key('incoming-talent-coverage-council-decision-submit'),
          onPressed: draft.isReadyToSubmit ? onSubmit : null,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Record decision'),
        ),
      ],
    );
  }
}
