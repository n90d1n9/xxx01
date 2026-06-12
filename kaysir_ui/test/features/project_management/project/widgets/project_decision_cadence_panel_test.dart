import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_cadence_panel.dart';

void main() {
  testWidgets('decision cadence panel renders review rhythm and agenda', (
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
              child: ProjectDecisionCadencePanel(
                summary: workspace.decisionCadenceSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision cadence needs review'), findsOneWidget);
    expect(find.text('Cadence'), findsOneWidget);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Escalation'), findsOneWidget);
    expect(find.text('Review cadence'), findsOneWidget);
    expect(find.text('Escalation window'), findsOneWidget);
    expect(find.text('Run decision review'), findsOneWidget);
    expect(find.text('Cadence agenda'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
