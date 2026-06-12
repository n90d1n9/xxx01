import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_evidence_readiness_components.dart';

void main() {
  testWidgets('renders evidence readiness coverage and next action', (
    tester,
  ) async {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
      queueId: 'auditor-evidence-gaps',
      request: _request(),
      links: [
        AccountingWorkspaceWorkQueueEvidenceLink.create(
          id: 'link-1',
          queueId: 'auditor-evidence-gaps',
          label: 'Release manifest workpaper',
          reference: 'WP-REL-2026-06',
          addedByLabel: 'Auditor',
          addedAt: DateTime(2026, 6, 9, 10, 20),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceReadinessPanel(
            readiness: readiness,
          ),
        ),
      ),
    );

    expect(find.text('Evidence readiness'), findsOneWidget);
    expect(find.text('Review needed'), findsOneWidget);
    expect(find.text('0/3 accepted'), findsOneWidget);
    expect(find.text('1 link'), findsOneWidget);
    expect(find.text('1 pending'), findsOneWidget);
    expect(find.text('Release manifest support'), findsOneWidget);
    expect(find.text('Signed controller approval'), findsOneWidget);
    expect(find.text('Disclosure checklist tie-out'), findsNothing);
    expect(find.textContaining('Review attached evidence'), findsOneWidget);
  });

  testWidgets('renders compact evidence signal for actionable readiness', (
    tester,
  ) async {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
      queueId: 'returned-support',
      request: _request(),
      links: [_link(queueId: 'returned-support')],
      reviewStates: const [
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'returned-support',
          linkId: 'link-1',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceSignalPill(
            readiness: readiness,
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-evidence-signal-returned-support',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Rework needed · 0/3 accepted'), findsOneWidget);
  });

  testWidgets('hides compact evidence signal for ready evidence by default', (
    tester,
  ) async {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
      queueId: 'ready-support',
      request: _request(),
      links: [
        _link(queueId: 'ready-support', id: 'link-1'),
        _link(queueId: 'ready-support', id: 'link-2'),
        _link(queueId: 'ready-support', id: 'link-3'),
      ],
      reviewStates: const [
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'ready-support',
          linkId: 'link-1',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'ready-support',
          linkId: 'link-2',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'ready-support',
          linkId: 'link-3',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceSignalPill(
            readiness: readiness,
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-signal-ready-support'),
      ),
      findsNothing,
    );
    expect(find.textContaining('Evidence ready'), findsNothing);
  });
}

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
    requestedItems: const [
      'Release manifest support',
      'Signed controller approval',
      'Disclosure checklist tie-out',
    ],
  );
}

AccountingWorkspaceWorkQueueEvidenceLink _link({
  required String queueId,
  String id = 'link-1',
}) {
  return AccountingWorkspaceWorkQueueEvidenceLink.create(
    id: id,
    queueId: queueId,
    label: 'Release manifest workpaper',
    reference: 'WP-REL-2026-06',
    addedByLabel: 'Auditor',
    addedAt: DateTime(2026, 6, 9, 10, 20),
  );
}
