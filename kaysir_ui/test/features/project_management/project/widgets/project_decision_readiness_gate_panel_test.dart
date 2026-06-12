import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_readiness_gate_panel.dart';

void main() {
  testWidgets('decision readiness gate panel renders score and lanes', (
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
              child: ProjectDecisionReadinessGatePanel(
                summary: workspace.decisionReadinessGateSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Decision readiness'), findsOneWidget);
    expect(find.text('Readiness Score'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Decision'), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Readiness brief'), findsOneWidget);
    expect(find.textContaining('Readiness lanes:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
