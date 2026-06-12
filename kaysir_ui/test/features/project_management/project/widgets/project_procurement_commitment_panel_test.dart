import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_procurement_commitment_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_procurement_commitment_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('procurement commitment panel renders commitment queue', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectProcurementCommitmentSummary(workspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1040,
              child: ProjectProcurementCommitmentPanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Procurement commitments blocked'), findsOneWidget);
    expect(find.text('Procurement readiness'), findsOneWidget);
    expect(find.text('Sensors and scanners'), findsOneWidget);
    expect(find.text('Integration vendor'), findsOneWidget);
    expect(find.text('Vendor commitment authority'), findsOneWidget);
    expect(find.text('Hold package'), findsWidgets);
  });
}
