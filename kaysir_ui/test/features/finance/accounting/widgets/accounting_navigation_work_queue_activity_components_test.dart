import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_note.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_work_queue_activity_components.dart';

void main() {
  testWidgets(
    'shows action capture state and exposes copy audit brief control',
    (tester) async {
      var copyTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AccountingNavigationWorkQueueActivityPanel(
                trail: AccountingWorkspaceWorkQueueActivityTrail(
                  queueId: 'auditor-evidence-gaps',
                  queueTitle: 'Audit evidence gaps',
                  ownerLabel: 'Audit liaison',
                  dueLabel: '2 days overdue',
                  summaryLabel: '0 ready / 1 waiting / 3 blocked',
                  nextActionLabel:
                      'Send request and record owner response today',
                  entries: const [
                    AccountingWorkspaceWorkQueueActivityEntry(
                      id: 'evidence-request',
                      type: AccountingWorkspaceWorkQueueActivityType.evidence,
                      title: 'Evidence request issued',
                      detail: 'Evidence request: Audit evidence gaps',
                      actorLabel: 'Audit liaison',
                      timeLabel: 'Today',
                      statusLabel: 'Overdue follow-up',
                    ),
                  ],
                ),
                evidenceRequest: AccountingWorkspaceWorkQueueEvidenceRequest(
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
                  ],
                ),
                actionState:
                    const AccountingWorkspaceWorkQueueActivityActionState(
                      queueId: 'auditor-evidence-gaps',
                    ),
                evidenceLinks: [
                  AccountingWorkspaceWorkQueueEvidenceLink.create(
                    id: 'link-1',
                    queueId: 'auditor-evidence-gaps',
                    label: 'Release manifest workpaper',
                    reference: 'WP-REL-2026-06',
                    addedByLabel: 'Auditor',
                    addedAt: DateTime(2026, 6, 9, 10, 20),
                  ),
                ],
                evidenceReviewStates: const {
                  'link-1': AccountingWorkspaceWorkQueueEvidenceReviewState(
                    queueId: 'auditor-evidence-gaps',
                    linkId: 'link-1',
                    decision:
                        AccountingWorkspaceWorkQueueEvidenceReviewDecision
                            .accepted,
                  ),
                },
                notes: [
                  AccountingWorkspaceWorkQueueNote.create(
                    id: 'note-1',
                    queueId: 'auditor-evidence-gaps',
                    authorLabel: 'Auditor',
                    body: 'Controller confirmed owner handoff.',
                    createdAt: DateTime(2026, 6, 9, 10, 15),
                  ),
                ],
                onOwnerAcknowledged: () {},
                onEvidenceReceived: () {},
                onEscalationLogged: () {},
                onEvidenceLinkAdded: (_) {},
                onEvidenceLinkReviewDecisionChanged: (_, _) {},
                onCopyEvidenceLinks: () {},
                onNoteAdded: (_) {},
                onCopyNotes: () {},
                onCopyAuditBrief: () => copyTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Activity trail'), findsOneWidget);
      expect(find.text('0/3 actions captured'), findsOneWidget);
      expect(find.text('Execution notes'), findsOneWidget);
      expect(find.text('Controller confirmed owner handoff.'), findsOneWidget);
      expect(find.text('Evidence readiness'), findsOneWidget);
      expect(find.text('1/2 accepted'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Evidence links'), findsOneWidget);
      expect(find.text('Release manifest workpaper'), findsOneWidget);
      expect(find.text('Evidence request issued'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('accounting-work-queue-activity-copy-brief')),
      );
      await tester.pump();

      expect(copyTapped, isTrue);
    },
  );
}
