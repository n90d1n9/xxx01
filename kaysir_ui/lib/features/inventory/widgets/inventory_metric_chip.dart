import 'package:flutter/material.dart';

import 'inventory_tile_surface.dart';

class InventoryMetricChip extends StatelessWidget {
  const InventoryMetricChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
    this.emphasizeColor,
    this.maxValueWidth = 150,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;
  final Color? emphasizeColor;
  final double? maxValueWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = emphasizeColor ?? colorScheme.error;
    final foreground = emphasize ? accent : colorScheme.onSurface;
    final iconColor = emphasize ? accent : colorScheme.onSurfaceVariant;

    return InventoryTileSurface(
      backgroundColor:
          emphasize ? accent.withValues(alpha: 0.08) : colorScheme.surface,
      borderColor:
          emphasize
              ? accent.withValues(alpha: 0.24)
              : colorScheme.outlineVariant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MetricValueText(
                value: value,
                color: foreground,
                maxWidth: maxValueWidth,
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricValueText extends StatelessWidget {
  const _MetricValueText({
    required this.value,
    required this.color,
    required this.maxWidth,
  });

  final String value;
  final Color color;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );

    if (maxWidth == null) return text;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: text,
    );
  }
}
