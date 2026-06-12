import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_control_icons.dart';

class InventoryProductCatalogTablePresetBadge extends StatelessWidget {
  const InventoryProductCatalogTablePresetBadge({
    super.key,
    required this.preferences,
  });

  final InventoryProductCatalogTablePreferences preferences;

  @override
  Widget build(BuildContext context) {
    final preset = preferences.matchingPreset;
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        preferences.isCustom ? colorScheme.tertiary : colorScheme.primary;

    return Tooltip(
      message: 'Current table preset: ${preferences.activePresetLabel}',
      child: SizedBox(
        height: 34,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  preset == null
                      ? Icons.tune_rounded
                      : inventoryProductCatalogTablePresetIcon(preset),
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  preferences.activePresetLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
