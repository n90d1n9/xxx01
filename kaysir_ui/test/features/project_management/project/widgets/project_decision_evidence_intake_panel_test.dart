import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_evidence_intake_panel.dart';

void main() {
  testWidgets('decision evidence intake panel validates and queues proof', (
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
              child: ProjectDecisionEvidenceIntakePanel(
                registerSummary: workspace.decisionRegisterSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision evidence intake'), findsOneWidget);
    expect(find.text('Evidence queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Evidence'));
    await tester.tap(find.text('Queue Evidence'));
    await tester.pump();

    expect(find.text('Evidence title is required.'), findsOneWidget);
    expect(find.text('Reference is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('decision-evidence-title')),
      'Signed sponsor decision memo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-evidence-reference')),
      'DOC-DEC-001',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-evidence-note')),
      'Attach the signed sponsor memo, approval route, and evidence owner for the next review.',
    );
    await tester.ensureVisible(find.text('Queue Evidence'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Evidence'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Evidence queue empty'), findsNothing);
  });
}
