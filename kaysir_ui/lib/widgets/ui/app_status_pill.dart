import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.tooltip,
    this.showDot = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.borderRadius = 999,
    this.iconSize = 14,
    this.maxWidth = 220,
    this.textStyle,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final String? tooltip;
  final bool showDot;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double? maxWidth;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedForeground = foregroundColor ?? color;
    final resolvedPadding = padding.resolve(Directionality.of(context));
    final contentWidth =
        maxWidth == null ? null : maxWidth! - resolvedPadding.horizontal;
    final showIcon =
        icon != null && (contentWidth == null || contentWidth >= iconSize + 16);
    final showLeadingDot =
        icon == null && showDot && (contentWidth == null || contentWidth >= 18);
    final leadingWidth =
        showIcon
            ? iconSize + 5
            : showLeadingDot
            ? 12.0
            : 0.0;
    final labelMaxWidth =
        contentWidth == null
            ? null
            : math.max(0.0, contentWidth - leadingWidth);
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          textStyle ??
          Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedForeground,
            fontWeight: FontWeight.w800,
          ),
    );

    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        border: Border.all(color: borderColor ?? color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, size: iconSize, color: resolvedForeground),
              const SizedBox(width: 5),
            ] else if (showLeadingDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: resolvedForeground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (labelMaxWidth == null)
              labelText
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: labelMaxWidth),
                child: labelText,
              ),
          ],
        ),
      ),
    );

    final constrained =
        maxWidth == null
            ? pill
            : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: pill,
            );

    if (tooltip == null) return constrained;

    return Tooltip(message: tooltip, child: constrained);
  }
}
