import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_evidence_vault_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_evidence_vault_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('evidence vault panel renders readiness and records', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectEvidenceVaultSummary(
      workspace,
      today: DateTime(2026, 7, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 920,
              child: ProjectEvidenceVaultPanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Evidence vault blocked'), findsOneWidget);
    expect(find.text('Evidence readiness'), findsOneWidget);
    expect(find.text('Sensor freight acceleration'), findsOneWidget);
    expect(find.text('Freight exception evidence'), findsOneWidget);
    expect(find.textContaining('Sponsor approval'), findsWidgets);
  });
}
