import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_bulk_price_update.dart';
import '../models/inventory_product_catalog.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_bulk_preview_panel.dart';

class InventoryProductBulkPricePreview extends StatelessWidget {
  const InventoryProductBulkPricePreview({
    super.key,
    required this.records,
    required this.draft,
  });

  final List<InventoryProductCatalogRecord> records;
  final InventoryProductBulkPriceUpdateDraft draft;

  @override
  Widget build(BuildContext context) {
    final projectedInventoryValue = records.fold<double>(
      0,
      (total, record) =>
          total + record.totalQuantity * draft.priceFor(record.product),
    );
    final currentInventoryValue = records.fold<double>(
      0,
      (total, record) => total + record.inventoryValue,
    );
    final delta = projectedInventoryValue - currentInventoryValue;
    final deltaColor =
        delta >= 0 ? Colors.green.shade700 : Colors.orange.shade800;

    return InventoryBulkPreviewPanel<InventoryProductCatalogRecord>(
      title: 'Price preview',
      items: records,
      maxVisibleItems: 4,
      headerTrailing: [
        AppStatusPill(
          label: formatInventoryCurrency(projectedInventoryValue),
          color: Colors.teal.shade700,
          icon: Icons.payments_rounded,
          tooltip: 'Projected selected inventory value',
          maxWidth: 150,
        ),
        AppStatusPill(
          label: _deltaLabel(delta),
          color: deltaColor,
          icon:
              delta >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
          tooltip: 'Projected value change from current selection',
          maxWidth: 150,
        ),
      ],
      itemBuilder:
          (context, record, index) => _InventoryProductBulkPricePreviewRow(
            record: record,
            draft: draft,
          ),
    );
  }
}

class _InventoryProductBulkPricePreviewRow extends StatelessWidget {
  const _InventoryProductBulkPricePreviewRow({
    required this.record,
    required this.draft,
  });

  final InventoryProductCatalogRecord record;
  final InventoryProductBulkPriceUpdateDraft draft;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nextPrice = draft.priceFor(record.product);

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
          '${formatInventoryCurrency(record.unitPrice)} -> '
          '${formatInventoryCurrency(nextPrice)}',
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

String _deltaLabel(double delta) {
  final formatted = formatInventoryCurrency(delta.abs());
  if (delta == 0) return 'No change';

  return delta > 0 ? '+$formatted' : '-$formatted';
}
