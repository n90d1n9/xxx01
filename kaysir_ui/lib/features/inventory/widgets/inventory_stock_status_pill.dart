import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_status_visuals.dart';

export 'inventory_quantity_badge.dart';
export 'inventory_stock_status_visuals.dart';

/// Compact status indicator for an inventory stock record state.
class InventoryStockStatusPill extends StatelessWidget {
  const InventoryStockStatusPill({super.key, required this.status});

  final InventoryStockStatus status;

  @override
  Widget build(BuildContext context) {
    final style = inventoryStockStatusVisuals(context, status);
    return AppStatusPill(
      label: style.label,
      icon: style.icon,
      color: style.color,
      maxWidth: 150,
    );
  }
}
