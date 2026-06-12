import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_draft.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('warehouse draft normalizes warehouse values', () {
    const draft = InventoryWarehouseDraft(
      name: '  East Hub  ',
      branchId: 'branch-bandung-retail',
      branchName: '  Bandung Retail  ',
      location: '  Bandung  ',
      description: '  Cold storage  ',
      capacity: 1200,
    );

    final warehouse = draft.toWarehouse(id: 'w1');

    expect(warehouse.id, 'w1');
    expect(warehouse.name, 'East Hub');
    expect(warehouse.branchId, 'branch-bandung-retail');
    expect(warehouse.branchName, 'Bandung Retail');
    expect(warehouse.location, 'Bandung');
    expect(warehouse.description, 'Cold storage');
    expect(warehouse.capacity, 1200);
  });

  test('warehouse draft converts empty description to null', () {
    const draft = InventoryWarehouseDraft(
      name: 'Main',
      location: 'Jakarta',
      description: '   ',
    );

    expect(draft.toWarehouse(id: 'w1').description, isNull);
  });

  test('warehouse draft validates required fields and capacity', () {
    expect(
      validateInventoryWarehouseDraft(
        const InventoryWarehouseDraft(name: '', location: 'Jakarta'),
      ),
      InventoryWarehouseIssue.missingName,
    );
    expect(
      validateInventoryWarehouseDraft(
        const InventoryWarehouseDraft(name: 'Main', location: ''),
      ),
      InventoryWarehouseIssue.missingBranch,
    );
    expect(
      validateInventoryWarehouseDraft(
        const InventoryWarehouseDraft(
          name: 'Main',
          branchName: 'Jakarta Central',
          location: '',
        ),
      ),
      InventoryWarehouseIssue.missingLocation,
    );
    expect(
      validateInventoryWarehouseDraft(
        const InventoryWarehouseDraft(
          name: 'Main',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
          capacity: -1,
        ),
      ),
      InventoryWarehouseIssue.invalidCapacity,
    );
    expect(
      validateInventoryWarehouseDraft(
        const InventoryWarehouseDraft(
          name: 'Main',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
      ),
      isNull,
    );
  });

  test('warehouse draft can be created from a warehouse', () {
    final draft = InventoryWarehouseDraft.fromWarehouse(
      Warehouse(
        id: 'w1',
        name: 'Main Warehouse',
        branchId: 'branch-jakarta-central',
        branchName: 'Jakarta Central',
        location: 'Jakarta',
        description: 'Primary stock room',
        capacity: 500,
      ),
    );

    expect(draft.name, 'Main Warehouse');
    expect(draft.branchId, 'branch-jakarta-central');
    expect(draft.branchName, 'Jakarta Central');
    expect(draft.location, 'Jakarta');
    expect(draft.description, 'Primary stock room');
    expect(draft.capacity, 500);
  });
}
