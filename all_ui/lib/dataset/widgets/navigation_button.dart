import 'package:flutter/material.dart';

class _NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool showNext;

  const _NavigationButtons({this.onBack, this.onNext, this.showNext = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        else
          const SizedBox.shrink(),
        if (showNext && onNext != null)
          FilledButton.icon(
            onPressed: onNext,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward),
            iconAlignment: IconAlignment.end,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
/* 
class _NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool showNext;

  const _NavigationButtons({this.onBack, this.onNext, this.showNext = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        else
          const SizedBox.shrink(),
        if (showNext && onNext != null)
          FilledButton.icon(
            onPressed: onNext,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward),
            iconAlignment: IconAlignment.end,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
 */