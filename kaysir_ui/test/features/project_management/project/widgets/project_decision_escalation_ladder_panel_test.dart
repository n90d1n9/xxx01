import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_escalation_ladder_panel.dart';

void main() {
  testWidgets('decision escalation ladder panel renders tier lanes', (
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
              child: ProjectDecisionEscalationLadderPanel(
                summary: workspace.decisionEscalationLadderSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Escalation ladder'), findsOneWidget);
    expect(find.text('Sponsor'), findsWidgets);
    expect(find.text('Owner'), findsWidgets);
    expect(find.text('Team'), findsWidgets);
    expect(find.text('Monitor'), findsWidgets);
    expect(find.text('Escalation brief'), findsOneWidget);
    expect(find.textContaining('Escalation steps:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
