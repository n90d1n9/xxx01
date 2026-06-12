import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import '../utils/inventory_formatters.dart';
import 'branch_preview_data.dart';
import 'inventory_branch_metric_components.dart';

/// Compact metric strip showing branch location, governance, and assignments.
class InventoryBranchTileMetricStrip extends StatelessWidget {
  const InventoryBranchTileMetricStrip({
    super.key,
    required this.branch,
    required this.warehouseCount,
  });

  final InventoryBranch branch;
  final int warehouseCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryBranchMetric(
          label: 'City',
          value: branch.cityLabel,
          icon: Icons.location_city_rounded,
        ),
        InventoryBranchMetric(
          label: 'Region',
          value: branch.regionLabel,
          icon: Icons.map_rounded,
        ),
        InventoryBranchMetric(
          label: 'Type',
          value: inventoryBranchTypeLabel(branch.type),
          icon: Icons.category_rounded,
        ),
        InventoryBranchMetric(
          label: 'Manager',
          value: branch.managerLabel,
          icon: Icons.manage_accounts_rounded,
        ),
        InventoryBranchMetric(
          label: 'People',
          value: formatInventoryNumber(branch.employeeCount),
          icon: Icons.groups_rounded,
        ),
        InventoryBranchMetric(
          label: 'Warehouses',
          value: formatInventoryNumber(warehouseCount),
          icon: Icons.warehouse_rounded,
        ),
        InventoryBranchMetric(
          label: 'Compliance',
          value: inventoryBranchComplianceTierLabel(branch.complianceTier),
          icon: Icons.policy_rounded,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch tile metrics')
Widget inventoryBranchTileMetricStripPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchTileMetricStrip(
      branch: inventoryBranchPreviewBranch(),
      warehouseCount: 3,
    ),
  );
}
