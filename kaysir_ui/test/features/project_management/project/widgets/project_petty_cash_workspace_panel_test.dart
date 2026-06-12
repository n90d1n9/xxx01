import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_petty_cash_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_petty_cash_workspace_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('petty cash workspace panel renders controls and entries', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectPettyCashWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 20),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 880,
              child: ProjectPettyCashWorkspacePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Petty cash reconciliation active'), findsOneWidget);
    expect(find.text('Petty cash controls'), findsOneWidget);
    expect(find.text('Pilot store project float'), findsOneWidget);
    expect(find.textContaining('Maya Santoso'), findsWidgets);
    expect(find.textContaining('Attach receipts'), findsWidgets);
    expect(find.textContaining('Configure project float'), findsWidgets);
  });
}
