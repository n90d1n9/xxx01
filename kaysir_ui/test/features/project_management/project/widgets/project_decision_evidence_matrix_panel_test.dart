import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_evidence_matrix_panel.dart';

void main() {
  testWidgets('decision evidence matrix panel renders proof readiness', (
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
              child: ProjectDecisionEvidenceMatrixPanel(
                summary: workspace.decisionEvidenceMatrixSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('decision proof items tracked'), findsOneWidget);
    expect(find.text('Missing'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Signed Off'), findsWidgets);
    expect(find.text('Decision evidence checklist'), findsOneWidget);
    expect(find.textContaining('Proof checklist:'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
