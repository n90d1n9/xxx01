import 'package:flutter/material.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import 'warehouse_capacity_status.dart';

/// Responsive header for a warehouse capacity tile.
class InventoryWarehouseCapacityTileHeader extends StatelessWidget {
  const InventoryWarehouseCapacityTileHeader({
    super.key,
    required this.summary,
    required this.status,
  });

  final Widget summary;
  final InventoryWarehouseCapacityStatus status;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;
        final statusPill = InventoryWarehouseCapacityStatusPill(status: status);

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              summary,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: statusPill),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: summary),
            const SizedBox(width: 12),
            statusPill,
          ],
        );
      },
    );
  }
}
