import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import '../models/inventory_product_catalog_table_sort.dart';
import 'inventory_product_catalog_table_column_contribution.dart';

/// Builds columns and sort metadata for the product catalog advanced table.
class InventoryProductCatalogAdvancedTableColumnBuilder {
  const InventoryProductCatalogAdvancedTableColumnBuilder({
    required this.preferences,
    required this.columnContributions,
    this.onSortStateChanged,
  });

  final InventoryProductCatalogTablePreferences preferences;
  final List<InventoryProductCatalogTableColumnContribution>
  columnContributions;
  final ValueChanged<InventoryProductCatalogTableSortState>? onSortStateChanged;

  List<DataColumn> buildColumns() {
    return [
      _sortableColumn(InventoryProductCatalogTableColumn.product),
      const DataColumn(label: Text('Actions')),
      for (final column in InventoryProductCatalogTableOptionalColumn.values)
        if (preferences.isVisible(column)) _columnFor(column),
      for (final contribution in visibleColumnContributions)
        _contributedColumnFor(contribution),
    ];
  }

  List<InventoryProductCatalogTableColumnContribution>
  get visibleColumnContributions {
    return [
      for (final contribution
          in normalizeInventoryProductCatalogTableColumnContributions(
            columnContributions,
          ))
        if (preferences.isContributionVisible(
          contribution.normalizedId,
          defaultVisible: contribution.defaultVisible,
        ))
          contribution,
    ];
  }

  InventoryProductCatalogTableSortState effectiveSortState({
    required InventoryProductCatalogTableSortState sortState,
  }) {
    if (preferences.supportsSortColumn(sortState.column)) {
      return sortState;
    }

    return const InventoryProductCatalogTableSortState();
  }

  int sortColumnIndex(InventoryProductCatalogTableSortState sortState) {
    if (sortState.column == InventoryProductCatalogTableColumn.product) {
      return 0;
    }

    var columnIndex = 2;
    for (final column in InventoryProductCatalogTableOptionalColumn.values) {
      if (!preferences.isVisible(column)) continue;

      final sortableColumn = column.sortableColumn;
      if (sortableColumn == sortState.column) return columnIndex;

      columnIndex += 1;
    }

    return 0;
  }

  DataColumn _columnFor(InventoryProductCatalogTableOptionalColumn column) {
    final sortableColumn = column.sortableColumn;
    if (sortableColumn == null) {
      return DataColumn(label: Text(column.label));
    }

    return _sortableColumn(sortableColumn);
  }

  DataColumn _sortableColumn(InventoryProductCatalogTableColumn column) {
    return DataColumn(
      label: Text(column.label),
      numeric: column.numeric,
      onSort:
          (_, ascending) => onSortStateChanged?.call(
            InventoryProductCatalogTableSortState(
              column: column,
              ascending: ascending,
            ),
          ),
    );
  }

  DataColumn _contributedColumnFor(
    InventoryProductCatalogTableColumnContribution contribution,
  ) {
    final label = Text(contribution.label);

    return DataColumn(
      label:
          contribution.tooltip == null
              ? label
              : Tooltip(message: contribution.tooltip!, child: label),
      numeric: contribution.numeric,
    );
  }
}
