import 'package:flutter/material.dart';

/// Square icon badge for surfacing FnB readiness or review state.
class FnbStatusBadge extends StatelessWidget {
  const FnbStatusBadge({
    super.key,
    required this.icon,
    required this.color,
    this.tooltip,
    this.size = 36,
    this.iconSize = 20,
    this.backgroundAlpha = .12,
    this.borderRadius = 8,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(iconSize > 0, 'iconSize must be greater than zero.');

  final IconData icon;
  final Color color;
  final String? tooltip;
  final double size;
  final double iconSize;
  final double backgroundAlpha;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final badge = DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );

    if (tooltip == null) return badge;
    return Tooltip(message: tooltip!, child: badge);
  }
}
