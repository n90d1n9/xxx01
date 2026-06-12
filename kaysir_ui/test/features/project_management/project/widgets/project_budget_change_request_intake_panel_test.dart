import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_change_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_change_request_intake_panel.dart';

void main() {
  testWidgets('budget change request panel validates and queues a change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectBudgetChangeWorkspaceSummary(financeWorkspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 960,
              child: ProjectBudgetChangeRequestIntakePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Budget change request flow'), findsOneWidget);
    expect(find.text('Budget change queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Change'));
    await tester.tap(find.text('Queue Change'));
    await tester.pump();

    expect(find.text('Budget change title is required.'), findsOneWidget);
    expect(find.text('Requested amount is required.'), findsOneWidget);
    expect(find.text('Impact note is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('budget-change-request-title')),
      'Sensor freight recovery variation',
    );
    await tester.enterText(
      find.byKey(const ValueKey('budget-change-request-owner')),
      'Rafi Prakoso',
    );
    await tester.enterText(
      find.byKey(const ValueKey('budget-change-request-amount')),
      '18000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('budget-change-request-impact')),
      'Recover freight acceleration cost by moving low-priority installation scope into the next baseline cycle.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('budget-change-request-evidence')),
      'Attach supplier quote, sponsor approval, variance reason, and funding source before release.',
    );
    await tester.ensureVisible(find.text('Queue Change'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Change'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Budget change queue empty'), findsNothing);
  });
}
