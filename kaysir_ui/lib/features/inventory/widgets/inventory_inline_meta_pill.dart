import 'package:flutter/material.dart';

import 'inventory_tile_surface.dart';

class InventoryInlineMetaPill extends StatelessWidget {
  const InventoryInlineMetaPill({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.maxWidth,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800);

    final pill = InventoryTileSurface(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      borderColor: borderColor ?? colorScheme.outlineVariant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ],
      ),
    );

    if (maxWidth == null) return pill;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: pill,
    );
  }
}
