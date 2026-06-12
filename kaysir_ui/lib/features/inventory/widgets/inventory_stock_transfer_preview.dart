import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_record.dart';
import '../models/inventory_stock_transfer_draft.dart';

class InventoryStockTransferPreview extends StatelessWidget {
  const InventoryStockTransferPreview({
    super.key,
    required this.record,
    required this.destinationRecord,
    required this.draft,
  });

  final InventoryStockRecord record;
  final InventoryStockRecord? destinationRecord;
  final InventoryStockTransferDraft? draft;

  @override
  Widget build(BuildContext context) {
    final sourceProjected =
        draft == null
            ? record.quantity
            : draft!.sourceQuantityAfter(record.quantity);
    final destinationCurrent = destinationRecord?.quantity ?? 0;
    final destinationProjected =
        draft == null
            ? destinationCurrent
            : draft!.destinationQuantityAfter(destinationCurrent);

    return AppMetricGrid(
      minTileWidth: 150,
      metrics: [
        AppMetricGridItem(
          title: 'Source After',
          value: sourceProjected < 0 ? '0' : sourceProjected.toString(),
          helper: record.warehouseName,
          icon: Icons.outbox_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Destination After',
          value: destinationProjected.toString(),
          helper:
              destinationRecord == null
                  ? 'New stock line'
                  : destinationRecord!.warehouseName,
          icon: Icons.move_to_inbox_rounded,
          accentColor: Colors.teal.shade700,
        ),
      ],
    );
  }
}
