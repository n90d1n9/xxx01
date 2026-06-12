import 'package:flutter/material.dart';

class AdminStatusBadge extends StatelessWidget {
  const AdminStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.icon,
    this.tooltip,
    this.showDot = true,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData? icon;
  final String? tooltip;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = color ?? colorScheme.secondary;
    final resolvedBackground =
        backgroundColor ??
        colorScheme.secondaryContainer.withValues(alpha: 0.72);
    final resolvedForeground =
        foregroundColor ?? colorScheme.onSecondaryContainer;
    final resolvedBorder =
        borderColor ?? colorScheme.outlineVariant.withValues(alpha: 0.72);
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolvedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 6),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: resolvedForeground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (tooltip == null) return content;

    return Tooltip(message: tooltip, child: content);
  }
}
