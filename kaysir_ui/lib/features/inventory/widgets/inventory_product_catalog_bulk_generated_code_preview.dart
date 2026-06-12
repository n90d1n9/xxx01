import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_bulk_preview_panel.dart';

typedef InventoryProductBulkGeneratedCodeValueBuilder =
    String Function(Product product);
typedef InventoryProductBulkGeneratedCodeLabelBuilder =
    String Function(Product product, String generatedValue);

class InventoryProductBulkGeneratedCodePreview extends StatelessWidget {
  const InventoryProductBulkGeneratedCodePreview({
    super.key,
    required this.title,
    required this.records,
    required this.previewProducts,
    required this.generatedValueFor,
    required this.labelBuilder,
  });

  final String title;
  final List<InventoryProductCatalogRecord> records;
  final List<Product> previewProducts;
  final InventoryProductBulkGeneratedCodeValueBuilder generatedValueFor;
  final InventoryProductBulkGeneratedCodeLabelBuilder labelBuilder;

  @override
  Widget build(BuildContext context) {
    return InventoryBulkPreviewPanel<InventoryProductCatalogRecord>(
      title: title,
      items: records,
      itemBuilder:
          (context, record, index) => _InventoryProductBulkGeneratedCodeRow(
            record: record,
            label: labelBuilder(
              record.product,
              generatedValueFor(previewProducts[index]),
            ),
          ),
    );
  }
}

class _InventoryProductBulkGeneratedCodeRow extends StatelessWidget {
  const _InventoryProductBulkGeneratedCodeRow({
    required this.record,
    required this.label,
  });

  final InventoryProductCatalogRecord record;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            record.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
