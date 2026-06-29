import 'package:flutter/material.dart';

class IncomingTalentMobilityFirstReviewFormActions extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentMobilityFirstReviewFormActions({
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
          key: const Key('incoming-talent-mobility-first-review-submit'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Submit review'),
        ),
      ],
    );
  }
}
