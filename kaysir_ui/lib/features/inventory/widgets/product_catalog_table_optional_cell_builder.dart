import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_product_catalog_record_footer_builder.dart';
import 'inventory_product_catalog_table_cells.dart';

/// Builds table cells for optional product catalog table columns.
class InventoryProductCatalogTableOptionalCellBuilder {
  const InventoryProductCatalogTableOptionalCellBuilder({
    required this.density,
    this.recordFooterBuilder,
  });

  final InventoryProductCatalogTableDensity density;
  final InventoryProductCatalogRecordFooterBuilder? recordFooterBuilder;

  /// Returns the data cell for a visible optional column.
  DataCell buildCell(
    BuildContext context,
    InventoryProductCatalogRecord record,
    InventoryProductCatalogTableOptionalColumn column,
  ) {
    switch (column) {
      case InventoryProductCatalogTableOptionalColumn.status:
        return DataCell(InventoryProductCatalogTableStatusCell(record: record));
      case InventoryProductCatalogTableOptionalColumn.category:
        return DataCell(
          InventoryProductCatalogTableTextCell(record.categoryLabel),
        );
      case InventoryProductCatalogTableOptionalColumn.stock:
        return DataCell(
          InventoryProductCatalogTableNumberCell(
            formatInventoryNumber(record.totalQuantity),
          ),
        );
      case InventoryProductCatalogTableOptionalColumn.shortage:
        return DataCell(
          InventoryProductCatalogTableNumberCell(
            formatInventoryNumber(record.totalShortage),
            emphasized: record.totalShortage > 0,
          ),
        );
      case InventoryProductCatalogTableOptionalColumn.value:
        return DataCell(
          InventoryProductCatalogTableNumberCell(
            formatInventoryCurrency(record.inventoryValue),
          ),
        );
      case InventoryProductCatalogTableOptionalColumn.price:
        return DataCell(
          InventoryProductCatalogTableNumberCell(
            formatInventoryCurrency(record.unitPrice),
          ),
        );
      case InventoryProductCatalogTableOptionalColumn.signals:
        return DataCell(
          InventoryProductCatalogTableSignalsCell(
            compact: density == InventoryProductCatalogTableDensity.compact,
            footer: recordFooterBuilder?.call(context, record),
          ),
        );
    }
  }
}
