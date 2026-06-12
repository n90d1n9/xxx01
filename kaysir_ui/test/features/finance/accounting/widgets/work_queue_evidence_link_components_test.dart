import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_evidence_link_components.dart';

void main() {
  testWidgets('renders evidence links and exposes copy control', (
    tester,
  ) async {
    var copied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceLinksPanel(
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
            reviewStates: const {},
            onLinkAdded: (_) {},
            onReviewDecisionChanged: (_, _) {},
            onCopyLinks: () => copied = true,
          ),
        ),
      ),
    );

    expect(find.text('Evidence links'), findsOneWidget);
    expect(find.text('1 link'), findsOneWidget);
    expect(find.text('Workpaper'), findsOneWidget);
    expect(find.text('Review pending'), findsOneWidget);
    expect(find.text('Release manifest workpaper'), findsOneWidget);
    expect(find.text('WP-REL-2026-06'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-evidence-links-copy')),
    );
    await tester.pump();

    expect(copied, isTrue);
  });

  testWidgets('renders reviewer audit trail metadata', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceLinksPanel(
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
            reviewStates: {
              'link-1': AccountingWorkspaceWorkQueueEvidenceReviewState(
                queueId: 'auditor-evidence-gaps',
                linkId: 'link-1',
                decision:
                    AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
                reviewedByLabel: 'Auditor',
                reviewedAt: DateTime(2026, 6, 9, 12, 5),
              ),
            },
            onLinkAdded: (_) {},
            onReviewDecisionChanged: (_, _) {},
            onCopyLinks: () {},
          ),
        ),
      ),
    );

    expect(find.text('Reviewed by Auditor · 2026-06-09 12:05'), findsOneWidget);
  });

  testWidgets('composes an evidence link draft from the add link dialog', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueEvidenceLinkDraft? capturedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceLinksPanel(
            links: const [],
            reviewStates: const {},
            onLinkAdded: (draft) => capturedDraft = draft,
            onReviewDecisionChanged: (_, _) {},
            onCopyLinks: () {},
          ),
        ),
      ),
    );

    expect(find.text('No evidence links attached yet.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-evidence-links-add')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-link-label-field'),
      ),
      'Signed controller approval',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-link-reference-field'),
      ),
      'APP-42',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-evidence-link-save')),
    );
    await tester.pumpAndSettle();

    expect(capturedDraft, isNotNull);
    expect(capturedDraft!.label, 'Signed controller approval');
    expect(capturedDraft!.reference, 'APP-42');
    expect(
      capturedDraft!.type,
      AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper,
    );
  });

  testWidgets('captures accepted evidence review drafts from link rows', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueEvidenceLink? reviewedLink;
    AccountingWorkspaceWorkQueueEvidenceReviewDraft? reviewedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceLinksPanel(
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
            reviewStates: const {},
            onLinkAdded: (_) {},
            onReviewDecisionChanged: (link, draft) {
              reviewedLink = link;
              reviewedDraft = draft;
            },
            onCopyLinks: () {},
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-link-accept-link-1'),
      ),
    );
    await tester.pump();

    expect(reviewedLink?.id, 'link-1');
    expect(
      reviewedDraft?.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
    );
    expect(reviewedDraft?.reviewNote, isEmpty);
  });

  testWidgets('requires reviewer memo before returning evidence for rework', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueEvidenceLink? reviewedLink;
    AccountingWorkspaceWorkQueueEvidenceReviewDraft? reviewedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueEvidenceLinksPanel(
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
            reviewStates: const {},
            onLinkAdded: (_) {},
            onReviewDecisionChanged: (link, draft) {
              reviewedLink = link;
              reviewedDraft = draft;
            },
            onCopyLinks: () {},
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-link-rework-link-1'),
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.byKey(
      const ValueKey('accounting-work-queue-evidence-review-save'),
    );
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(
        const ValueKey('accounting-work-queue-evidence-review-note-field'),
      ),
      'Approval reference is missing controller sign-off.',
    );
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(reviewedLink?.id, 'link-1');
    expect(
      reviewedDraft?.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
    );
    expect(
      reviewedDraft?.normalizedReviewNote,
      'Approval reference is missing controller sign-off.',
    );
  });
}
