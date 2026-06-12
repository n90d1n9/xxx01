import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_brief_pack_panel.dart';

void main() {
  testWidgets('decision brief pack panel renders copy-ready context', (
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
              child: ProjectDecisionBriefPackPanel(
                summary: workspace.decisionBriefPackSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Retail Modernization decision brief pack'), findsWidgets);
    expect(find.text('Primary decision'), findsOneWidget);
    expect(find.text('Owner focus'), findsOneWidget);
    expect(find.text('Governance route'), findsOneWidget);
    expect(find.text('Decision brief pack'), findsOneWidget);
    expect(find.textContaining('Highlights:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
