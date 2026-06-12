import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_movement_report.dart';
import 'movement_direction_visuals.dart';

/// Status pill for the movement type shown in a stock movement report row.
class InventoryStockMovementReportTypePill extends StatelessWidget {
  const InventoryStockMovementReportTypePill({super.key, required this.line});

  final InventoryStockMovementReportLine line;

  @override
  Widget build(BuildContext context) {
    final style = movementDirectionVisuals(context, line.direction);
    return AppStatusPill(
      label: line.typeLabel,
      icon: style.icon,
      color: style.color,
      maxWidth: 140,
    );
  }
}
