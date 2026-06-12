import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_recovery.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_saved_view_manager_recovery_components.dart';

void main() {
  testWidgets('renders adjusted history recovery labels and context chips', (
    tester,
  ) async {
    WorkQueueSavedViewRecoveryCandidate? restoredCandidate;
    final activeView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      selectedQueueId: null,
      detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
      label: 'Month-end blockers',
    );
    final sourceView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      selectedQueueId: 'controller-release-approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      label: activeView.label,
    );
    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [sourceView],
      activeViews: [activeView],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkQueueSavedViewManagerHistoryRecoveryNotice(
            candidates: candidates,
            onRestore: (candidate) => restoredCandidate = candidate,
            onRestoreAll: (_) {},
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
          '${sourceView.id}-work',
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

    expect(
      restoredCandidate?.restoredView.label,
      'Month-end blockers (restored)',
    );
  });

  testWidgets('offers restore all for multiple history recovery candidates', (
    tester,
  ) async {
    List<WorkQueueSavedViewRecoveryCandidate>? restoredCandidates;
    final firstView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      selectedQueueId: null,
      detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
      label: 'Month-end blockers',
    );
    final secondView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      selectedQueueId: 'controller-release-approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      label: 'Approver pulse',
    );
    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [firstView, secondView],
      activeViews: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkQueueSavedViewManagerHistoryRecoveryNotice(
            candidates: candidates,
            onRestore: (_) {},
            onRestoreAll: (candidates) => restoredCandidates = candidates,
          ),
        ),
      ),
    );

    expect(find.text('2 deleted queue views can be restored'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-history-restore-all',
        ),
      ),
    );
    await tester.pump();

    expect(restoredCandidates?.map((candidate) => candidate.sourceView.id), [
      firstView.id,
      secondView.id,
    ]);
  });
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceWorkQueueFocus focus,
  required String? selectedQueueId,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
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
    selectedQueueId: selectedQueueId,
    selectedQueueTitle: selectedQueueId == null ? null : 'Release approvals',
    detailSection: detailSection,
  ).copyWith(label: label);
}
