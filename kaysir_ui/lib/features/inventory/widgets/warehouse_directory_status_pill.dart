import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'warehouse_directory_preview_data.dart';

/// Active warehouse count pill for the warehouse directory panel.
class InventoryWarehouseDirectoryStatusPill extends StatelessWidget {
  const InventoryWarehouseDirectoryStatusPill({
    super.key,
    required this.activeCount,
  });

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '$activeCount active',
      icon: Icons.check_circle_outline_rounded,
      color: Colors.green.shade700,
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Warehouse directory status')
Widget inventoryWarehouseDirectoryStatusPillPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    const InventoryWarehouseDirectoryStatusPill(activeCount: 2),
  );
}
