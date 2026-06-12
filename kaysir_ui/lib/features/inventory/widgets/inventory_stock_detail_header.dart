import 'package:flutter/material.dart';

import '../../../widgets/ui/app_text_cluster.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_status_pill.dart';

class InventoryStockDetailHeader extends StatelessWidget {
  const InventoryStockDetailHeader({
    super.key,
    required this.record,
    this.onClose,
  });

  final InventoryStockRecord record;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final header = AppTextCluster(
          eyebrow: 'Stock Detail',
          title: record.productName,
          subtitle:
              '${record.skuLabel} | ${record.categoryLabel} | ${record.warehouseName} - ${record.warehouseLocation}',
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        );
        final trailing = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InventoryStockStatusPill(status: record.status),
            if (onClose != null)
              IconButton(
                tooltip: 'Close details',
                icon: const Icon(Icons.close_rounded),
                color: colorScheme.onSurfaceVariant,
                onPressed: onClose,
              ),
          ],
        );

        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              header,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: header),
            const SizedBox(width: 16),
            trailing,
          ],
        );
      },
    );
  }
}
