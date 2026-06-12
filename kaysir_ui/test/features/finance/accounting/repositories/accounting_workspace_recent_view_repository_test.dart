import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_recent_view.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_note.dart';
import 'package:kaysir/features/finance/accounting/repositories/accounting_workspace_recent_view_repository.dart';

void main() {
  test('saves and restores accounting workspace snapshot state', () async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);
    final views = [
      AccountingWorkspaceRecentView.fromSearch(
        query: 'spt',
        scope: AccountingMenuSearchScope.shortcuts,
      ),
      AccountingWorkspaceRecentView.fromSearch(
        query: 'reconciliation',
        scope: AccountingMenuSearchScope.screens,
      ),
    ];
    final auditRecordedAt = DateTime.utc(2026, 6, 10, 4, 30);
    final taxSavedView = AccountingWorkspaceWorkQueueSavedView.custom(
      query: 'spt',
      scope: AccountingMenuSearchScope.shortcuts,
      rolePreset: AccountingWorkspaceRolePreset.tax,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Tax reviewer',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
      selectedQueueId: 'tax-statutory-filing-gaps',
      selectedQueueTitle: 'SPT filing gaps',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    ).copyWith(label: 'Tax filing blockers');

    await repository.saveSnapshot(
      AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.tax,
        workQueueFocus: AccountingWorkspaceWorkQueueFocus.blocked,
        workQueueSort: AccountingWorkspaceWorkQueueSort.urgent,
        workQueueOwnerFilter: 'Tax reviewer',
        selectedWorkQueueId: 'tax-statutory-filing-gaps',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.controls,
        workQueueResolutionFilter:
            AccountingWorkspaceWorkQueueResolutionFilter.ready,
        views: views,
        workQueueSavedViews: [taxSavedView],
        workQueueSavedViewAuditEvents: [
          WorkQueueSavedViewManagerAuditEvent(
            action: WorkQueueSavedViewManagerAuditAction.renamed,
            previousLabel: 'SPT filing gaps / Ready',
            viewId: taxSavedView.id,
            rolePreset: AccountingWorkspaceRolePreset.tax,
            nextLabel: 'Tax filing blockers',
            occurredAt: auditRecordedAt,
            savedView: taxSavedView,
          ),
        ],
        workQueueActivityActionStates: const [
          AccountingWorkspaceWorkQueueActivityActionState(
            queueId: 'auditor-evidence-gaps',
            ownerAcknowledged: true,
            evidenceReceived: true,
          ),
        ],
        workQueueEvidenceLinks: [
          AccountingWorkspaceWorkQueueEvidenceLink.create(
            id: 'link-1',
            queueId: 'auditor-evidence-gaps',
            label: 'Release manifest workpaper',
            reference: 'WP-REL-2026-06',
            addedByLabel: 'Auditor',
            addedAt: DateTime(2026, 6, 9, 10, 20),
          ),
        ],
        workQueueEvidenceReviewStates: [
          AccountingWorkspaceWorkQueueEvidenceReviewState(
            queueId: 'auditor-evidence-gaps',
            linkId: 'link-1',
            decision:
                AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
            reviewNote: 'Controller approval checked.',
            reviewedByLabel: 'Auditor',
            reviewedAt: DateTime(2026, 6, 9, 12, 5),
          ),
        ],
        workQueueNotes: [
          AccountingWorkspaceWorkQueueNote.create(
            id: 'note-1',
            queueId: 'auditor-evidence-gaps',
            authorLabel: 'Auditor',
            body: 'Controller confirmed owner handoff.',
            createdAt: DateTime(2026, 6, 9, 10, 15),
            type: AccountingWorkspaceWorkQueueNoteType.handoff,
          ),
        ],
        workQueueReviewerSignOffStates: const [
          AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
        ],
        workQueueResolutionStates: const [
          AccountingWorkspaceWorkQueueResolutionState(
            queueId: 'auditor-evidence-gaps',
            cleared: true,
          ),
        ],
      ),
    );

    final restoredSnapshot = await repository.loadSnapshot();

    expect(restoredSnapshot.rolePreset, AccountingWorkspaceRolePreset.tax);
    expect(
      restoredSnapshot.workQueueFocus,
      AccountingWorkspaceWorkQueueFocus.blocked,
    );
    expect(
      restoredSnapshot.workQueueSort,
      AccountingWorkspaceWorkQueueSort.urgent,
    );
    expect(restoredSnapshot.workQueueOwnerFilter, 'Tax reviewer');
    expect(restoredSnapshot.selectedWorkQueueId, 'tax-statutory-filing-gaps');
    expect(
      restoredSnapshot.selectedWorkQueueDetailSection,
      AccountingWorkspaceWorkQueueDetailSection.controls,
    );
    expect(
      restoredSnapshot.workQueueResolutionFilter,
      AccountingWorkspaceWorkQueueResolutionFilter.ready,
    );
    expect(restoredSnapshot.views.map((view) => view.id), [
      'shortcuts:spt',
      'screens:reconciliation',
    ]);
    expect(
      restoredSnapshot.views.first.path,
      '/accounting?q=spt&scope=shortcuts',
    );
    expect(restoredSnapshot.workQueueSavedViews.single.id, contains('custom'));
    expect(restoredSnapshot.workQueueSavedViews.single.query, 'spt');
    expect(
      restoredSnapshot.workQueueSavedViews.single.selectedQueueId,
      'tax-statutory-filing-gaps',
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.action,
      WorkQueueSavedViewManagerAuditAction.renamed,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.previousLabel,
      'SPT filing gaps / Ready',
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.viewId,
      taxSavedView.id,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.rolePreset,
      AccountingWorkspaceRolePreset.tax,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.nextLabel,
      'Tax filing blockers',
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.occurredAt,
      auditRecordedAt,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.savedView?.id,
      taxSavedView.id,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.savedView?.label,
      'Tax filing blockers',
    );
    expect(
      restoredSnapshot.workQueueActivityActionStates.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(
      restoredSnapshot.workQueueActivityActionStates.single.ownerAcknowledged,
      isTrue,
    );
    expect(
      restoredSnapshot.workQueueActivityActionStates.single.evidenceReceived,
      isTrue,
    );
    expect(
      restoredSnapshot.workQueueEvidenceLinks.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(
      restoredSnapshot.workQueueEvidenceLinks.single.label,
      'Release manifest workpaper',
    );
    expect(
      restoredSnapshot.workQueueEvidenceLinks.single.reference,
      'WP-REL-2026-06',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.linkId,
      'link-1',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewNote,
      'Controller approval checked.',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewedByLabel,
      'Auditor',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewedAt,
      DateTime(2026, 6, 9, 12, 5),
    );
    expect(
      restoredSnapshot.workQueueNotes.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(
      restoredSnapshot.workQueueNotes.single.type,
      AccountingWorkspaceWorkQueueNoteType.handoff,
    );
    expect(
      restoredSnapshot.workQueueNotes.single.body,
      'Controller confirmed owner handoff.',
    );
    expect(
      restoredSnapshot.workQueueReviewerSignOffStates.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(
      restoredSnapshot.workQueueReviewerSignOffStates.single.decision,
      AccountingWorkspaceWorkQueueReviewerDecision.approved,
    );
    expect(
      restoredSnapshot.workQueueResolutionStates.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(restoredSnapshot.workQueueResolutionStates.single.cleared, isTrue);
  });

  test('ignores malformed recent view snapshot entries', () async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await store.write({
      'schemaVersion': 1,
      'views': [
        'bad-entry',
        {'query': 'evidence', 'scope': 'all', 'label': '', 'icon': ''},
      ],
      'rolePreset': 'audit',
      'workQueueFocus': 'warning',
      'workQueueSort': 'load',
      'workQueueOwnerFilter': '  Audit liaison  ',
      'selectedWorkQueueId': ' auditor-evidence-gaps ',
      'selectedWorkQueueDetailSection': 'audit',
      'workQueueResolutionFilter': 'cleared',
      'workQueueActivityActionStates': [
        'bad-entry',
        {'queueId': '', 'ownerAcknowledged': true},
        {'queueId': 'auditor-evidence-gaps', 'escalationLogged': true},
      ],
      'workQueueEvidenceLinks': [
        'bad-entry',
        {
          'id': 'missing-label',
          'queueId': 'auditor-evidence-gaps',
          'label': '',
          'reference': 'WP-MISSING',
        },
        {
          'id': 'link-1',
          'queueId': 'auditor-evidence-gaps',
          'label': 'Signed controller approval',
          'reference': 'APP-42',
          'addedByLabel': 'Auditor',
          'addedAt': '2026-06-09T12:45:00.000',
          'type': 'approval',
        },
      ],
      'workQueueEvidenceReviewStates': [
        'bad-entry',
        {'queueId': '', 'linkId': 'link-1', 'decision': 'accepted'},
        {'queueId': 'auditor-evidence-gaps', 'linkId': 'link-2'},
        {
          'queueId': 'auditor-evidence-gaps',
          'linkId': 'link-1',
          'decision': 'returned',
          'reviewNote': 'Missing signed controller approval.',
          'reviewedByLabel': 'Auditor',
          'reviewedAt': '2026-06-09T12:55:00.000',
        },
      ],
      'workQueueNotes': [
        'bad-entry',
        {'id': 'empty-queue', 'queueId': '', 'body': 'Missing queue'},
        {
          'id': 'note-1',
          'queueId': 'auditor-evidence-gaps',
          'authorLabel': 'Auditor',
          'body': 'Reviewer requested signed release support.',
          'createdAt': '2026-06-09T12:30:00.000',
          'type': 'evidence',
        },
      ],
      'workQueueReviewerSignOffStates': [
        'bad-entry',
        {'queueId': '', 'decision': 'approved'},
        {'queueId': 'auditor-evidence-gaps', 'decision': 'returned'},
      ],
      'workQueueResolutionStates': [
        'bad-entry',
        {'queueId': '', 'cleared': true},
        {'queueId': 'auditor-evidence-gaps', 'cleared': true},
      ],
      'workQueueSavedViews': [
        'bad-entry',
        {'id': '', 'rolePreset': 'tax', 'label': 'Broken'},
        {
          'id': 'custom-audit-review',
          'label': 'Audit review',
          'description': 'Audit review lanes.',
          'icon': 'fact_check',
          'rolePreset': 'audit',
          'query': 'evidence',
          'scope': 'screens',
          'focus': 'review',
          'sort': 'urgent',
          'ownerFilter': 'Audit liaison',
          'resolutionFilter': 'open',
          'selectedQueueId': 'auditor-evidence-gaps',
          'detailSection': 'request',
          'isCustom': true,
        },
      ],
      'workQueueSavedViewAuditEvents': [
        'bad-entry',
        {'action': 'deleted', 'previousLabel': ''},
        {'action': 'ignored', 'previousLabel': 'Bad action'},
        {
          'action': 'deleted',
          'previousLabel': 'Audit review',
          'viewId': 'custom-audit-review',
          'rolePreset': 'audit',
          'savedView': {
            'id': 'custom-audit-review',
            'label': 'Audit review',
            'description': 'Audit review lanes.',
            'icon': 'fact_check',
            'rolePreset': 'audit',
            'query': 'evidence',
            'scope': 'screens',
            'focus': 'review',
            'sort': 'urgent',
            'ownerFilter': 'Audit liaison',
            'resolutionFilter': 'open',
            'selectedQueueId': 'auditor-evidence-gaps',
            'detailSection': 'request',
            'isCustom': true,
          },
        },
      ],
    });

    final restoredSnapshot = await repository.loadSnapshot();

    expect(restoredSnapshot.rolePreset, AccountingWorkspaceRolePreset.auditor);
    expect(
      restoredSnapshot.workQueueFocus,
      AccountingWorkspaceWorkQueueFocus.review,
    );
    expect(
      restoredSnapshot.workQueueSort,
      AccountingWorkspaceWorkQueueSort.largest,
    );
    expect(restoredSnapshot.workQueueOwnerFilter, 'Audit liaison');
    expect(restoredSnapshot.selectedWorkQueueId, 'auditor-evidence-gaps');
    expect(
      restoredSnapshot.selectedWorkQueueDetailSection,
      AccountingWorkspaceWorkQueueDetailSection.activity,
    );
    expect(
      restoredSnapshot.workQueueResolutionFilter,
      AccountingWorkspaceWorkQueueResolutionFilter.cleared,
    );
    final restoredViews = restoredSnapshot.views;
    expect(restoredViews, hasLength(1));
    expect(restoredViews.single.id, 'all:evidence');
    expect(restoredViews.single.label, 'evidence - All');
    expect(
      restoredSnapshot.workQueueActivityActionStates.single.queueId,
      'auditor-evidence-gaps',
    );
    expect(
      restoredSnapshot.workQueueActivityActionStates.single.escalationLogged,
      isTrue,
    );
    expect(
      restoredSnapshot.workQueueReviewerSignOffStates.single.decision,
      AccountingWorkspaceWorkQueueReviewerDecision.returned,
    );
    expect(restoredSnapshot.workQueueEvidenceLinks.single.id, 'link-1');
    expect(
      restoredSnapshot.workQueueEvidenceLinks.single.type,
      AccountingWorkspaceWorkQueueEvidenceLinkType.approval,
    );
    expect(restoredSnapshot.workQueueEvidenceLinks.single.reference, 'APP-42');
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.linkId,
      'link-1',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewNote,
      'Missing signed controller approval.',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewedByLabel,
      'Auditor',
    );
    expect(
      restoredSnapshot.workQueueEvidenceReviewStates.single.reviewedAt,
      DateTime(2026, 6, 9, 12, 55),
    );
    expect(restoredSnapshot.workQueueNotes.single.id, 'note-1');
    expect(
      restoredSnapshot.workQueueNotes.single.body,
      'Reviewer requested signed release support.',
    );
    expect(
      restoredSnapshot.workQueueNotes.single.type,
      AccountingWorkspaceWorkQueueNoteType.evidence,
    );
    expect(restoredSnapshot.workQueueResolutionStates.single.cleared, isTrue);
    expect(
      restoredSnapshot.workQueueSavedViews.single.id,
      'custom-audit-review',
    );
    expect(
      restoredSnapshot.workQueueSavedViews.single.scope,
      AccountingMenuSearchScope.screens,
    );
    expect(
      restoredSnapshot.workQueueSavedViews.single.resolutionFilter,
      AccountingWorkspaceWorkQueueResolutionFilter.open,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.action,
      WorkQueueSavedViewManagerAuditAction.deleted,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.previousLabel,
      'Audit review',
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.viewId,
      'custom-audit-review',
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.rolePreset,
      AccountingWorkspaceRolePreset.auditor,
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.single.savedView?.id,
      'custom-audit-review',
    );
    expect(
      restoredSnapshot
          .workQueueSavedViewAuditEvents
          .single
          .savedView
          ?.selectedQueueId,
      'auditor-evidence-gaps',
    );
  });

  test('clears recent views while preserving role preset', () async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueFocus: AccountingWorkspaceWorkQueueFocus.monitor,
        workQueueSort: AccountingWorkspaceWorkQueueSort.owner,
        workQueueOwnerFilter: 'Reporting lead',
        selectedWorkQueueId: 'controller-report-pack-exceptions',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.request,
        workQueueResolutionFilter:
            AccountingWorkspaceWorkQueueResolutionFilter.blocked,
        views: [
          AccountingWorkspaceRecentView.fromSearch(
            query: 'spt',
            scope: AccountingMenuSearchScope.shortcuts,
          ),
        ],
      ),
    );

    await repository.clear();

    final restoredSnapshot = await repository.loadSnapshot();

    expect(
      restoredSnapshot.rolePreset,
      AccountingWorkspaceRolePreset.controller,
    );
    expect(
      restoredSnapshot.workQueueFocus,
      AccountingWorkspaceWorkQueueFocus.monitor,
    );
    expect(
      restoredSnapshot.workQueueSort,
      AccountingWorkspaceWorkQueueSort.owner,
    );
    expect(restoredSnapshot.workQueueOwnerFilter, 'Reporting lead');
    expect(
      restoredSnapshot.selectedWorkQueueId,
      'controller-report-pack-exceptions',
    );
    expect(
      restoredSnapshot.selectedWorkQueueDetailSection,
      AccountingWorkspaceWorkQueueDetailSection.request,
    );
    expect(
      restoredSnapshot.workQueueResolutionFilter,
      AccountingWorkspaceWorkQueueResolutionFilter.blocked,
    );
    expect(restoredSnapshot.views, isEmpty);
  });

  test('saving recent views preserves persisted role preset', () async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveRolePreset(AccountingWorkspaceRolePreset.auditor);
    await repository.saveWorkQueueFocus(
      AccountingWorkspaceWorkQueueFocus.review,
    );
    await repository.saveWorkQueueSort(AccountingWorkspaceWorkQueueSort.urgent);
    await repository.saveWorkQueueOwnerFilter('Audit liaison');
    await repository.saveWorkQueueResolutionFilter(
      AccountingWorkspaceWorkQueueResolutionFilter.open,
    );
    await repository.save([
      AccountingWorkspaceRecentView.fromSearch(
        query: 'report pack',
        scope: AccountingMenuSearchScope.screens,
      ),
    ]);

    final restoredSnapshot = await repository.loadSnapshot();

    expect(restoredSnapshot.rolePreset, AccountingWorkspaceRolePreset.auditor);
    expect(
      restoredSnapshot.workQueueFocus,
      AccountingWorkspaceWorkQueueFocus.review,
    );
    expect(
      restoredSnapshot.workQueueSort,
      AccountingWorkspaceWorkQueueSort.urgent,
    );
    expect(restoredSnapshot.workQueueOwnerFilter, 'Audit liaison');
    expect(
      restoredSnapshot.workQueueResolutionFilter,
      AccountingWorkspaceWorkQueueResolutionFilter.open,
    );
    expect(restoredSnapshot.views.single.id, 'screens:report pack');

    await repository.saveWorkQueueOwnerFilter('   ');

    expect((await repository.loadSnapshot()).workQueueOwnerFilter, isNull);
  });
}
