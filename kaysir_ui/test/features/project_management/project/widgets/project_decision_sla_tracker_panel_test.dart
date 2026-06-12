import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_sla_tracker_panel.dart';

void main() {
  testWidgets('decision SLA tracker panel renders timing lanes', (
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
              child: ProjectDecisionSlaTrackerPanel(
                summary: workspace.decisionSlaTrackerSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Decision SLA'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Next 7d'), findsWidgets);
    expect(find.text('On track'), findsWidgets);
    expect(find.text('SLA brief'), findsOneWidget);
    expect(find.textContaining('SLA lanes:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
