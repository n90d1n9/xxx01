import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Status pill showing how many branch warehouses have tracked capacity.
class InventoryWarehouseBranchCapacityStatusPill extends StatelessWidget {
  const InventoryWarehouseBranchCapacityStatusPill({
    super.key,
    required this.trackedWarehouseCount,
  });

  final int trackedWarehouseCount;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '$trackedWarehouseCount tracked',
      icon: Icons.fact_check_rounded,
      color: Colors.indigo.shade700,
      maxWidth: 140,
    );
  }
}

@Preview(name: 'Warehouse branch capacity status pill')
Widget inventoryWarehouseBranchCapacityStatusPillPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchCapacityStatusPill(trackedWarehouseCount: 2),
  );
}
