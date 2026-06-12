import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_funding_release_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_funding_release_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('funding release panel renders release gates', (tester) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectFundingReleaseSummary(workspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1040,
              child: ProjectFundingReleasePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Funding releases blocked'), findsOneWidget);
    expect(find.text('Release readiness'), findsOneWidget);
    expect(find.text('Active funding window'), findsOneWidget);
    expect(find.text('Reserve guardrail'), findsOneWidget);
    expect(find.text('Hold release'), findsWidgets);
    expect(find.text('Reserve'), findsWidgets);
  });
}
