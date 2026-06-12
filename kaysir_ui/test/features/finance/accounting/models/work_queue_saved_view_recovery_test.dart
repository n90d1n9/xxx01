import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_recovery.dart';

void main() {
  test('keeps original label when no active saved view collides', () {
    final sourceView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );

    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [sourceView],
      activeViews: const [],
    );

    expect(candidates.single.sourceView.id, sourceView.id);
    expect(candidates.single.restoredView.label, 'Month-end blockers');
    expect(candidates.single.labelChanged, isFalse);
  });

  test('adds restored suffix when an active saved view label collides', () {
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final sourceView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Month-end blockers',
    );

    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [sourceView],
      activeViews: [activeView],
    );

    expect(
      candidates.single.restoredView.label,
      'Month-end blockers (restored)',
    );
    expect(candidates.single.labelChanged, isTrue);
  });

  test('keeps recovered labels unique across one restore batch', () {
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final firstView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Month-end blockers',
    );
    final secondView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.monitor,
      label: 'Month-end blockers',
    );

    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [firstView, secondView],
      activeViews: [activeView],
    );

    expect(candidates.map((candidate) => candidate.restoredView.label), [
      'Month-end blockers (restored)',
      'Month-end blockers (restored 2)',
    ]);
  });

  test('caps generated labels to the saved view label limit', () {
    final longLabel = 'Revenue close approval blockers for consolidation';
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: longLabel,
    );
    final sourceView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: longLabel,
    );

    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [sourceView],
      activeViews: [activeView],
    );

    expect(
      candidates.single.restoredView.label.length,
      lessThanOrEqualTo(workQueueSavedViewLabelLimit),
    );
    expect(candidates.single.restoredView.label, endsWith('(restored)'));
  });

  test('normalizes saved view labels for duplicate checks', () {
    expect(workQueueSavedViewNormalizedLabel('  Month-END  '), 'month-end');
    expect(workQueueSavedViewNormalizedLabel('   '), isNull);
  });

  test('returns deleted history views with saved payloads', () {
    final firstView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final secondView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );

    final recoverableViews = workQueueSavedViewRecoverableHistoryViews(
      activeViews: const [],
      auditEvents: [
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: firstView.label,
          viewId: firstView.id,
          savedView: firstView,
        ),
        const WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: 'Legacy delete without payload',
          viewId: 'custom-controller-legacy',
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: secondView.label,
          viewId: secondView.id,
          savedView: secondView,
        ),
      ],
    );

    expect(recoverableViews.map((view) => view.id), [
      firstView.id,
      secondView.id,
    ]);
  });

  test('skips deleted history views already active in the workspace', () {
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );

    final recoverableViews = workQueueSavedViewRecoverableHistoryViews(
      activeViews: [activeView],
      auditEvents: [
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: activeView.label,
          viewId: activeView.id,
          savedView: activeView,
        ),
      ],
    );

    expect(recoverableViews, isEmpty);
  });

  test('honors newer restore events before older delete history', () {
    final restoredView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final deletedView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );

    final recoverableViews = workQueueSavedViewRecoverableHistoryViews(
      activeViews: const [],
      auditEvents: [
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.restored,
          previousLabel: restoredView.label,
          viewId: restoredView.id,
          savedView: restoredView,
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: restoredView.label,
          viewId: restoredView.id,
          savedView: restoredView,
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: deletedView.label,
          viewId: deletedView.id,
          savedView: deletedView,
        ),
      ],
    );

    expect(recoverableViews.map((view) => view.id), [deletedView.id]);
  });
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceWorkQueueFocus focus,
  required String label,
}) {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: focus,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: null,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: null,
    selectedQueueTitle: null,
    detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
  ).copyWith(label: label);
}
