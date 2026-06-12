import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('warehouse serializes branch metadata', () {
    final warehouse = Warehouse(
      id: 'w1',
      name: 'Main Warehouse',
      branchId: 'branch-jakarta-central',
      branchName: 'Jakarta Central',
      location: 'Jakarta',
      description: 'Primary stock room',
      capacity: 500,
    );

    final json = warehouse.toJson();
    final restored = Warehouse.fromJson(json);

    expect(json['branchId'], 'branch-jakarta-central');
    expect(json['branchName'], 'Jakarta Central');
    expect(restored.branchId, 'branch-jakarta-central');
    expect(restored.branchName, 'Jakarta Central');
    expect(restored.branchLabel, 'Jakarta Central');
  });

  test('warehouse falls back to main branch for legacy records', () {
    final warehouse = Warehouse.fromJson({
      'id': 'w1',
      'name': 'Legacy Warehouse',
      'location': 'Jakarta',
    });

    expect(warehouse.branchName, inventoryDefaultWarehouseBranchName);
    expect(warehouse.branchLabel, inventoryDefaultWarehouseBranchName);
  });
}
