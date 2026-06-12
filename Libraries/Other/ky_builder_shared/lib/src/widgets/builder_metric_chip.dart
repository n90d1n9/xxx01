import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Displays one compact builder metric with an icon, value, and label.
class KyBuilderMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const KyBuilderMetricChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @Preview(name: 'Builder metric chip')
  const KyBuilderMetricChip.preview({super.key})
    : icon = Icons.widgets_outlined,
      label = 'blocks',
      value = '12',
      color = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = color ?? colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
