import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch_filter.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('inventory branch helpers build labels and sanitize filters', () {
    final warehouses = [
      Warehouse(
        id: 'w1',
        name: 'Main Warehouse',
        branchId: 'branch-jakarta',
        branchName: 'Jakarta Central',
        location: 'Jakarta',
      ),
      Warehouse(
        id: 'w2',
        name: 'North Warehouse',
        branchId: 'branch-surabaya',
        branchName: 'Surabaya North',
        location: 'Surabaya',
      ),
      Warehouse(
        id: 'w3',
        name: 'Overflow',
        branchId: 'branch-jakarta',
        branchName: 'Jakarta Central',
        location: 'Jakarta',
      ),
    ];

    final branches = inventoryBranchLabelsForWarehouses(warehouses);
    final branchOptions = inventoryBranchOptionsForWarehouses(warehouses);

    expect(branches, ['Jakarta Central', 'Surabaya North']);
    expect(branchOptions.map((option) => option.value), [
      'branch-jakarta',
      'branch-surabaya',
    ]);
    expect(
      inventoryValidBranchFilterValue('surabaya north', branchOptions),
      'branch-surabaya',
    );
    expect(
      inventoryValidBranchFilterValue('Missing Branch', branchOptions),
      isNull,
    );
    expect(
      filterInventoryWarehousesByBranch(
        warehouses,
        selectedBranch: 'branch-jakarta',
      ).map((warehouse) => warehouse.id),
      ['w1', 'w3'],
    );
    expect(
      filterInventoryWarehousesByBranch(
        warehouses,
        selectedBranch: 'jakarta central',
      ).map((warehouse) => warehouse.id),
      ['w1', 'w3'],
    );
  });
}
