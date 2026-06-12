import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_action_plan_panel.dart';

void main() {
  testWidgets('decision action plan panel renders owner accountability', (
    tester,
  ) async {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 920,
              child: ProjectDecisionActionPlanPanel(
                summary: workspace.decisionActionPlanSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision owners need attention'), findsOneWidget);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Awaiting'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Maya Santoso'), findsOneWidget);
    expect(find.text('Retail Operations'), findsOneWidget);
  });
}
