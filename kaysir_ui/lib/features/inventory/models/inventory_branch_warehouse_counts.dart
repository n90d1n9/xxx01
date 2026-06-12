import 'inventory_branch.dart';
import 'warehouse.dart';

/// Counts warehouse assignments keyed by branch id for branch workspaces.
Map<String, int> countInventoryWarehousesByBranchId({
  required List<InventoryBranch> branches,
  required List<Warehouse> warehouses,
}) {
  final counts = {for (final branch in branches) branch.id: 0};

  for (final warehouse in warehouses) {
    final branchId =
        warehouse.branchId ??
        inventoryBranchIdForWarehouseBranchName(
          branches: branches,
          branchName: warehouse.branchName,
        );
    if (branchId == null) continue;

    counts[branchId] = (counts[branchId] ?? 0) + 1;
  }

  return counts;
}

/// Resolves a warehouse branch label to a known branch id using normalized names.
String? inventoryBranchIdForWarehouseBranchName({
  required List<InventoryBranch> branches,
  required String branchName,
}) {
  final normalized = _normalizedBranchName(branchName);
  for (final branch in branches) {
    if (_normalizedBranchName(branch.name) == normalized) {
      return branch.id;
    }
  }

  return null;
}

String _normalizedBranchName(String value) {
  return value.trim().toLowerCase();
}
