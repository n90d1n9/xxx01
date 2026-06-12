import 'package:flutter/material.dart';

class IncomingTalentDevelopmentPortfolioFormActions extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentDevelopmentPortfolioFormActions({
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
          key: const Key('incoming-talent-idp-submit'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.assignment_turned_in_outlined),
          label: const Text('Create IDP'),
        ),
      ],
    );
  }
}
