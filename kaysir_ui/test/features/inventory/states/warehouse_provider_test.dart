import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_branch_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';

void main() {
  test('default warehouses are linked to seeded branches', () {
    final notifier = WarehousesNotifier();

    expect(notifier.state.map((warehouse) => warehouse.branchId), [
      inventoryBranchJakartaCentralId,
      inventoryBranchSurabayaNorthId,
      inventoryBranchBandungSouthId,
    ]);
  });

  test('warehouse branch labels can be refreshed by branch id', () {
    final notifier =
        WarehousesNotifier()
          ..state = [
            Warehouse(
              id: 'w1',
              name: 'Main Warehouse',
              branchId: 'b1',
              branchName: 'Jakarta Central',
              location: 'Jakarta',
            ),
            Warehouse(
              id: 'w2',
              name: 'North Warehouse',
              branchId: 'b2',
              branchName: 'Surabaya North',
              location: 'Surabaya',
            ),
          ];

    notifier.updateBranchLabel(branchId: 'b1', branchName: 'Jakarta HQ');

    expect(notifier.state.first.branchName, 'Jakarta HQ');
    expect(notifier.state.last.branchName, 'Surabaya North');
  });

  test('branch notifier supports directory CRUD', () {
    final notifier = InventoryBranchesNotifier();
    const branch = InventoryBranch(
      id: 'b-new',
      name: 'Bekasi Outlet',
      city: 'Bekasi',
      managerName: 'Dewi Lestari',
      contact: 'bekasi.ops@kaysir.local',
    );

    notifier.addBranch(branch);
    expect(notifier.state.last, branch);

    notifier.updateBranch(branch.copyWith(name: 'Bekasi Fulfillment'));
    expect(notifier.state.last.name, 'Bekasi Fulfillment');

    notifier.deleteBranch('b-new');
    expect(notifier.state.any((item) => item.id == 'b-new'), isFalse);
  });
}
