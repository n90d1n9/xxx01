import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/company_branch_governance.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';

void main() {
  test('company branch governance summarizes readiness and risks', () {
    final summary = CompanyBranchGovernanceSummary.fromBranches(
      branches: const [
        InventoryBranch(
          id: 'b1',
          name: 'Jakarta Central',
          city: 'Jakarta',
          managerName: 'Rina Wijaya',
          contact: 'jakarta.ops@kaysir.local',
          code: 'JKT-HQ',
          region: 'Java West',
          legalEntity: 'PT Kaysir Nusantara',
          type: InventoryBranchType.headquarters,
          employeeCount: 52,
        ),
        InventoryBranch(
          id: 'b2',
          name: 'Bandung Retail',
          city: 'Bandung',
          managerName: '',
          contact: 'bandung.ops@kaysir.local',
          code: '',
          region: 'Java West',
          legalEntity: 'PT Kaysir Retail Indonesia',
          type: InventoryBranchType.retailOutlet,
          complianceTier: InventoryBranchComplianceTier.restricted,
          status: InventoryBranchStatus.planning,
        ),
      ],
      warehouseCountByBranchId: const {'b1': 1, 'b2': 0},
    );

    final ready = summary.items.first;
    final blocked = summary.items.last;

    expect(summary.totalBranches, 2);
    expect(summary.readyCount, 1);
    expect(summary.riskCount, 1);
    expect(summary.legalEntityCount, 2);
    expect(summary.employeeCount, 52);
    expect(summary.nextAction, 'Resolve Bandung Retail governance blockers.');
    expect(ready.readinessScore, 100);
    expect(ready.isReady, isTrue);
    expect(blocked.isBlocked, isTrue);
    expect(blocked.issues, contains('Missing branch code'));
    expect(
      blocked.issues,
      contains('Restricted compliance tier blocks expansion'),
    );
  });
}
