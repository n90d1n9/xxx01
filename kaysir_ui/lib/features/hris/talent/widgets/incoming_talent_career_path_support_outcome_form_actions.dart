import 'package:flutter/material.dart';

class IncomingTalentCareerPathSupportOutcomeFormActions
    extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentCareerPathSupportOutcomeFormActions({
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
          key: const Key('incoming-talent-career-support-outcome-submit'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.insights_outlined),
          label: const Text('Record outcome'),
        ),
      ],
    );
  }
}
