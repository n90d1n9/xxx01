import 'package:flutter/material.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageActionOutcomeFormActions
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageActionOutcomeDraft draft;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentSuccessionCoverageActionOutcomeFormActions({
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
          key: const Key('incoming-talent-succession-coverage-outcome-submit'),
          onPressed: draft.isReadyToSubmit ? onSubmit : null,
          icon: const Icon(Icons.insights_outlined),
          label: const Text('Submit outcome'),
        ),
      ],
    );
  }
}
