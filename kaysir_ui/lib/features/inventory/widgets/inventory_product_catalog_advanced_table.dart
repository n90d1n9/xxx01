import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import 'inventory_data_table_surface.dart';
import 'inventory_product_catalog_advanced_table_columns.dart';
import 'inventory_product_catalog_advanced_table_rows.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'product_catalog_preview_data.dart';

/// Data-table presentation for dense product catalog operations.
class InventoryProductCatalogAdvancedTable extends StatelessWidget {
  const InventoryProductCatalogAdvancedTable({
    super.key,
    required this.records,
    this.preferences = const InventoryProductCatalogTablePreferences(),
    this.sortState = const InventoryProductCatalogTableSortState(),
    this.selectedProductIds = const <String>{},
    this.onSelectionChanged,
    this.onSelectVisibleChanged,
    this.onSortStateChanged,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.recordFooterBuilder,
    this.columnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final List<InventoryProductCatalogRecord> records;
  final InventoryProductCatalogTablePreferences preferences;
  final InventoryProductCatalogTableSortState sortState;
  final Set<String> selectedProductIds;
  final void Function(InventoryProductCatalogRecord record, bool selected)?
  onSelectionChanged;
  final ValueChanged<bool>? onSelectVisibleChanged;
  final ValueChanged<InventoryProductCatalogTableSortState>? onSortStateChanged;
  final ValueChanged<InventoryProductCatalogRecord>? onEdit;
  final ValueChanged<InventoryProductCatalogRecord>? onDuplicate;
  final ValueChanged<InventoryProductCatalogRecord>? onDelete;
  final List<InventoryProductCatalogTableColumnContribution>
  columnContributions;
  final Widget? Function(
    BuildContext context,
    InventoryProductCatalogRecord record,
  )?
  recordFooterBuilder;

  @override
  Widget build(BuildContext context) {
    final density = preferences.density;
    final colorScheme = Theme.of(context).colorScheme;
    final columnBuilder = InventoryProductCatalogAdvancedTableColumnBuilder(
      preferences: preferences,
      columnContributions: columnContributions,
      onSortStateChanged: onSortStateChanged,
    );
    final sortState = columnBuilder.effectiveSortState(
      sortState: this.sortState,
    );
    final sortedRecords = sortInventoryProductCatalogTableRecords(
      records: records,
      column: sortState.column,
      ascending: sortState.ascending,
    );
    final rowBuilder = InventoryProductCatalogAdvancedTableRowBuilder(
      context: context,
      preferences: preferences,
      selectedProductIds: selectedProductIds,
      visibleColumnContributions: columnBuilder.visibleColumnContributions,
      onSelectionChanged: onSelectionChanged,
      onEdit: onEdit,
      onDuplicate: onDuplicate,
      onDelete: onDelete,
      recordFooterBuilder: recordFooterBuilder,
    );

    return InventoryDataTableSurface(
      height: inventoryProductCatalogAdvancedTableHeight(
        sortedRecords.length,
        density: density,
      ),
      child: DataTable(
        sortColumnIndex: columnBuilder.sortColumnIndex(sortState),
        sortAscending: sortState.ascending,
        showCheckboxColumn: onSelectionChanged != null,
        onSelectAll:
            onSelectVisibleChanged == null
                ? null
                : (selected) => onSelectVisibleChanged!(selected ?? false),
        headingRowColor: WidgetStateProperty.resolveWith(
          (_) => colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
        ),
        dataRowMinHeight: density.dataRowMinHeight,
        dataRowMaxHeight: density.dataRowMaxHeight,
        columnSpacing:
            density == InventoryProductCatalogTableDensity.compact ? 16 : 22,
        horizontalMargin: 16,
        columns: columnBuilder.buildColumns(),
        rows: [for (final record in sortedRecords) rowBuilder.buildRow(record)],
      ),
    );
  }
}

double inventoryProductCatalogAdvancedTableHeight(
  int rowCount, {
  required InventoryProductCatalogTableDensity density,
}) {
  final preferredHeight = 64 + (rowCount * density.rowExtent);
  return preferredHeight.clamp(240, 520).toDouble();
}

@Preview(name: 'Inventory product catalog advanced table')
Widget inventoryProductCatalogAdvancedTablePreview() {
  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogAdvancedTable(
      records: inventoryProductCatalogPreviewRecords(),
      preferences: InventoryProductCatalogTablePreset.operations.preferences,
      sortState: const InventoryProductCatalogTableSortState(),
      onEdit: (_) {},
      onDuplicate: (_) {},
      onDelete: (_) {},
      recordFooterBuilder:
          (context, record) => Text('Signals for ${record.productName}'),
    ),
  );
}
