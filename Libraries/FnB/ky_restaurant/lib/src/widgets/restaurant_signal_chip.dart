import 'package:flutter/material.dart';

class RestaurantSignalChip extends StatelessWidget {
  const RestaurantSignalChip({
    super.key,
    required this.label,
    this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    this.iconSize = 13,
    this.iconSpacing = 5,
    this.fontWeight = FontWeight.w800,
    this.borderRadius = 999,
  });

  final String label;
  final IconData? icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double iconSpacing;
  final FontWeight fontWeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = foregroundColor ?? colors.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colors.surfaceContainerHighest.withValues(alpha: .46),
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: foreground),
              SizedBox(width: iconSpacing),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
