import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_review_flow_panel.dart';

void main() {
  testWidgets('decision review flow panel validates and queues an outcome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
              width: 960,
              child: ProjectDecisionReviewFlowPanel(
                registerSummary: workspace.decisionRegisterSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision review flow'), findsOneWidget);
    expect(find.text('Review queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Outcome'));
    await tester.tap(find.text('Queue Outcome'));
    await tester.pump();

    expect(
      find.text('Review note should explain the decision outcome.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('decision-review-owner')),
      'Aisyah Rahman',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-review-evidence')),
      'Signed review evidence',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-review-note')),
      'Queue this review outcome after confirming owner accountability, evidence, and route.',
    );
    await tester.ensureVisible(find.text('Queue Outcome'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Outcome'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Review queue empty'), findsNothing);
  });
}
