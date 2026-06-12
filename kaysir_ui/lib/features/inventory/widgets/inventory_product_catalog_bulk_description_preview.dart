import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_description_fill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_bulk_preview_panel.dart';

class InventoryProductBulkDescriptionPreview extends StatelessWidget {
  const InventoryProductBulkDescriptionPreview({
    super.key,
    required this.records,
    required this.draft,
  });

  final List<InventoryProductCatalogRecord> records;
  final InventoryProductBulkDescriptionFillDraft draft;

  @override
  Widget build(BuildContext context) {
    return InventoryBulkPreviewPanel<InventoryProductCatalogRecord>(
      title: 'Description preview',
      items: records,
      maxVisibleItems: 4,
      itemSpacing: 10,
      itemBuilder:
          (context, record, index) =>
              _InventoryProductBulkDescriptionPreviewRow(
                record: record,
                description: draft.descriptionFor(record.product),
              ),
    );
  }
}

class _InventoryProductBulkDescriptionPreviewRow extends StatelessWidget {
  const _InventoryProductBulkDescriptionPreviewRow({
    required this.record,
    required this.description,
  });

  final InventoryProductCatalogRecord record;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          record.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          inventoryProductBulkDescriptionPreviewLabel(
            product: record.product,
            description: description,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
