import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_closeout_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance closeout panel renders readiness checklist', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 880,
              child: ProjectFinanceCloseoutPanel(
                summary: buildProjectFinanceWorkspaceSummary(project!),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Finance closeout needs attention'), findsOneWidget);
    expect(find.text('Closeout readiness'), findsOneWidget);
    expect(find.text('17%'), findsWidgets);
    expect(find.text('Ledger records'), findsOneWidget);
    expect(find.text('Finance action queue'), findsOneWidget);
    expect(find.text('Reconciliation evidence'), findsOneWidget);
    expect(find.text('Budget runway'), findsOneWidget);
  });
}
