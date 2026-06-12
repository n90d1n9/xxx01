import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_work_queue_action_progress_components.dart';

void main() {
  testWidgets('hides progress strip before activity actions are captured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueActionProgressStrip(
            actionState: AccountingWorkspaceWorkQueueActivityActionState(
              queueId: 'auditor-evidence-gaps',
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('accounting-work-queue-action-progress-strip')),
      findsNothing,
    );
  });

  testWidgets('renders captured action progress and next action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueActionProgressStrip(
            actionState: AccountingWorkspaceWorkQueueActivityActionState(
              queueId: 'auditor-evidence-gaps',
              ownerAcknowledged: true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('accounting-work-queue-action-progress-strip')),
      findsOneWidget,
    );
    expect(find.text('1/3 actions captured'), findsOneWidget);
    expect(find.text('Record evidence receipt'), findsOneWidget);
  });

  testWidgets('renders complete activity progress state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueActionProgressStrip(
            actionState: AccountingWorkspaceWorkQueueActivityActionState(
              queueId: 'auditor-evidence-gaps',
              ownerAcknowledged: true,
              evidenceReceived: true,
              escalationLogged: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Activity actions complete'), findsAtLeastNWidgets(1));
  });
}
