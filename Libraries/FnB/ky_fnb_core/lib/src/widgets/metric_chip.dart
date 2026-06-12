import 'package:flutter/material.dart';

/// Compact icon-and-label chip for repeated FnB operating metrics.
class FnbMetricChip extends StatelessWidget {
  const FnbMetricChip({
    super.key,
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    this.iconSize = 14,
    this.maxWidth = 220,
    this.outlined = false,
  }) : assert(iconSize > 0, 'iconSize must be greater than zero.'),
       assert(maxWidth > 0, 'maxWidth must be greater than zero.');

  const FnbMetricChip.outlined({
    super.key,
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.maxWidth = 220,
  }) : backgroundColor = null,
       border = null,
       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
       iconSize = 15,
       outlined = true,
       assert(maxWidth > 0, 'maxWidth must be greater than zero.');

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double maxWidth;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = foregroundColor ?? colors.onSurfaceVariant;
    final effectiveBackground =
        backgroundColor ??
        (outlined
            ? colors.surface.withValues(alpha: .72)
            : colors.surfaceContainerHighest.withValues(alpha: .42));
    final effectiveBorder =
        border ??
        (outlined
            ? Border.all(color: colors.outlineVariant.withValues(alpha: .5))
            : null);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveBackground,
          border: effectiveBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
