import 'warehouse.dart';

enum InventoryWarehouseIssue {
  missingName,
  missingBranch,
  missingLocation,
  invalidCapacity,
}

class InventoryWarehouseDraft {
  const InventoryWarehouseDraft({
    required this.name,
    this.branchId,
    this.branchName = '',
    required this.location,
    this.description = '',
    this.capacity,
  });

  final String name;
  final String? branchId;
  final String branchName;
  final String location;
  final String description;
  final num? capacity;

  factory InventoryWarehouseDraft.fromWarehouse(Warehouse warehouse) {
    return InventoryWarehouseDraft(
      name: warehouse.name,
      branchId: warehouse.branchId,
      branchName: warehouse.branchName,
      location: warehouse.location,
      description: warehouse.description ?? '',
      capacity: warehouse.capacity,
    );
  }

  Warehouse toWarehouse({required String id}) {
    return Warehouse(
      id: id,
      name: name.trim(),
      branchId: branchId,
      branchName: _normalizedBranchName,
      location: location.trim(),
      description: _normalizedDescription,
      capacity: capacity,
    );
  }

  String? get _normalizedDescription {
    final value = description.trim();
    return value.isEmpty ? null : value;
  }

  String get _normalizedBranchName {
    final value = branchName.trim();
    return value.isEmpty ? inventoryDefaultWarehouseBranchName : value;
  }
}

InventoryWarehouseIssue? validateInventoryWarehouseDraft(
  InventoryWarehouseDraft draft,
) {
  if (draft.name.trim().isEmpty) {
    return InventoryWarehouseIssue.missingName;
  }
  if (draft.branchName.trim().isEmpty) {
    return InventoryWarehouseIssue.missingBranch;
  }
  if (draft.location.trim().isEmpty) {
    return InventoryWarehouseIssue.missingLocation;
  }
  final capacity = draft.capacity;
  if (capacity != null && capacity < 0) {
    return InventoryWarehouseIssue.invalidCapacity;
  }

  return null;
}

String inventoryWarehouseIssueLabel(InventoryWarehouseIssue issue) {
  switch (issue) {
    case InventoryWarehouseIssue.missingName:
      return 'Enter a warehouse name.';
    case InventoryWarehouseIssue.missingBranch:
      return 'Enter the branch this warehouse belongs to.';
    case InventoryWarehouseIssue.missingLocation:
      return 'Enter a warehouse location.';
    case InventoryWarehouseIssue.invalidCapacity:
      return 'Capacity cannot be negative.';
  }
}
