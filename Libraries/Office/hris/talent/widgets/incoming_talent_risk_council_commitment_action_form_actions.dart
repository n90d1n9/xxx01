import 'package:flutter/material.dart';

class IncomingTalentRiskCouncilCommitmentActionFormActions
    extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentRiskCouncilCommitmentActionFormActions({
    super.key,
    required this.canSubmit,
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
          key: const Key('risk-council-commitment-action-submit'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Create action'),
        ),
      ],
    );
  }
}
