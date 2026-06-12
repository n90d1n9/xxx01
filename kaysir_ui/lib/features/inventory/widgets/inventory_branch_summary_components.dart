import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_branch.dart';
import '../utils/inventory_formatters.dart';

class InventoryBranchSummary extends StatelessWidget {
  const InventoryBranchSummary({
    super.key,
    required this.branches,
    required this.warehouseCountByBranchId,
  });

  final List<InventoryBranch> branches;
  final Map<String, int> warehouseCountByBranchId;

  @override
  Widget build(BuildContext context) {
    final activeCount =
        branches
            .where((branch) => branch.status == InventoryBranchStatus.active)
            .length;
    final planningCount =
        branches
            .where((branch) => branch.status == InventoryBranchStatus.planning)
            .length;
    final linkedWarehouses = warehouseCountByBranchId.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final staffedCount =
        branches.where((branch) => branch.managerName.trim().isNotEmpty).length;
    final legalEntityCount =
        branches
            .map((branch) => branch.legalEntity.trim())
            .where((entity) => entity.isNotEmpty)
            .toSet()
            .length;

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Branches',
          value: formatInventoryNumber(branches.length),
          helper: '${formatInventoryNumber(activeCount)} active',
          icon: Icons.account_tree_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Linked Warehouses',
          value: formatInventoryNumber(linkedWarehouses),
          helper: 'Warehouse assignments',
          icon: Icons.warehouse_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Planning',
          value: formatInventoryNumber(planningCount),
          helper: 'Branches not fully active',
          icon: Icons.pending_actions_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Staffed',
          value: '$staffedCount/${branches.length}',
          helper: 'Branches with managers',
          icon: Icons.manage_accounts_rounded,
          accentColor: Colors.indigo.shade700,
        ),
        AppMetricGridItem(
          title: 'Entities',
          value: formatInventoryNumber(legalEntityCount),
          helper: 'Legal company records',
          icon: Icons.account_balance_rounded,
          accentColor: Colors.deepPurple.shade700,
        ),
      ],
    );
  }
}
