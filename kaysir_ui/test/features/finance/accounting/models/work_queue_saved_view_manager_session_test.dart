import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_session.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_recovery.dart';

void main() {
  test('rename validates blank and duplicate labels', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Report approver',
      selectedQueueId: 'controller-release-approvals',
      selectedQueueTitle: 'Release approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: [blockersView, approverView],
      auditEvents: const [],
    );

    final blankResult = session.rename(view: blockersView, nextLabel: '   ');

    expect(blankResult.errorText, 'Enter a view name.');
    expect(blankResult.renamedView, isNull);
    expect(blankResult.session.errors[blockersView.id], 'Enter a view name.');

    final duplicateResult = blankResult.session.rename(
      view: blockersView,
      nextLabel: 'Approver pulse',
    );

    expect(duplicateResult.errorText, 'Use a unique view name.');
    expect(duplicateResult.renamedView, isNull);
    expect(
      duplicateResult.session.errors[blockersView.id],
      'Use a unique view name.',
    );
  });

  test('renames custom view and records audit payload', () {
    final occurredAt = DateTime.utc(2026, 6, 10, 8);
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: [blockersView],
      auditEvents: const [],
    );

    final result = session.rename(
      view: blockersView,
      nextLabel: 'Close review blockers',
      occurredAt: occurredAt,
    );
    final event = result.session.auditEvents.single;

    expect(result.renamedView?.label, 'Close review blockers');
    expect(result.session.views.single.label, 'Close review blockers');
    expect(event.action, WorkQueueSavedViewManagerAuditAction.renamed);
    expect(event.previousLabel, 'Month-end blockers');
    expect(event.nextLabel, 'Close review blockers');
    expect(event.occurredAt, occurredAt);
    expect(event.savedView?.label, 'Close review blockers');
  });

  test('deletes custom view and tracks undo state', () {
    final occurredAt = DateTime.utc(2026, 6, 10, 9);
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: [blockersView, approverView],
      auditEvents: const [],
    );

    final result = session.delete(view: approverView, occurredAt: occurredAt);
    final event = result.session.auditEvents.single;

    expect(result.deletedView?.id, approverView.id);
    expect(result.session.views.map((view) => view.id), [blockersView.id]);
    expect(result.session.lastDeletedView?.id, approverView.id);
    expect(result.session.lastDeletedIndex, 1);
    expect(event.action, WorkQueueSavedViewManagerAuditAction.deleted);
    expect(event.previousLabel, 'Approver pulse');
    expect(event.occurredAt, occurredAt);
    expect(event.savedView?.id, approverView.id);
  });

  test('restores deleted view at previous index with unique label', () {
    final occurredAt = DateTime.utc(2026, 6, 10, 10);
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final deletedView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Month-end blockers',
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: [activeView],
      auditEvents: const [],
    );

    final result = session.restore(
      view: deletedView,
      insertionIndex: 0,
      occurredAt: occurredAt,
    );
    final event = result.session.auditEvents.single;

    expect(result.restoredView?.label, 'Month-end blockers (restored)');
    expect(result.session.views.map((view) => view.id), [
      deletedView.id,
      activeView.id,
    ]);
    expect(event.action, WorkQueueSavedViewManagerAuditAction.restored);
    expect(event.previousLabel, 'Month-end blockers (restored)');
    expect(event.occurredAt, occurredAt);
    expect(event.savedView?.label, 'Month-end blockers (restored)');
  });

  test('restores many recovery candidates', () {
    final occurredAt = DateTime.utc(2026, 6, 10, 11);
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );
    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [blockersView, approverView],
      activeViews: const [],
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: const [],
      auditEvents: const [],
    );

    final result = session.restoreMany(
      candidates: candidates,
      occurredAt: occurredAt,
    );

    expect(result.restoredViews.map((view) => view.id), [
      blockersView.id,
      approverView.id,
    ]);
    expect(result.session.views.map((view) => view.id), [
      blockersView.id,
      approverView.id,
    ]);
    expect(result.session.auditEvents.map((event) => event.action), [
      WorkQueueSavedViewManagerAuditAction.restored,
      WorkQueueSavedViewManagerAuditAction.restored,
    ]);
    expect(result.session.auditEvents.map((event) => event.viewId), [
      blockersView.id,
      approverView.id,
    ]);
    expect(result.session.auditEvents.map((event) => event.occurredAt), [
      occurredAt,
      occurredAt,
    ]);
  });

  test('exposes recoverable history candidates', () {
    final deletedView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final session = WorkQueueSavedViewManagerSession.create(
      views: const [],
      auditEvents: [
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: deletedView.label,
          viewId: deletedView.id,
          rolePreset: deletedView.rolePreset,
          savedView: deletedView,
        ),
      ],
    );

    expect(session.recoveryCandidates.single.restoredView.id, deletedView.id);
    expect(
      session.recoveryCandidates.single.restoredView.label,
      'Month-end blockers',
    );
  });
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceWorkQueueFocus focus,
  required String label,
  AccountingWorkspaceWorkQueueSort sort =
      AccountingWorkspaceWorkQueueSort.workflow,
  String? ownerFilter,
  String? selectedQueueId,
  String? selectedQueueTitle,
  AccountingWorkspaceWorkQueueDetailSection detailSection =
      AccountingWorkspaceWorkQueueDetailSection.overview,
}) {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: focus,
    sort: sort,
    ownerFilter: ownerFilter,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: selectedQueueId,
    selectedQueueTitle: selectedQueueTitle,
    detailSection: detailSection,
  ).copyWith(label: label);
}
