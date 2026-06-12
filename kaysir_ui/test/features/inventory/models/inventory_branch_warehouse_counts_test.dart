import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_branch_warehouse_counts.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('counts warehouses by direct branch id and branch name fallback', () {
    final counts = countInventoryWarehousesByBranchId(
      branches: _branches,
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchId: 'b1',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
        Warehouse(
          id: 'w2',
          name: 'Retail Warehouse',
          branchName: ' bandung retail ',
          location: 'Bandung',
        ),
      ],
    );

    expect(counts['b1'], 1);
    expect(counts['b2'], 1);
  });

  test('preserves unknown branch ids while ignoring unknown branch labels', () {
    final counts = countInventoryWarehousesByBranchId(
      branches: _branches,
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Unknown Id Warehouse',
          branchId: 'unknown-branch',
          branchName: 'Unknown',
          location: 'Jakarta',
        ),
        Warehouse(
          id: 'w2',
          name: 'Unknown Label Warehouse',
          branchName: 'No Matching Branch',
          location: 'Bekasi',
        ),
      ],
    );

    expect(counts['b1'], 0);
    expect(counts['b2'], 0);
    expect(counts['unknown-branch'], 1);
    expect(counts.containsValue(2), isFalse);
  });

  test('resolves warehouse branch labels to known branch ids', () {
    expect(
      inventoryBranchIdForWarehouseBranchName(
        branches: _branches,
        branchName: ' JAKARTA CENTRAL ',
      ),
      'b1',
    );
    expect(
      inventoryBranchIdForWarehouseBranchName(
        branches: _branches,
        branchName: 'Unknown',
      ),
      isNull,
    );
  });
}

const _branches = [
  InventoryBranch(
    id: 'b1',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina Wijaya',
    contact: 'jakarta.ops@kaysir.local',
  ),
  InventoryBranch(
    id: 'b2',
    name: 'Bandung Retail',
    city: 'Bandung',
    managerName: 'Maya Lestari',
    contact: 'bandung.ops@kaysir.local',
  ),
];
