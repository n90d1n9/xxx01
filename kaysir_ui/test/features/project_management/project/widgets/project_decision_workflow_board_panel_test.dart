import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_workflow_board_panel.dart';

void main() {
  testWidgets('decision workflow board panel renders stage lanes', (
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
              child: ProjectDecisionWorkflowBoardPanel(
                summary: workspace.decisionWorkflowBoardSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('active decisions in workflow'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Awaiting'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Workflow snapshot'), findsOneWidget);
    expect(find.textContaining('Workflow stages:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
