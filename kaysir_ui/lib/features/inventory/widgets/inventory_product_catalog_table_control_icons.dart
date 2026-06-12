import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';

IconData inventoryProductCatalogTablePresetIcon(
  InventoryProductCatalogTablePreset preset,
) {
  switch (preset) {
    case InventoryProductCatalogTablePreset.operations:
      return Icons.dashboard_customize_rounded;
    case InventoryProductCatalogTablePreset.stockControl:
      return Icons.inventory_rounded;
    case InventoryProductCatalogTablePreset.pricing:
      return Icons.sell_rounded;
    case InventoryProductCatalogTablePreset.channelSignals:
      return Icons.hub_rounded;
  }
}

IconData inventoryProductCatalogTableDensityIcon(
  InventoryProductCatalogTableDensity density,
) {
  switch (density) {
    case InventoryProductCatalogTableDensity.comfortable:
      return Icons.table_rows_rounded;
    case InventoryProductCatalogTableDensity.compact:
      return Icons.density_small_rounded;
  }
}
