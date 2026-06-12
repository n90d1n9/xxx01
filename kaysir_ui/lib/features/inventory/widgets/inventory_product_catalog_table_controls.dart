import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'inventory_product_catalog_table_density_toggle.dart';
import 'inventory_product_catalog_table_extension_column_button.dart';
import 'inventory_product_catalog_table_optional_column_button.dart';
import 'inventory_product_catalog_table_preset_badge.dart';
import 'inventory_product_catalog_table_preset_button.dart';

class InventoryProductCatalogTableControls extends StatelessWidget {
  const InventoryProductCatalogTableControls({
    super.key,
    required this.preferences,
    required this.onChanged,
    this.onPresetSelected,
    this.columnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final InventoryProductCatalogTablePreferences preferences;
  final ValueChanged<InventoryProductCatalogTablePreferences> onChanged;
  final ValueChanged<InventoryProductCatalogTablePreset>? onPresetSelected;
  final List<InventoryProductCatalogTableColumnContribution>
  columnContributions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedColumnContributions =
        normalizeInventoryProductCatalogTableColumnContributions(
          columnContributions,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InventoryProductCatalogTablePresetBadge(preferences: preferences),
            InventoryProductCatalogTablePresetButton(
              onSelected:
                  (preset) =>
                      onPresetSelected == null
                          ? onChanged(preset.preferences)
                          : onPresetSelected!(preset),
            ),
            InventoryProductCatalogTableDensityToggle(
              density: preferences.density,
              onChanged:
                  (density) =>
                      onChanged(preferences.copyWith(density: density)),
            ),
            InventoryProductCatalogTableOptionalColumnButton(
              preferences: preferences,
              onChanged:
                  (column) => onChanged(preferences.toggleColumn(column)),
            ),
            if (normalizedColumnContributions.isNotEmpty)
              InventoryProductCatalogTableExtensionColumnButton(
                preferences: preferences,
                contributions: normalizedColumnContributions,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}
