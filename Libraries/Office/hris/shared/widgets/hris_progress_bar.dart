import 'package:flutter/material.dart';

import '../theme/hris_theme.dart';

class HrisProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const HrisProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value.clamp(0, 1),
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}
