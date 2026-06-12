import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_saved_view_manager_edit_components.dart';

void main() {
  testWidgets('renders pending changes notice action', (tester) async {
    var saved = false;
    var discarded = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkQueueSavedViewManagerPendingChangesNotice(
            pendingCount: 2,
            onSave: () => saved = true,
            onDiscard: () => discarded = true,
          ),
        ),
      ),
    );

    expect(find.text('2 name edits pending'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-discard-pending',
        ),
      ),
    );

    expect(discarded, isTrue);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-save-pending'),
      ),
    );

    expect(saved, isTrue);
  });

  testWidgets('renders compact role group header', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WorkQueueSavedViewManagerRoleGroupHeader(
            rolePreset: AccountingWorkspaceRolePreset.controller,
            viewCount: 2,
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
    expect(find.text('Controller'), findsOneWidget);
    expect(find.text('2 views'), findsOneWidget);
  });

  testWidgets('renders editable saved view row actions and context', (
    tester,
  ) async {
    var changed = false;
    var renamed = false;
    var deleted = false;
    final view = _controllerBlockedSavedView();
    final controller = TextEditingController(text: view.label);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkQueueSavedViewManagerRow(
            view: view,
            controller: controller,
            errorText: null,
            onChanged: (_) => changed = true,
            onRenamed: () => renamed = true,
            onDeleted: () => deleted = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        ValueKey(
          'accounting-work-queue-saved-view-manager-summary-${view.id}-role',
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(
        ValueKey('accounting-work-queue-saved-view-manager-label-${view.id}'),
      ),
      'Close blockers',
    );
    await tester.tap(
      find.byKey(
        ValueKey('accounting-work-queue-saved-view-manager-save-${view.id}'),
      ),
    );
    await tester.tap(
      find.byKey(
        ValueKey('accounting-work-queue-saved-view-manager-delete-${view.id}'),
      ),
    );

    expect(changed, isTrue);
    expect(renamed, isTrue);
    expect(deleted, isTrue);
  });

  testWidgets('renders undo notice and empty state', (tester) async {
    var restored = false;
    final view = _controllerBlockedSavedView();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              WorkQueueSavedViewManagerUndoDeleteNotice(
                view: view,
                onUndo: () => restored = true,
              ),
              const WorkQueueSavedViewManagerEmptyState(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Month-end blockers deleted'), findsOneWidget);
    expect(find.text('No custom queue views saved.'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-delete-undo'),
      ),
    );

    expect(restored, isTrue);
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
