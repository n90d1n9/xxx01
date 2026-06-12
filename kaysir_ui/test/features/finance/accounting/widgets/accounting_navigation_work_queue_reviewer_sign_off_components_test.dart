import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_reviewer_sign_off_guard.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_work_queue_reviewer_sign_off_components.dart';

void main() {
  testWidgets('renders reviewer sign-off actions and captures a decision', (
    tester,
  ) async {
    var approved = false;
    var returned = false;
    var blocked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueReviewerSignOffPanel(
            state: const AccountingWorkspaceWorkQueueReviewerSignOffState(
              queueId: 'auditor-evidence-gaps',
            ),
            onApproved: () => approved = true,
            onReturned: () => returned = true,
            onBlocked: () => blocked = true,
          ),
        ),
      ),
    );

    expect(find.text('Reviewer sign-off'), findsOneWidget);
    expect(find.text('Pending review'), findsOneWidget);
    expect(find.text('Review evidence and record a decision'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-reviewer-approve')),
    );
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-reviewer-return')),
    );
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-reviewer-block')),
    );
    await tester.pump();

    expect(approved, isTrue);
    expect(returned, isTrue);
    expect(blocked, isTrue);
  });

  testWidgets('renders approved reviewer sign-off state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueReviewerSignOffPanel(
            state: AccountingWorkspaceWorkQueueReviewerSignOffState(
              queueId: 'auditor-evidence-gaps',
              decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
            ),
            onApproved: _noop,
            onReturned: _noop,
            onBlocked: _noop,
          ),
        ),
      ),
    );

    expect(find.text('Approved'), findsAtLeastNWidgets(1));
    expect(find.text('Move release or close gate forward'), findsOneWidget);
  });

  testWidgets('blocks reviewer approval when evidence is not ready', (
    tester,
  ) async {
    var approved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueReviewerSignOffPanel(
            state: const AccountingWorkspaceWorkQueueReviewerSignOffState(
              queueId: 'auditor-evidence-gaps',
            ),
            approvalGuard: AccountingWorkspaceWorkQueueReviewerSignOffGuard(
              readiness:
                  AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
                    queueId: 'auditor-evidence-gaps',
                    request: _request(),
                    links: const [],
                  ),
            ),
            onApproved: () => approved = true,
            onReturned: _noop,
            onBlocked: _noop,
          ),
        ),
      ),
    );

    expect(find.text('Evidence gate blocked · 0/1 accepted'), findsOneWidget);
    expect(
      find.text('Requested evidence must be attached and accepted first.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-reviewer-approve')),
    );
    await tester.pump();

    expect(approved, isFalse);
  });
}

void _noop() {}

AccountingWorkspaceWorkQueueEvidenceRequest _request() {
  return AccountingWorkspaceWorkQueueEvidenceRequest(
    recipientLabel: 'Audit liaison',
    subject: 'Evidence request: Audit evidence gaps',
    responseDueLabel: 'Today before release',
    statusLabel: 'Overdue follow-up',
    agingLabel: '2 days overdue',
    followUpLabel: 'Daily until cleared',
    nextTrackingActionLabel: 'Send request today',
    requestBody: 'Evidence request body',
    requestedItems: const ['Release manifest support'],
  );
}
