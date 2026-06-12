import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_impact_matrix_panel.dart';

void main() {
  testWidgets('decision impact matrix panel renders prioritized impacts', (
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
              child: ProjectDecisionImpactMatrixPanel(
                summary: workspace.decisionImpactMatrixSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('decision impact index'), findsOneWidget);
    expect(find.text('Impact Index'), findsOneWidget);
    expect(find.text('Severe'), findsWidgets);
    expect(find.text('High'), findsWidgets);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('Decision impact brief'), findsOneWidget);
    expect(find.textContaining('Impact priorities:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
