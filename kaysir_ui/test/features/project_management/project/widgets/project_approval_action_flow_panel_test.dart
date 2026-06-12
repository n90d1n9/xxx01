import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_approval_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_approval_action_flow_panel.dart';

void main() {
  testWidgets('approval action flow panel validates and queues an action', (
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
    final summary = buildProjectApprovalWorkspaceSummary(financeWorkspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 960,
              child: ProjectApprovalActionFlowPanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Approval action flow'), findsOneWidget);
    expect(find.text('Approval action queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Action'));
    await tester.tap(find.text('Queue Action'));
    await tester.pump();

    expect(
      find.text('Approval note should explain the action.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('approval-action-approver')),
      'Supply Chain Sponsor',
    );
    await tester.enterText(
      find.byKey(const ValueKey('approval-action-evidence')),
      'Sponsor approval memo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('approval-action-note')),
      'Approve the queue item after confirming evidence, release owner, and approval threshold.',
    );
    await tester.ensureVisible(find.text('Queue Action'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Action'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Approval action queue empty'), findsNothing);
  });
}
