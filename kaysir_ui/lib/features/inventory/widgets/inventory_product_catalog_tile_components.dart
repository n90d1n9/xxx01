import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_tile_actions.dart';
import 'inventory_product_catalog_tile_layout.dart';
import 'inventory_product_catalog_tile_metrics.dart';
import 'inventory_product_catalog_tile_selection_control.dart';
import 'inventory_product_catalog_tile_status.dart';
import 'inventory_product_catalog_tile_summary.dart';
import 'inventory_product_catalog_visuals.dart';

class InventoryProductCatalogTile extends StatelessWidget {
  const InventoryProductCatalogTile({
    super.key,
    required this.record,
    this.selected = false,
    this.onSelectionChanged,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.footer,
  });

  final InventoryProductCatalogRecord record;
  final bool selected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final statusVisuals = inventoryProductCatalogStatusVisuals(record.status);
    final selector =
        onSelectionChanged == null
            ? null
            : InventoryProductCatalogTileSelectionControl(
              productName: record.productName,
              selected: selected,
              onSelectionChanged: onSelectionChanged!,
            );

    return InventoryProductCatalogTileLayout(
      backgroundColor: statusVisuals.color.withValues(alpha: 0.06),
      selector: selector,
      summary: InventoryProductCatalogTileSummary(record: record),
      metrics: InventoryProductCatalogTileMetrics(record: record),
      status: InventoryProductCatalogTileStatus(record: record),
      actions: InventoryProductCatalogTileActions(
        record: record,
        onEdit: onEdit,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
      ),
      footer: footer,
    );
  }
}
