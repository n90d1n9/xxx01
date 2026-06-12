import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_saved_view_manager_dialog.dart';

void main() {
  testWidgets('renames and deletes custom accounting work queue views', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final arguments = call.arguments as Map<Object?, Object?>;
          copiedText = arguments['text'] as String?;
        }

        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    AccountingWorkspaceWorkQueueSavedView? renamedView;
    AccountingWorkspaceWorkQueueSavedView? deletedView;
    AccountingWorkspaceWorkQueueSavedView? restoredView;
    final customView = AccountingWorkspaceWorkQueueSavedView.custom(
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [customView],
            onRenamed: (view) => renamedView = view,
            onDeleted: (view) => deletedView = view,
            onRestored: (view) => restoredView = view,
          ),
        ),
      ),
    );

    expect(find.text('Controller'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Workflow'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-summary-'
          '${customView.id}-role',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-summary-'
          '${customView.id}-focus',
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${customView.id}',
        ),
      ),
      'Month-end blockers',
    );
    await tester.tap(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-save-${customView.id}',
        ),
      ),
    );
    await tester.pump();

    expect(renamedView?.id, customView.id);
    expect(renamedView?.label, 'Month-end blockers');
    expect(find.text('Month-end blockers'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-audit'),
      ),
      findsOneWidget,
    );
    expect(find.text('Recent changes'), findsOneWidget);
    expect(
      find.text('Renamed Blocked queues / Workflow to Month-end blockers'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-delete-${customView.id}',
        ),
      ),
    );
    await tester.pump();

    expect(deletedView?.id, customView.id);
    expect(find.text('No custom queue views saved.'), findsOneWidget);
    expect(find.text('Deleted Month-end blockers'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-delete-undo-notice',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Month-end blockers deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-delete-undo'),
      ),
    );
    await tester.pump();

    expect(restoredView?.id, customView.id);
    expect(find.text('No custom queue views saved.'), findsNothing);
    expect(find.text('Restored Month-end blockers'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-audit-copy'),
      ),
    );
    await tester.pump();

    expect(copiedText, contains('Custom queue view changes:'));
    expect(find.text('Recent queue view changes copied'), findsOneWidget);
    expect(copiedText, contains('- Restored "Month-end blockers"'));
    expect(copiedText, contains('- Deleted "Month-end blockers"'));
    expect(
      copiedText,
      contains('- Renamed "Blocked queues / Workflow" to "Month-end blockers"'),
    );
  });

  testWidgets('restores deleted custom queue view from persisted history', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueSavedView? restoredView;
    final deletedView = AccountingWorkspaceWorkQueueSavedView.custom(
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
    ).copyWith(label: 'Month-end blockers');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: const [],
            auditEvents: [
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: deletedView.label,
                viewId: deletedView.id,
                rolePreset: deletedView.rolePreset,
                occurredAt: DateTime.utc(2026, 6, 10, 8),
                savedView: deletedView,
              ),
            ],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: (view) => restoredView = view,
          ),
        ),
      ),
    );

    expect(find.text('No custom queue views saved.'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-notice',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Restore Month-end blockers from history'),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-history-summary-'
          '${deletedView.id}-role',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-history-summary-'
          '${deletedView.id}-focus',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore',
        ),
      ),
    );
    await tester.pump();

    expect(restoredView?.id, deletedView.id);
    expect(find.text('No custom queue views saved.'), findsNothing);
    expect(find.text('Month-end blockers'), findsOneWidget);
    expect(find.text('Restored Month-end blockers'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-notice',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('keeps restored history view names unique', (tester) async {
    AccountingWorkspaceWorkQueueSavedView? restoredView;
    final activeView = _controllerBlockedSavedView();
    final deletedView = _controllerApproverSavedView().copyWith(
      label: activeView.label,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [activeView],
            auditEvents: [
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: deletedView.label,
                viewId: deletedView.id,
                rolePreset: deletedView.rolePreset,
                savedView: deletedView,
              ),
            ],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: (view) => restoredView = view,
          ),
        ),
      ),
    );

    expect(
      find.text('Restore Month-end blockers (restored) from history'),
      findsOneWidget,
    );
    expect(find.text('Original: Month-end blockers'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-history-summary-'
          '${deletedView.id}-work',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-history-summary-'
          '${deletedView.id}-detail',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore',
        ),
      ),
    );
    await tester.pump();

    expect(restoredView?.id, deletedView.id);
    expect(restoredView?.label, 'Month-end blockers (restored)');
    expect(find.text('Restored Month-end blockers (restored)'), findsOneWidget);
  });

  testWidgets('restores multiple deleted custom queue views from history', (
    tester,
  ) async {
    final restoredViews = <AccountingWorkspaceWorkQueueSavedView>[];
    final blockersView = AccountingWorkspaceWorkQueueSavedView.custom(
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
    ).copyWith(label: 'Month-end blockers');
    final approverView = AccountingWorkspaceWorkQueueSavedView.custom(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.review,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Report approver',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
      selectedQueueId: 'controller-release-approvals',
      selectedQueueTitle: 'Release approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    ).copyWith(label: 'Approver pulse');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: const [],
            auditEvents: [
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: blockersView.label,
                viewId: blockersView.id,
                rolePreset: blockersView.rolePreset,
                savedView: blockersView,
              ),
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: approverView.label,
                viewId: approverView.id,
                rolePreset: approverView.rolePreset,
                savedView: approverView,
              ),
            ],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: restoredViews.add,
          ),
        ),
      ),
    );

    expect(find.text('2 deleted queue views can be restored'), findsOneWidget);
    expect(find.text('Month-end blockers'), findsOneWidget);
    expect(find.text('Approver pulse'), findsOneWidget);

    await tester.tap(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-'
          '${blockersView.id}',
        ),
      ),
    );
    await tester.pump();

    expect(restoredViews.map((view) => view.id), [blockersView.id]);
    expect(find.text('Restore Approver pulse from history'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore',
        ),
      ),
    );
    await tester.pump();

    expect(restoredViews.map((view) => view.id), [
      blockersView.id,
      approverView.id,
    ]);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-notice',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('restores all deleted custom queue views from history', (
    tester,
  ) async {
    final restoredViews = <AccountingWorkspaceWorkQueueSavedView>[];
    final blockersView = _controllerBlockedSavedView();
    final approverView = _controllerApproverSavedView();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: const [],
            auditEvents: [
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: blockersView.label,
                viewId: blockersView.id,
                rolePreset: blockersView.rolePreset,
                savedView: blockersView,
              ),
              WorkQueueSavedViewManagerAuditEvent(
                action: WorkQueueSavedViewManagerAuditAction.deleted,
                previousLabel: approverView.label,
                viewId: approverView.id,
                rolePreset: approverView.rolePreset,
                savedView: approverView,
              ),
            ],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: restoredViews.add,
          ),
        ),
      ),
    );

    expect(find.text('2 deleted queue views can be restored'), findsOneWidget);
    expect(find.text('Restore all'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-all',
        ),
      ),
    );
    await tester.pump();

    expect(restoredViews.map((view) => view.id), [
      blockersView.id,
      approverView.id,
    ]);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${approverView.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-notice',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('filters custom queue views inside the manager dialog', (
    tester,
  ) async {
    final blockersView = _controllerBlockedSavedView();
    final approverView = _controllerApproverSavedView();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [blockersView, approverView],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: (_) {},
          ),
        ),
      ),
    );

    final filterField = find.descendant(
      of: find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-filter'),
      ),
      matching: find.byType(TextField),
    );

    expect(filterField, findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${approverView.id}',
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(filterField, 'Approver');
    await tester.pump();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${approverView.id}',
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(filterField, 'missing view');
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-filter-empty'),
      ),
      findsOneWidget,
    );
    expect(find.text('0 / 2'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-filter-clear'),
      ),
    );
    await tester.pump();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${approverView.id}',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('groups mixed-role custom queue views without extra controls', (
    tester,
  ) async {
    final controllerView = _controllerBlockedSavedView();
    final taxView = _taxReviewSavedView();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [controllerView, taxView],
            onRenamed: (_) {},
            onDeleted: (_) {},
            onRestored: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-role-group-controller',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-role-group-tax',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('1 view'), findsNWidgets(2));
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${controllerView.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${taxView.id}',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('saves multiple pending rename drafts together', (tester) async {
    final renamedViews = <AccountingWorkspaceWorkQueueSavedView>[];
    final blockersView = _controllerBlockedSavedView();
    final approverView = _controllerApproverSavedView();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [blockersView, approverView],
            onRenamed: renamedViews.add,
            onDeleted: (_) {},
            onRestored: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
        ),
      ),
      'Close blockers',
    );
    await tester.enterText(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-${approverView.id}',
        ),
      ),
      'Reviewer pulse',
    );
    await tester.pump();

    expect(renamedViews, isEmpty);
    expect(find.text('2 name edits pending'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-save-pending'),
      ),
    );
    await tester.pump();

    expect(renamedViews.map((view) => view.label), [
      'Close blockers',
      'Reviewer pulse',
    ]);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-pending-changes',
        ),
      ),
      findsNothing,
    );
    expect(
      find.text('Renamed Month-end blockers to Close blockers'),
      findsOneWidget,
    );
    expect(
      find.text('Renamed Approver pulse to Reviewer pulse'),
      findsOneWidget,
    );
  });

  testWidgets('discards pending rename drafts and clears validation', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueSavedView? renamedView;
    final blockersView = _controllerBlockedSavedView();
    final labelField = find.byKey(
      ValueKey(
        'accounting-work-queue-saved-view-manager-label-${blockersView.id}',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [blockersView],
            onRenamed: (view) => renamedView = view,
            onDeleted: (_) {},
            onRestored: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(labelField, '   ');
    await tester.pump();
    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-save-pending'),
      ),
    );
    await tester.pump();

    expect(renamedView, isNull);
    expect(find.text('Enter a view name.'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-discard-pending',
        ),
      ),
    );
    await tester.pump();

    final labelTextField = tester.widget<TextField>(labelField);
    expect(labelTextField.controller?.text, 'Month-end blockers');
    expect(find.text('Enter a view name.'), findsNothing);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-pending-changes',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('prevents blank or duplicate custom queue view names', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueSavedView? renamedView;
    final blockersView = AccountingWorkspaceWorkQueueSavedView.custom(
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
    ).copyWith(label: 'Month-end blockers');
    final approverView = AccountingWorkspaceWorkQueueSavedView.custom(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.review,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Report approver',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
      selectedQueueId: 'controller-release-approvals',
      selectedQueueTitle: 'Release approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    ).copyWith(label: 'Approver pulse');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingWorkQueueSavedViewManagerDialog(
            views: [blockersView, approverView],
            onRenamed: (view) => renamedView = view,
            onDeleted: (_) {},
            onRestored: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-'
          '${blockersView.id}',
        ),
      ),
      'Approver pulse',
    );
    await tester.tap(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-save-${blockersView.id}',
        ),
      ),
    );
    await tester.pump();

    expect(renamedView, isNull);
    expect(find.text('Use a unique view name.'), findsOneWidget);

    await tester.enterText(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-label-'
          '${blockersView.id}',
        ),
      ),
      '   ',
    );
    await tester.tap(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-save-${blockersView.id}',
        ),
      ),
    );
    await tester.pump();

    expect(renamedView, isNull);
    expect(find.text('Enter a view name.'), findsOneWidget);
  });
}

AccountingWorkspaceWorkQueueSavedView _controllerBlockedSavedView() {
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
  ).copyWith(label: 'Month-end blockers');
}

AccountingWorkspaceWorkQueueSavedView _controllerApproverSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.review,
    sort: AccountingWorkspaceWorkQueueSort.urgent,
    ownerFilter: 'Report approver',
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: 'controller-release-approvals',
    selectedQueueTitle: 'Release approvals',
    detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
  ).copyWith(label: 'Approver pulse');
}

AccountingWorkspaceWorkQueueSavedView _taxReviewSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: 'spt',
    scope: AccountingMenuSearchScope.shortcuts,
    rolePreset: AccountingWorkspaceRolePreset.tax,
    focus: AccountingWorkspaceWorkQueueFocus.review,
    sort: AccountingWorkspaceWorkQueueSort.urgent,
    ownerFilter: 'Tax reviewer',
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
    selectedQueueId: 'tax-disclosure-review',
    selectedQueueTitle: 'Tax disclosure review',
    detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
  ).copyWith(label: 'SPT review');
}
