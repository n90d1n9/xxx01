import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_branch_draft.dart';

void main() {
  test('branch draft normalizes and converts to branch', () {
    const draft = InventoryBranchDraft(
      name: '  Bandung Retail  ',
      city: '  Bandung  ',
      managerName: '  Maya  ',
      contact: '  bandung.ops@kaysir.local  ',
      code: '  BDG-ST  ',
      region: '  Java West  ',
      legalEntity: '  PT Kaysir Retail Indonesia  ',
      type: InventoryBranchType.retailOutlet,
      complianceTier: InventoryBranchComplianceTier.monitored,
      employeeCount: 18,
      status: InventoryBranchStatus.planning,
      notes: '  New site  ',
    );

    final branch = draft.toBranch(id: 'b1');

    expect(branch.name, 'Bandung Retail');
    expect(branch.city, 'Bandung');
    expect(branch.managerName, 'Maya');
    expect(branch.contact, 'bandung.ops@kaysir.local');
    expect(branch.code, 'BDG-ST');
    expect(branch.region, 'Java West');
    expect(branch.legalEntity, 'PT Kaysir Retail Indonesia');
    expect(branch.type, InventoryBranchType.retailOutlet);
    expect(branch.complianceTier, InventoryBranchComplianceTier.monitored);
    expect(branch.employeeCount, 18);
    expect(branch.notes, 'New site');
  });

  test('branch draft validates required fields', () {
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: '',
          city: '',
          managerName: '',
          contact: '',
        ),
      ),
      InventoryBranchIssue.missingName,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: '',
          managerName: '',
          contact: '',
        ),
      ),
      InventoryBranchIssue.missingCity,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: '',
          contact: '',
        ),
      ),
      InventoryBranchIssue.missingManager,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: '',
        ),
      ),
      InventoryBranchIssue.missingContact,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: 'rina@example.com',
        ),
      ),
      InventoryBranchIssue.missingCode,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: 'rina@example.com',
          code: 'JKT',
        ),
      ),
      InventoryBranchIssue.missingRegion,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: 'rina@example.com',
          code: 'JKT',
          region: 'Java West',
        ),
      ),
      InventoryBranchIssue.missingLegalEntity,
    );
    expect(
      validateInventoryBranchDraft(
        const InventoryBranchDraft(
          name: 'Branch',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: 'rina@example.com',
          code: 'JKT',
          region: 'Java West',
          legalEntity: 'PT Kaysir Nusantara',
          employeeCount: -1,
        ),
      ),
      InventoryBranchIssue.invalidEmployeeCount,
    );
  });

  test('branch draft can preload from branch', () {
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
      complianceTier: InventoryBranchComplianceTier.standard,
      employeeCount: 52,
      status: InventoryBranchStatus.active,
      notes: 'Primary branch',
    );

    final draft = InventoryBranchDraft.fromBranch(branch);

    expect(draft.name, 'Jakarta Central');
    expect(draft.city, 'Jakarta');
    expect(draft.code, 'JKT-HQ');
    expect(draft.region, 'Java West');
    expect(draft.legalEntity, 'PT Kaysir Nusantara');
    expect(draft.type, InventoryBranchType.headquarters);
    expect(draft.employeeCount, 52);
    expect(draft.status, InventoryBranchStatus.active);
    expect(draft.notes, 'Primary branch');
  });
}
