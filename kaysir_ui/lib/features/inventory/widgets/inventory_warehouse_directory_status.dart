import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/warehouse.dart';
import 'warehouse_directory_preview_data.dart';

/// Capacity tracking status pill for a warehouse directory row.
class InventoryWarehouseCapacityStatusPill extends StatelessWidget {
  const InventoryWarehouseCapacityStatusPill({
    super.key,
    required this.warehouse,
  });

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final hasCapacity = warehouse.capacity != null;

    return AppStatusPill(
      label: hasCapacity ? 'Capacity tracked' : 'Capacity needed',
      icon: hasCapacity ? Icons.fact_check_rounded : Icons.help_outline_rounded,
      color: hasCapacity ? Colors.green.shade700 : Colors.orange.shade700,
      maxWidth: 160,
    );
  }
}

@Preview(name: 'Warehouse directory capacity status')
Widget inventoryWarehouseCapacityStatusPillPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseCapacityStatusPill(
      warehouse: inventoryWarehouseDirectoryPreviewWarehouse(),
    ),
  );
}
