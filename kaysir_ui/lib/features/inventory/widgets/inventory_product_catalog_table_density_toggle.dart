import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_control_icons.dart';

class InventoryProductCatalogTableDensityToggle extends StatelessWidget {
  const InventoryProductCatalogTableDensityToggle({
    super.key,
    required this.density,
    required this.onChanged,
  });

  final InventoryProductCatalogTableDensity density;
  final ValueChanged<InventoryProductCatalogTableDensity> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<InventoryProductCatalogTableDensity>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      segments: [
        for (final density in InventoryProductCatalogTableDensity.values)
          ButtonSegment(
            value: density,
            icon: Icon(
              inventoryProductCatalogTableDensityIcon(density),
              size: 16,
            ),
            label: Text(density.label),
            tooltip: '${density.label} table density',
          ),
      ],
      selected: {density},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}
