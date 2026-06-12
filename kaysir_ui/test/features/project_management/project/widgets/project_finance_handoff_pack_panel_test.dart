import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_handoff_pack_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance handoff pack panel renders package sections', (
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
              child: ProjectFinanceHandoffPackPanel(
                summary: buildProjectFinanceWorkspaceSummary(project!),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Finance handoff pack needs review'), findsOneWidget);
    expect(find.text('Finance handoff brief'), findsOneWidget);
    expect(find.text('Recipients'), findsOneWidget);
    expect(find.text('Executive finance summary'), findsOneWidget);
    expect(find.text('Ledger bundle'), findsOneWidget);
    expect(find.text('Closeout checklist'), findsOneWidget);
    expect(find.textContaining('Recovery Plan'), findsWidgets);
  });
}
