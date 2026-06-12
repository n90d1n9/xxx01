import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_briefing_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_briefing_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project portfolio briefing panel renders board signals', (
    tester,
  ) async {
    String? openedProjectId;
    final summary = buildProjectPortfolioBriefing(
      projects: demoProjectPortfolio,
      totalProjectCount: demoProjectPortfolio.length,
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectPortfolioBriefingPanel(
              summary: summary,
              onOpenProject: (projectId) => openedProjectId = projectId,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Unblock Mobile Field App'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('In View'), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('Domain Gaps'), findsOneWidget);
    expect(find.text('Mobile Field App domain context'), findsOneWidget);
    expect(find.textContaining('Repository, API Contract'), findsOneWidget);
    expect(find.text('API contract drift'), findsOneWidget);
    expect(find.text('API Ready'), findsOneWidget);
    expect(find.textContaining('Due in 11d'), findsWidgets);
    expect(find.byType(AppMetricGrid), findsOneWidget);

    await tester.tap(find.text('Open Project'));
    expect(openedProjectId, 'mobile-field-app');
  });

  testWidgets('project portfolio briefing panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectPortfolioBriefingPanel(
            summary: buildProjectPortfolioBriefing(
              projects: const [],
              totalProjectCount: demoProjectPortfolio.length,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No projects in this view'), findsOneWidget);
  });
}
