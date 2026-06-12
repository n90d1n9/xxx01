import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_cost_structure_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cost_structure_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('cost structure panel renders baseline categories', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: ProjectCostStructurePanel(
              summary: ProjectCostStructureSummary(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                profileLabel: 'Event production',
                budgetPaceLabel: 'Spend ahead of progress',
                lines: [
                  ProjectCostStructureLine(
                    id: 'venue-fit-out-vendor',
                    title: 'Venue and vendors',
                    detail:
                        'Needs Procurement before this baseline category becomes ledger-ready.',
                    category: ProjectCostStructureCategory.vendor,
                    plannedShare: 0.34,
                    level: ProjectCostStructureLevel.watch,
                    icon: Icons.inventory_2_outlined,
                  ),
                  ProjectCostStructureLine(
                    id: 'venue-fit-out-logistics',
                    title: 'Logistics and field ops',
                    detail:
                        'Needs Project Float before this baseline category becomes ledger-ready.',
                    category: ProjectCostStructureCategory.logistics,
                    plannedShare: 0.17,
                    level: ProjectCostStructureLevel.watch,
                    icon: Icons.local_shipping_outlined,
                  ),
                  ProjectCostStructureLine(
                    id: 'venue-fit-out-reserve',
                    title: 'Event reserve',
                    detail:
                        'Needs Approval Policy before this baseline category becomes ledger-ready.',
                    category: ProjectCostStructureCategory.contingency,
                    plannedShare: 0.15,
                    level: ProjectCostStructureLevel.ready,
                    icon: Icons.savings_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Cost controls need attention'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);
    expect(find.text('Venue and vendors (34%)'), findsOneWidget);
    expect(find.text('Logistics and field ops (17%)'), findsOneWidget);
    expect(find.textContaining('Needs Procurement'), findsOneWidget);
    expect(find.text('Watch'), findsWidgets);
  });
}
