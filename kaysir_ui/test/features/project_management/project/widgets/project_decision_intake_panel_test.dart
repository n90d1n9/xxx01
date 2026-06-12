import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_intake_panel.dart';

void main() {
  testWidgets('decision intake panel validates and queues a draft', (
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
              child: ProjectDecisionIntakePanel(
                registerSummary: workspace.decisionRegisterSummary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision intake flow'), findsOneWidget);
    expect(find.text('Draft queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit Draft'));
    await tester.tap(find.text('Submit Draft'));
    await tester.pump();

    expect(find.text('Decision title is required.'), findsOneWidget);
    expect(find.text('Decision context is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('decision-intake-title')),
      'Approve site readiness gate',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-intake-detail')),
      'Confirm the owner, evidence, and timing needed before the next project milestone can continue.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-intake-owner')),
      'Aisyah Rahman',
    );
    await tester.enterText(
      find.byKey(const ValueKey('decision-intake-evidence')),
      'Readiness checklist',
    );
    await tester.ensureVisible(find.text('Submit Draft'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Submit Draft'));
    await tester.pump();

    expect(find.text('Approve site readiness gate'), findsWidgets);
    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Draft queue empty'), findsNothing);
  });
}
