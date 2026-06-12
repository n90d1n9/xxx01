import 'package:flutter/material.dart';

import '../models/inventory_branch_filter.dart';
import '../models/warehouse.dart';
import 'inventory_branch_filter.dart';

class InventoryStockBranchFilter extends StatelessWidget {
  const InventoryStockBranchFilter({
    super.key,
    required this.branchLabels,
    this.branchOptions,
    required this.selectedBranch,
    required this.onChanged,
  });

  final List<String> branchLabels;
  final List<InventoryBranchFilterOption>? branchOptions;
  final String? selectedBranch;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryBranchSelectField(
      branchLabels: branchLabels,
      branchOptions: branchOptions,
      selectedBranch: selectedBranch,
      onChanged: onChanged,
    );
  }
}

class InventoryStockWarehouseFilter extends StatelessWidget {
  const InventoryStockWarehouseFilter({
    super.key,
    required this.warehouses,
    required this.selectedWarehouseId,
    required this.onChanged,
  });

  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryWarehouseSelectField(
      warehouses: warehouses,
      selectedWarehouseId: selectedWarehouseId,
      onChanged: onChanged,
    );
  }
}
