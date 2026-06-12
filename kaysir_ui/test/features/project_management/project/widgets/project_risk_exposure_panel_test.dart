import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_exposure_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_exposure_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project risk exposure panel renders portfolio risk signals', (
    tester,
  ) async {
    String? openedProjectId;
    final summary = ProjectRiskExposureSummary(
      items: [
        ProjectRiskExposureItem(
          projectId: 'mobile',
          projectName: 'Mobile Field App',
          projectHealth: ProjectHealth.blocked,
          title: 'API contract drift',
          detail: 'Payload contract is not signed.',
          severity: ProjectHealth.blocked,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectRiskExposurePanel(
                summary: summary,
                onOpenProject: (projectId) => openedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Risk Exposure Critical'), findsOneWidget);
    expect(find.text('Active Risks'), findsOneWidget);
    expect(find.text('API contract drift'), findsOneWidget);
    expect(
      find.textContaining('Mobile Field App needs attention'),
      findsOneWidget,
    );

    await tester.tap(find.text('Project'));
    expect(openedProjectId, 'mobile');
  });

  testWidgets('project risk exposure panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectRiskExposurePanel(
            summary: ProjectRiskExposureSummary(items: []),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No portfolio risks'), findsOneWidget);
  });
}
