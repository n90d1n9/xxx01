import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_record_footer_builder.dart';
import 'inventory_product_catalog_tile_components.dart';
import 'product_catalog_preview_data.dart';

/// Vertical card list for the product catalog card presentation mode.
class InventoryProductCatalogCardList extends StatelessWidget {
  const InventoryProductCatalogCardList({
    super.key,
    required this.records,
    required this.selectedProductIds,
    this.onSelectionChanged,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.recordFooterBuilder,
  });

  final List<InventoryProductCatalogRecord> records;
  final Set<String> selectedProductIds;
  final void Function(InventoryProductCatalogRecord record, bool selected)?
  onSelectionChanged;
  final ValueChanged<InventoryProductCatalogRecord>? onEdit;
  final ValueChanged<InventoryProductCatalogRecord>? onDuplicate;
  final ValueChanged<InventoryProductCatalogRecord>? onDelete;
  final InventoryProductCatalogRecordFooterBuilder? recordFooterBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < records.length; index += 1) ...[
          InventoryProductCatalogTile(
            record: records[index],
            selected: selectedProductIds.contains(records[index].id),
            onSelectionChanged:
                onSelectionChanged == null
                    ? null
                    : (selected) =>
                        onSelectionChanged!(records[index], selected),
            onEdit: onEdit == null ? null : () => onEdit!(records[index]),
            onDuplicate:
                onDuplicate == null ? null : () => onDuplicate!(records[index]),
            onDelete: onDelete == null ? null : () => onDelete!(records[index]),
            footer: recordFooterBuilder?.call(context, records[index]),
          ),
          if (index != records.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Inventory product catalog card list')
Widget inventoryProductCatalogCardListPreview() {
  final records = inventoryProductCatalogPreviewRecords();

  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogCardList(
      records: records,
      selectedProductIds: {records.first.id},
      onSelectionChanged: (_, _) {},
      onEdit: (_) {},
      onDuplicate: (_) {},
      onDelete: (_) {},
    ),
  );
}
