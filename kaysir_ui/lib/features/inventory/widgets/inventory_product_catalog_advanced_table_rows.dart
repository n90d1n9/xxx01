import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_cells.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'product_catalog_table_optional_cell_builder.dart';

/// Builds data rows for the product catalog advanced table.
class InventoryProductCatalogAdvancedTableRowBuilder {
  const InventoryProductCatalogAdvancedTableRowBuilder({
    required this.context,
    required this.preferences,
    required this.selectedProductIds,
    required this.visibleColumnContributions,
    this.onSelectionChanged,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.recordFooterBuilder,
  });

  final BuildContext context;
  final InventoryProductCatalogTablePreferences preferences;
  final Set<String> selectedProductIds;
  final List<InventoryProductCatalogTableColumnContribution>
  visibleColumnContributions;
  final void Function(InventoryProductCatalogRecord record, bool selected)?
  onSelectionChanged;
  final ValueChanged<InventoryProductCatalogRecord>? onEdit;
  final ValueChanged<InventoryProductCatalogRecord>? onDuplicate;
  final ValueChanged<InventoryProductCatalogRecord>? onDelete;
  final Widget? Function(
    BuildContext context,
    InventoryProductCatalogRecord record,
  )?
  recordFooterBuilder;

  DataRow buildRow(InventoryProductCatalogRecord record) {
    return DataRow(
      key: ValueKey('inventory-product-table-row-${record.id}'),
      selected: selectedProductIds.contains(record.id),
      onSelectChanged:
          onSelectionChanged == null
              ? null
              : (selected) => onSelectionChanged!(record, selected ?? false),
      cells: _cellsFor(record),
    );
  }

  List<DataCell> _cellsFor(InventoryProductCatalogRecord record) {
    final optionalCellBuilder = InventoryProductCatalogTableOptionalCellBuilder(
      density: preferences.density,
      recordFooterBuilder: recordFooterBuilder,
    );

    return [
      DataCell(InventoryProductCatalogTableProductCell(record: record)),
      DataCell(
        InventoryProductCatalogTableActionsCell(
          record: record,
          onEdit: onEdit,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
        ),
      ),
      for (final column in InventoryProductCatalogTableOptionalColumn.values)
        if (preferences.isVisible(column))
          optionalCellBuilder.buildCell(context, record, column),
      for (final contribution in visibleColumnContributions)
        DataCell(contribution.cellBuilder(context, record)),
    ];
  }
}
