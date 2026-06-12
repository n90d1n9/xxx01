import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_register_panel.dart';

void main() {
  testWidgets('decision register panel renders and filters records', (
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
              child: ProjectDecisionRegisterPanel(
                summary: workspace.decisionRegisterSummary,
                maxRows: 20,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('decision records tracked'), findsOneWidget);
    expect(find.text('Store readiness'), findsOneWidget);
    expect(find.text('Confirm Store Cluster'), findsOneWidget);
    expect(find.text('Confirm Pilot'), findsOneWidget);

    await tester.tap(find.text('Domain'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Store Cluster'), findsOneWidget);
    expect(find.text('Store readiness'), findsNothing);

    await tester.tap(find.text('Risks'));
    await tester.pumpAndSettle();

    expect(find.text('Store readiness'), findsOneWidget);
    expect(find.text('Confirm Store Cluster'), findsNothing);
  });
}
