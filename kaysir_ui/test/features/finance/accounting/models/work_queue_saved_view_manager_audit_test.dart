import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';

void main() {
  test('serializes saved view manager audit events', () {
    final recordedAt = DateTime.utc(2026, 6, 10, 3, 15);
    final savedView = _controllerSavedView().copyWith(
      label: 'Month-end blockers',
    );
    final event = WorkQueueSavedViewManagerAuditEvent(
      action: WorkQueueSavedViewManagerAuditAction.renamed,
      previousLabel: 'Blocked queues / Workflow',
      viewId: savedView.id,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      nextLabel: 'Month-end blockers',
      occurredAt: recordedAt,
      savedView: savedView,
    );

    final restored = workQueueSavedViewManagerAuditEventFromJson(
      event.toJson(),
    );

    expect(event.toJson(), {
      'action': 'renamed',
      'previousLabel': 'Blocked queues / Workflow',
      'viewId': savedView.id,
      'rolePreset': 'controller',
      'nextLabel': 'Month-end blockers',
      'occurredAt': '2026-06-10T03:15:00.000Z',
      'savedView': savedView.toJson(),
    });
    expect(restored?.action, WorkQueueSavedViewManagerAuditAction.renamed);
    expect(restored?.previousLabel, 'Blocked queues / Workflow');
    expect(restored?.viewId, savedView.id);
    expect(restored?.rolePreset, AccountingWorkspaceRolePreset.controller);
    expect(restored?.nextLabel, 'Month-end blockers');
    expect(restored?.occurredAt, recordedAt);
    expect(restored?.savedView?.id, savedView.id);
    expect(restored?.savedView?.label, 'Month-end blockers');
    expect(
      restored?.auditBrief,
      contains('- Renamed "Blocked queues / Workflow" to "Month-end blockers"'),
    );
    expect(restored?.auditBrief, contains('[view: ${savedView.id}]'));
    expect(restored?.auditBrief, contains('(recorded '));
  });

  test('formats saved view manager audit brief for controller handoff', () {
    final brief = workQueueSavedViewManagerAuditBrief(const [
      WorkQueueSavedViewManagerAuditEvent(
        action: WorkQueueSavedViewManagerAuditAction.restored,
        previousLabel: 'Month-end blockers',
      ),
      WorkQueueSavedViewManagerAuditEvent(
        action: WorkQueueSavedViewManagerAuditAction.deleted,
        previousLabel: 'Old approver pulse',
      ),
      WorkQueueSavedViewManagerAuditEvent(
        action: WorkQueueSavedViewManagerAuditAction.renamed,
        previousLabel: 'Blocked queues / Workflow',
        nextLabel: 'Month-end blockers',
      ),
    ]);

    expect(
      brief,
      'Custom queue view changes:\n'
      '- Restored "Month-end blockers"\n'
      '- Deleted "Old approver pulse"\n'
      '- Renamed "Blocked queues / Workflow" to "Month-end blockers"',
    );
  });

  test('formats empty saved view manager audit brief', () {
    expect(
      workQueueSavedViewManagerAuditBrief(const []),
      'Custom queue view changes: none',
    );
  });

  test('filters saved view manager audit events by workspace role', () {
    final controllerSavedView = _controllerSavedView().copyWith(
      label: 'Payload role wins over legacy id',
    );
    final controllerEvents = workQueueSavedViewManagerAuditEventsForRole(
      rolePreset: AccountingWorkspaceRolePreset.controller,
      events: [
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: 'Month-end blockers',
          viewId:
              'custom-controller-all-all-blocked-workflow-all-all-all-overview',
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: 'Controller role wins over legacy id',
          rolePreset: AccountingWorkspaceRolePreset.controller,
          viewId: 'custom-tax-shortcuts-spt-blocked-urgent-tax-reviewer-ready',
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: 'Payload role wins over legacy id',
          viewId: 'custom-tax-shortcuts-spt-blocked-urgent-tax-reviewer-ready',
          savedView: controllerSavedView,
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: 'Tax filing blockers',
          rolePreset: AccountingWorkspaceRolePreset.tax,
          viewId: 'custom-tax-shortcuts-spt-blocked-urgent-tax-reviewer-ready',
        ),
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.restored,
          previousLabel: 'Legacy saved view',
        ),
      ],
    );

    expect(controllerEvents.map((event) => event.previousLabel), [
      'Month-end blockers',
      'Controller role wins over legacy id',
      'Payload role wins over legacy id',
      'Legacy saved view',
    ]);
  });
}

AccountingWorkspaceWorkQueueSavedView _controllerSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.blocked,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: null,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: null,
    selectedQueueTitle: null,
    detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
  );
}
