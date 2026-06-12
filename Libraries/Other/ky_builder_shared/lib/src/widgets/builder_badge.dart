import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Displays a compact builder badge with optional icon and trailing content.
class KyBuilderBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double borderWidth;
  final double iconSize;
  final double iconGap;
  final double? maxWidth;
  final TextStyle? textStyle;

  const KyBuilderBadge({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.tooltip,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    this.radius = 999,
    this.borderWidth = 1,
    this.iconSize = 12,
    this.iconGap = 4,
    this.maxWidth,
    this.textStyle,
  });

  @Preview(name: 'Builder badge')
  const KyBuilderBadge.preview({super.key})
    : label = 'Saved',
      icon = Icons.bookmark_added_outlined,
      trailing = null,
      tooltip = null,
      backgroundColor = null,
      borderColor = null,
      foregroundColor = null,
      padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      radius = 999,
      borderWidth = 1,
      iconSize = 12,
      iconGap = 4,
      maxWidth = null,
      textStyle = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = foregroundColor ?? colorScheme.onSurfaceVariant;
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          textStyle ??
          theme.textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
    );
    Widget badge = DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.76),
        border: Border.all(
          color: borderColor ?? colorScheme.outlineVariant,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: foreground),
              SizedBox(width: iconGap),
            ],
            if (maxWidth == null) labelText else Flexible(child: labelText),
            if (trailing != null) ...[SizedBox(width: iconGap + 2), trailing!],
          ],
        ),
      ),
    );

    if (maxWidth != null) {
      badge = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: badge,
      );
    }

    if (tooltip != null) {
      badge = Tooltip(message: tooltip!, child: badge);
    }

    return badge;
  }
}
