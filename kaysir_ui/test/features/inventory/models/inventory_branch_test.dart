import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';

void main() {
  test('inventory branch serializes status metadata', () {
    const branch = InventoryBranch(
      id: 'b1',
      name: 'Jakarta Central',
      city: 'Jakarta',
      managerName: 'Rina Wijaya',
      contact: 'jakarta.ops@kaysir.local',
      code: 'JKT-HQ',
      region: 'Java West',
      legalEntity: 'PT Kaysir Nusantara',
      type: InventoryBranchType.headquarters,
      complianceTier: InventoryBranchComplianceTier.monitored,
      employeeCount: 52,
      status: InventoryBranchStatus.planning,
      notes: 'Expansion branch',
    );

    final json = branch.toJson();
    final restored = InventoryBranch.fromJson(json);

    expect(json['status'], 'planning');
    expect(json['type'], 'headquarters');
    expect(json['complianceTier'], 'monitored');
    expect(restored.nameLabel, 'Jakarta Central');
    expect(restored.codeLabel, 'JKT-HQ');
    expect(restored.legalEntityLabel, 'PT Kaysir Nusantara');
    expect(restored.status, InventoryBranchStatus.planning);
    expect(restored.type, InventoryBranchType.headquarters);
    expect(restored.complianceTier, InventoryBranchComplianceTier.monitored);
    expect(restored.employeeCount, 52);
    expect(restored.managerLabel, 'Rina Wijaya');
  });

  test('inventory branch falls back to active status for legacy records', () {
    final branch = InventoryBranch.fromJson({
      'id': 'b1',
      'name': 'Legacy Branch',
      'city': 'Jakarta',
    });

    expect(branch.status, InventoryBranchStatus.active);
    expect(branch.type, InventoryBranchType.branchOffice);
    expect(branch.complianceTier, InventoryBranchComplianceTier.standard);
    expect(branch.codeLabel, 'No code');
    expect(branch.managerLabel, 'No manager');
    expect(branch.contactLabel, 'No contact');
  });

  test('inventory branch normalizes invalid employee count metadata', () {
    final branch = InventoryBranch.fromJson({
      'id': 'b1',
      'name': 'Legacy Branch',
      'city': 'Jakarta',
      'employeeCount': '-8',
    });

    expect(branch.employeeCount, 0);
  });
}
