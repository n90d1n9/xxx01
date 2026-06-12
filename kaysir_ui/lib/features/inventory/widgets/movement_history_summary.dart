import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_movement_record.dart';
import '../utils/inventory_formatters.dart';
import 'movement_direction_visuals.dart';

/// Summary metric grid for inventory movement history.
class InventoryMovementHistorySummary extends StatelessWidget {
  const InventoryMovementHistorySummary({super.key, required this.records});

  final List<InventoryMovementRecord> records;

  @override
  Widget build(BuildContext context) {
    final inboundQuantity = records
        .where(
          (record) => record.direction == InventoryMovementDirection.inbound,
        )
        .fold<int>(0, (sum, record) => sum + record.movement.quantity);
    final outboundQuantity = records
        .where(
          (record) => record.direction == InventoryMovementDirection.outbound,
        )
        .fold<int>(0, (sum, record) => sum + record.movement.quantity);
    final transferCount =
        records
            .where(
              (record) =>
                  record.direction == InventoryMovementDirection.transfer,
            )
            .length;

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Movements',
          value: records.length.toString(),
          helper: 'Recorded stock events',
          icon: Icons.sync_alt_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Inbound Qty',
          value: formatInventoryNumber(inboundQuantity),
          helper: 'Receipts, purchases, and inbound stock',
          icon: movementDirectionIcon(InventoryMovementDirection.inbound),
          accentColor: movementDirectionStaticColor(
            InventoryMovementDirection.inbound,
          ),
        ),
        AppMetricGridItem(
          title: 'Outbound Qty',
          value: formatInventoryNumber(outboundQuantity),
          helper: 'Sales, issues, and outbound stock',
          icon: movementDirectionIcon(InventoryMovementDirection.outbound),
          accentColor: movementDirectionStaticColor(
            InventoryMovementDirection.outbound,
          ),
        ),
        AppMetricGridItem(
          title: 'Transfers',
          value: transferCount.toString(),
          helper: 'Warehouse-to-warehouse moves',
          icon: movementDirectionIcon(InventoryMovementDirection.transfer),
          accentColor: movementDirectionStaticColor(
            InventoryMovementDirection.transfer,
          ),
        ),
      ],
    );
  }
}
