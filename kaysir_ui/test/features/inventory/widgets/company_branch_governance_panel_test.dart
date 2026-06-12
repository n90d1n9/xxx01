import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/company_branch_governance.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/widgets/company_branch_governance_panel.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('company governance panel renders readiness and risks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
          complianceTier: InventoryBranchComplianceTier.restricted,
        ),
      ],
      warehouseCountByBranchId: const {'b1': 1, 'b2': 0},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyBranchGovernancePanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(CompanyBranchGovernanceStatusPill), findsOneWidget);
    expect(find.byType(CompanyBranchGovernanceMetricGrid), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(CompanyBranchGovernanceTileList), findsOneWidget);
    expect(find.byType(CompanyBranchGovernanceTile), findsNWidgets(2));
    expect(find.byType(CompanyBranchGovernanceReadinessPill), findsNWidgets(2));
    expect(find.byType(CompanyBranchGovernanceDetails), findsNWidgets(2));
    expect(find.text('Company Management'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Bandung Retail'), findsOneWidget);
    expect(find.text('Restricted'), findsOneWidget);
    expect(find.text('Missing branch code'), findsOneWidget);
  });
}
