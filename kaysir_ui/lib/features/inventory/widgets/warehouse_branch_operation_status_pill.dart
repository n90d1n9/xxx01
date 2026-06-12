import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Status pill summarizing how many warehouse locations are in the branch.
class InventoryWarehouseBranchOperationStatusPill extends StatelessWidget {
  const InventoryWarehouseBranchOperationStatusPill({
    super.key,
    required this.operationCount,
  });

  final int operationCount;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '$operationCount locations',
      icon: Icons.location_city_rounded,
      color: Colors.blue.shade700,
      maxWidth: 140,
    );
  }
}

@Preview(name: 'Warehouse branch operation status pill')
Widget inventoryWarehouseBranchOperationStatusPillPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchOperationStatusPill(operationCount: 3),
  );
}
