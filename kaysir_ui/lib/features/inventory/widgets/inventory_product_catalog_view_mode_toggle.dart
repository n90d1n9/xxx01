import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_view_mode.dart';

export '../models/inventory_product_catalog_view_mode.dart';

class InventoryProductCatalogViewModeToggle extends StatelessWidget {
  const InventoryProductCatalogViewModeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InventoryProductCatalogViewMode value;
  final ValueChanged<InventoryProductCatalogViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<InventoryProductCatalogViewMode>(
      showSelectedIcon: false,
      selected: {value},
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      segments: const [
        ButtonSegment(
          value: InventoryProductCatalogViewMode.cards,
          icon: Icon(Icons.view_agenda_rounded),
          label: Text('Cards'),
        ),
        ButtonSegment(
          value: InventoryProductCatalogViewMode.table,
          icon: Icon(Icons.table_rows_rounded),
          label: Text('Table'),
        ),
      ],
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onChanged(selection.first);
      },
    );
  }
}
