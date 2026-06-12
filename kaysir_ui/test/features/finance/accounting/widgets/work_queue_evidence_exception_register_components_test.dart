import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_exception_register.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_evidence_exception_register_components.dart';

void main() {
  testWidgets('renders evidence exception register and selects a queue', (
    tester,
  ) async {
    String? selectedQueueId;
    String? selectedOwner;
    var copied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceExceptionRegister(
            register: AccountingWorkspaceWorkQueueEvidenceExceptionRegister(
              items: const [
                AccountingWorkspaceWorkQueueEvidenceException(
                  queueId: 'returned-support',
                  title: 'Returned support',
                  ownerLabel: 'Controller',
                  dueLabel: '1 day overdue',
                  severity: AccountingWorkspaceWorkQueueSeverity.critical,
                  slaStatus: AccountingWorkspaceWorkQueueSlaStatus.overdue,
                  status:
                      AccountingWorkspaceWorkQueueEvidenceReadinessStatus
                          .rework,
                  coverageLabel: '0/3 accepted',
                  nextActionLabel: 'Send rework comments to owner.',
                  pendingReviewCount: 0,
                  reworkEvidenceCount: 1,
                  remainingItemCount: 3,
                ),
                AccountingWorkspaceWorkQueueEvidenceException(
                  queueId: 'review-support',
                  title: 'Review support',
                  ownerLabel: 'Treasury',
                  dueLabel: 'Due today',
                  severity: AccountingWorkspaceWorkQueueSeverity.warning,
                  slaStatus: AccountingWorkspaceWorkQueueSlaStatus.dueToday,
                  status:
                      AccountingWorkspaceWorkQueueEvidenceReadinessStatus
                          .reviewNeeded,
                  coverageLabel: '0/2 accepted',
                  nextActionLabel: 'Review attached evidence.',
                  pendingReviewCount: 1,
                  reworkEvidenceCount: 0,
                  remainingItemCount: 2,
                ),
              ],
            ),
            maxVisibleItems: 1,
            onCopyBrief: () => copied = true,
            onExceptionSelected: (queueId) => selectedQueueId = queueId,
            onOwnerSelected: (owner) => selectedOwner = owner,
          ),
        ),
      ),
    );

    expect(find.text('Evidence exceptions'), findsOneWidget);
    expect(find.text('1 blocker(s)'), findsOneWidget);
    expect(find.text('Controller · 1 open · 1 blocker'), findsOneWidget);
    expect(find.text('Treasury · 1 open · 1 review'), findsOneWidget);
    expect(find.text('Returned support'), findsOneWidget);
    expect(find.text('Review support'), findsNothing);
    expect(find.textContaining('+1 more evidence exception'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-exception-copy'),
      ),
    );
    await tester.pump();

    expect(copied, isTrue);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-evidence-owner-handoff-controller',
        ),
      ),
    );
    await tester.pump();

    expect(selectedOwner, 'Controller');

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-owner-handoff-treasury'),
      ),
    );
    await tester.pump();

    expect(selectedOwner, 'Treasury');

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-evidence-exception-review-returned-support',
        ),
      ),
    );
    await tester.pump();

    expect(selectedQueueId, 'returned-support');
  });

  testWidgets('hides register when evidence exceptions are clear', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceExceptionRegister(
            register: AccountingWorkspaceWorkQueueEvidenceExceptionRegister(
              items: const [],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-exception-register'),
      ),
      findsNothing,
    );
  });
}
