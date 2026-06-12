import 'package:flutter/material.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = 8,
    this.tooltip,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badge = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Icon(
        icon,
        color: foregroundColor ?? colorScheme.onPrimaryContainer,
        size: iconSize ?? _defaultIconSize,
        semanticLabel: semanticLabel,
      ),
    );

    if (tooltip == null) return badge;

    return Tooltip(message: tooltip!, child: badge);
  }

  double get _defaultIconSize => (size * 0.5).clamp(18, 24).toDouble();
}
