import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_saved_view_components.dart';

void main() {
  testWidgets('renders selectable accounting work queue saved views', (
    tester,
  ) async {
    AccountingWorkspaceWorkQueueSavedView? selectedView;
    AccountingWorkspaceWorkQueueSavedView? deletedView;
    var saveCurrentTapped = false;
    var resetViewTapped = false;
    var ownerFilterCleared = false;
    var queueSelectionCleared = false;
    var detailSectionCleared = false;
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
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AccountingNavigationWorkQueueSavedViews(
              views: [
                ...accountingWorkspaceWorkQueueSavedViewsForRole(
                  AccountingWorkspaceRolePreset.controller,
                ),
                customView,
              ],
              query: '',
              scope: AccountingMenuSearchScope.all,
              rolePreset: AccountingWorkspaceRolePreset.controller,
              focus: AccountingWorkspaceWorkQueueFocus.blocked,
              sort: AccountingWorkspaceWorkQueueSort.urgent,
              ownerFilter: 'Report approver',
              resolutionFilter:
                  AccountingWorkspaceWorkQueueResolutionFilter.all,
              selectedQueueId: 'controller-release-approvals',
              selectedQueueLabel: 'Release approvals',
              detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
              onSelected: (view) => selectedView = view,
              onOwnerFilterCleared: () => ownerFilterCleared = true,
              onQueueSelectionCleared: () => queueSelectionCleared = true,
              onDetailSectionCleared: () => detailSectionCleared = true,
              onContextReset: () => resetViewTapped = true,
              onSaveCurrent: () => saveCurrentTapped = true,
              onDeleted: (view) => deletedView = view,
            ),
          ),
        ),
      ),
    );

    final reportApproverChip = find.byKey(
      const ValueKey(
        'accounting-work-queue-saved-view-controller-report-approver',
      ),
    );

    expect(find.text('Queue Views'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('accounting-work-queue-current-view-context')),
      findsOneWidget,
    );
    expect(find.text('Blocked queues'), findsOneWidget);
    expect(find.text('Sort: Urgent'), findsOneWidget);
    expect(find.text('Owner: Report approver'), findsOneWidget);
    expect(find.text('Queue: Release approvals'), findsOneWidget);
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.text('Report approver'), findsOneWidget);
    expect(find.text('Blocked queues / Workflow'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-custom-marker'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<ChoiceChip>(reportApproverChip).selected, isTrue);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('accounting-work-queue-reset-view')),
          )
          .tooltip,
      'Reset queue view',
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(
              const ValueKey('accounting-work-queue-save-current-view'),
            ),
          )
          .tooltip,
      'Save current queue view',
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-reset-view')),
    );
    await tester.pump();

    expect(resetViewTapped, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-save-current-view')),
    );
    await tester.pump();

    expect(saveCurrentTapped, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-current-view-overflow')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tab: Controls'), findsOneWidget);

    await tester.tap(find.text('Tab: Controls'));
    await tester.pumpAndSettle();

    expect(detailSectionCleared, isTrue);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-current-view-clear-owner'),
      ),
    );
    await tester.pump();

    expect(ownerFilterCleared, isTrue);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-current-view-clear-queue'),
      ),
    );
    await tester.pump();

    expect(queueSelectionCleared, isTrue);

    await tester.tap(reportApproverChip);
    await tester.pump();

    expect(selectedView?.id, 'controller-report-approver');

    await tester.tap(
      find.descendant(
        of: find.byKey(
          ValueKey('accounting-work-queue-saved-view-${customView.id}'),
        ),
        matching: find.byIcon(Icons.close_rounded),
      ),
    );
    await tester.pump();

    expect(deletedView?.id, customView.id);
  });

  testWidgets('marks current queue view save action as update when saved', (
    tester,
  ) async {
    final savedCurrentView = AccountingWorkspaceWorkQueueSavedView.custom(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Report approver',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
      selectedQueueId: 'controller-release-approvals',
      selectedQueueTitle: 'Release approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AccountingNavigationWorkQueueSavedViews(
              views: [savedCurrentView],
              query: '',
              scope: AccountingMenuSearchScope.all,
              rolePreset: AccountingWorkspaceRolePreset.controller,
              focus: AccountingWorkspaceWorkQueueFocus.blocked,
              sort: AccountingWorkspaceWorkQueueSort.urgent,
              ownerFilter: 'Report approver',
              resolutionFilter:
                  AccountingWorkspaceWorkQueueResolutionFilter.all,
              selectedQueueId: 'controller-release-approvals',
              detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
              onSelected: (_) {},
              onSaveCurrent: () {},
            ),
          ),
        ),
      ),
    );

    final saveButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('accounting-work-queue-save-current-view')),
    );

    expect(saveButton.tooltip, 'Update saved queue view');
    expect((saveButton.icon as Icon).icon, Icons.bookmark_added_rounded);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('shows manager action for persisted custom view history', (
    tester,
  ) async {
    var managed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AccountingNavigationWorkQueueSavedViews(
              views: accountingWorkspaceWorkQueueSavedViewsForRole(
                AccountingWorkspaceRolePreset.controller,
              ),
              query: '',
              scope: AccountingMenuSearchScope.all,
              rolePreset: AccountingWorkspaceRolePreset.controller,
              focus: AccountingWorkspaceWorkQueueFocus.all,
              sort: AccountingWorkspaceWorkQueueSort.workflow,
              ownerFilter: null,
              resolutionFilter:
                  AccountingWorkspaceWorkQueueResolutionFilter.all,
              selectedQueueId: null,
              detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
              onSelected: (_) {},
              hasManagedViewHistory: true,
              onManageViews: () => managed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Custom'), findsNothing);
    expect(
      find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
    );
    await tester.pump();

    expect(managed, isTrue);
  });
}
