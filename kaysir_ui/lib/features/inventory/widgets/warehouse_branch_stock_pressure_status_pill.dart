import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Status pill summarizing branch stock pressure alert volume.
class InventoryWarehouseBranchStockPressureStatusPill extends StatelessWidget {
  const InventoryWarehouseBranchStockPressureStatusPill({
    super.key,
    required this.alertCount,
  });

  final int alertCount;

  @override
  Widget build(BuildContext context) {
    if (alertCount == 0) {
      return AppStatusPill(
        label: 'Healthy',
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green.shade700,
        maxWidth: 120,
      );
    }

    return AppStatusPill(
      label: '$alertCount alerts',
      icon: Icons.warning_amber_rounded,
      color: Colors.deepOrange.shade700,
      maxWidth: 120,
    );
  }
}

@Preview(name: 'Warehouse branch stock pressure status pill')
Widget inventoryWarehouseBranchStockPressureStatusPillPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchStockPressureStatusPill(alertCount: 2),
  );
}
