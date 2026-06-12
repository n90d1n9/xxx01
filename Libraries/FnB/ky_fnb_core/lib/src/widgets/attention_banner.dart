import 'package:flutter/material.dart';

/// Inline alert banner for the highest-priority FnB operating issue.
class FnbAttentionBanner extends StatelessWidget {
  const FnbAttentionBanner({
    super.key,
    required this.message,
    required this.color,
    this.icon = Icons.priority_high_rounded,
    this.maxLines = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  }) : assert(maxLines > 0, 'maxLines must be greater than zero.');

  final String message;
  final Color color;
  final IconData icon;
  final int maxLines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
