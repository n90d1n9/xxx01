import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_recent_view.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_audit.dart';
import 'package:kaysir/features/finance/accounting/repositories/accounting_workspace_recent_view_repository.dart';
import 'package:kaysir/features/finance/accounting/screens/accounting_navigation_screen.dart';

void main() {
  testWidgets('filters accounting workspace destinations from search input', (
    tester,
  ) async {
    await _pumpAccountingNavigation(tester);

    expect(find.text('Accounting Workspace'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('accounting-saved-view-ledger-review')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'spt');
    await tester.pump();

    expect(find.text('Filing'), findsOneWidget);
    expect(find.text('Accounting Policy'), findsNothing);
    expect(find.text('1 match'), findsOneWidget);
  });

  testWidgets('shows an empty state for unmatched accounting search', (
    tester,
  ) async {
    await _pumpAccountingNavigation(tester);

    await tester.enterText(
      find.byType(TextField),
      'not-a-real-accounting-area',
    );
    await tester.pump();

    expect(
      find.text('No accounting matches for "not-a-real-accounting-area"'),
      findsOneWidget,
    );
  });

  testWidgets('filters accounting workspace by shortcut scope', (tester) async {
    await _pumpAccountingNavigation(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AccountingMenuSearchScope>),
        matching: find.text('Shortcuts'),
      ),
    );
    await tester.pump();

    expect(find.text('Focus Shortcuts'), findsOneWidget);
    expect(find.text('Filing'), findsOneWidget);
    expect(find.text('Accounting Policy'), findsNothing);
  });

  testWidgets('applies suggested accounting shortcut searches', (tester) async {
    await _pumpAccountingNavigation(tester);

    await tester.tap(
      find.byKey(const ValueKey('accounting-search-suggestion-Management')),
    );
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'management');
    expect(find.text('Focus Shortcuts'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Approval'), findsOneWidget);
    expect(find.text('Release Sign-off'), findsNothing);
    expect(find.text('5 matches'), findsOneWidget);
  });

  testWidgets('opens accounting screens from the compact screen launcher', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspace,
      extraRoutes: [
        GoRoute(
          path: AccountingPath.trialBalance,
          builder:
              (context, state) =>
                  const Scaffold(body: Text('Trial Balance route')),
        ),
      ],
    );

    final launcher = find.byKey(
      const ValueKey('accounting-header-destination-menu'),
    );

    await tester.tap(launcher);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('accounting-destination-menu-item-trial-balance'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.trialBalance);
    expect(find.text('Trial Balance route'), findsOneWidget);
  });

  testWidgets('opens accounting focus shortcuts from the header launcher', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspace,
      extraRoutes: [
        GoRoute(
          path: AccountingPath.reportRelease,
          builder:
              (context, state) =>
                  const Scaffold(body: Text('Report Release route')),
        ),
      ],
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-header-destination-menu')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('accounting-destination-menu-item-release-evidence'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.reportReleaseEvidence);
    expect(find.text('Report Release route'), findsOneWidget);
  });

  testWidgets('initializes accounting workspace from search arguments', (
    tester,
  ) async {
    await _pumpAccountingNavigation(
      tester,
      child: const AccountingNavigationScreen(
        initialQuery: 'spt',
        initialScope: AccountingMenuSearchScope.shortcuts,
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'spt');
    expect(find.text('Filing'), findsOneWidget);
    expect(find.text('Accounting Policy'), findsNothing);
    expect(find.text('1 match'), findsOneWidget);
  });

  testWidgets('applies saved accounting workspace views', (tester) async {
    await _pumpAccountingNavigation(tester);

    expect(
      find.byKey(const ValueKey('accounting-saved-view-ledger-review')),
      findsOneWidget,
    );

    await tester.tap(find.text('SPT / statutory'));
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'spt');
    expect(find.text('Filing'), findsOneWidget);
    expect(find.text('Accounting Policy'), findsNothing);
    expect(find.text('1 match'), findsOneWidget);
  });

  testWidgets('switches saved accounting workspace views by role preset', (
    tester,
  ) async {
    await _pumpAccountingNavigation(tester);

    expect(find.text('SPT / statutory'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AccountingWorkspaceRolePreset>),
        matching: find.text('Auditor'),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('accounting-saved-view-evidence')),
      findsOneWidget,
    );
    expect(find.text('SPT / statutory'), findsNothing);
    expect(
      find.byKey(const ValueKey('accounting-saved-view-report-pack')),
      findsOneWidget,
    );
  });

  testWidgets('keeps recently used accounting workspace views', (tester) async {
    await _pumpAccountingNavigation(tester);

    await tester.tap(find.text('SPT / statutory'));
    await tester.pump();

    final recentStatutory = find.byKey(
      const ValueKey('accounting-recent-view-shortcuts:spt'),
    );

    expect(find.text('Recent Views'), findsOneWidget);
    expect(recentStatutory, findsOneWidget);

    await tester.tap(find.text('Reconciliation'));
    await tester.pump();

    expect(find.text('Bank Reconciliation'), findsOneWidget);
    expect(recentStatutory, findsOneWidget);

    await tester.tap(recentStatutory);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'spt');
    expect(find.text('Filing'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-recent-views-clear')),
    );
    await tester.pump();

    expect(find.text('Recent Views'), findsNothing);
  });

  testWidgets('hydrates persisted accounting workspace recent views', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.save([
      AccountingWorkspaceRecentView.fromSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.all,
      ),
    ]);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(find.text('Recent Views'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('accounting-recent-view-all:evidence')),
      findsOneWidget,
    );
  });

  testWidgets('hydrates persisted accounting workspace role preset', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.auditor,
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('accounting-saved-view-evidence')),
      findsOneWidget,
    );
    expect(find.text('SPT / statutory'), findsNothing);
  });

  testWidgets('hydrates persisted accounting workspace work queue focus', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueFocus: AccountingWorkspaceWorkQueueFocus.blocked,
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('hydrates persisted accounting work queue owner focus', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueOwnerFilter: 'Report approver',
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(find.text('Report approver selected'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsNothing,
    );
    expect(
      (await repository.loadSnapshot()).workQueueOwnerFilter,
      'Report approver',
    );
  });

  testWidgets('drops stale persisted accounting work queue owner focus', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueOwnerFilter: 'Former approver',
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(find.text('Former approver selected'), findsNothing);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect((await repository.loadSnapshot()).workQueueOwnerFilter, isNull);
  });

  testWidgets('hydrates persisted accounting work queue detail selection', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        selectedWorkQueueId: 'controller-release-approvals',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.activity,
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    final detailPanel = find.byKey(
      const ValueKey(
        'accounting-work-queue-detail-controller-release-approvals',
      ),
    );
    expect(detailPanel, findsOneWidget);
    expect(
      find.descendant(of: detailPanel, matching: find.text('Activity trail')),
      findsOneWidget,
    );
    expect(
      (await repository.loadSnapshot()).selectedWorkQueueId,
      'controller-release-approvals',
    );
    expect(
      (await repository.loadSnapshot()).selectedWorkQueueDetailSection,
      AccountingWorkspaceWorkQueueDetailSection.activity,
    );
  });

  testWidgets('drops stale persisted accounting work queue selection', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        selectedWorkQueueId: 'missing-close-queue',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-detail-missing-close-queue'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect((await repository.loadSnapshot()).selectedWorkQueueId, isNull);
    expect(
      (await repository.loadSnapshot()).selectedWorkQueueDetailSection,
      isNull,
    );
  });

  testWidgets(
    'hydrates and clears persisted accounting work queue resolution filter',
    (tester) async {
      final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
      final repository = AccountingWorkspaceRecentViewRepository(store: store);

      await repository.saveSnapshot(
        const AccountingWorkspaceSnapshot(
          rolePreset: AccountingWorkspaceRolePreset.controller,
          workQueueResolutionFilter:
              AccountingWorkspaceWorkQueueResolutionFilter.ready,
        ),
      );

      await _pumpAccountingNavigation(
        tester,
        child: AccountingNavigationScreen(recentViewRepository: repository),
      );
      await tester.pump();

      expect(find.text('Ready filter active'), findsOneWidget);
      expect(find.text('No ready queues match this view.'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('accounting-work-queue-controller-close-blockers'),
        ),
        findsNothing,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('accounting-work-queue-empty-clear-resolution-filter'),
        ),
      );
      await tester.pump();

      expect(find.text('Ready filter active'), findsNothing);
      expect(
        find.byKey(
          const ValueKey('accounting-work-queue-controller-close-blockers'),
        ),
        findsOneWidget,
      );
      expect(
        (await repository.loadSnapshot()).workQueueResolutionFilter,
        AccountingWorkspaceWorkQueueResolutionFilter.all,
      );
    },
  );

  testWidgets('clears active close command blocker gate', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );
    final blockerGate = find.byKey(
      const ValueKey('accounting-close-command-gate-blockers'),
    );

    expect(blockerGate, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-close-command-gate-blockers-active'),
      ),
      findsOneWidget,
    );

    await tester.tap(blockerGate);
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.workspaceController);
    expect(
      find.byKey(
        const ValueKey('accounting-close-command-gate-blockers-active'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('hydrates persisted accounting workspace work queue sort', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      const AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueSort: AccountingWorkspaceWorkQueueSort.urgent,
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pump();

    final closeBlockers = find.byKey(
      const ValueKey('accounting-work-queue-controller-close-blockers'),
    );
    final releaseApprovals = find.byKey(
      const ValueKey('accounting-work-queue-controller-release-approvals'),
    );

    expect(releaseApprovals, findsOneWidget);
    expect(closeBlockers, findsOneWidget);
    expect(
      tester.getTopLeft(releaseApprovals).dy,
      lessThan(tester.getTopLeft(closeBlockers).dy),
    );
  });

  testWidgets('persists selected accounting workspace role preset', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AccountingWorkspaceRolePreset>),
        matching: find.text('Auditor'),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();

    expect(restoredSnapshot.rolePreset, AccountingWorkspaceRolePreset.auditor);
  });

  testWidgets('persists selected accounting workspace work queue focus', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialRolePreset: AccountingWorkspaceRolePreset.controller,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-focus-selector')),
        matching: find.text('Blocked'),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();

    expect(
      restoredSnapshot.workQueueFocus,
      AccountingWorkspaceWorkQueueFocus.blocked,
    );
  });

  testWidgets('persists selected accounting workspace work queue sort', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialRolePreset: AccountingWorkspaceRolePreset.controller,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-sort-selector')),
        matching: find.text('Urgent'),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();

    expect(
      restoredSnapshot.workQueueSort,
      AccountingWorkspaceWorkQueueSort.urgent,
    );
  });

  testWidgets('persists work queue activity action captures', (tester) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final queueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(queueRow);
    await tester.pumpAndSettle();
    await tester.tap(queueRow);
    await tester.pumpAndSettle();

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    final acknowledgeOwnerButton = find.byKey(
      const ValueKey('accounting-work-queue-activity-acknowledge-owner'),
    );
    await tester.ensureVisible(acknowledgeOwnerButton);
    await tester.pumpAndSettle();
    await tester.tap(acknowledgeOwnerButton);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();
    final actionState = restoredSnapshot.workQueueActivityActionStates.single;

    expect(actionState.queueId, 'auditor-evidence-gaps');
    expect(actionState.ownerAcknowledged, isTrue);
    expect(actionState.evidenceReceived, isFalse);
    expect(actionState.escalationLogged, isFalse);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final restoredQueueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(restoredQueueRow);
    await tester.pumpAndSettle();
    await tester.tap(restoredQueueRow);
    await tester.pumpAndSettle();

    final restoredDetailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: restoredDetailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text('1/3 actions captured'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text('Owner acknowledged'),
      ),
      findsWidgets,
    );
  });

  testWidgets('persists work queue execution notes', (tester) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final queueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(queueRow);
    await tester.pumpAndSettle();
    await tester.tap(queueRow);
    await tester.pumpAndSettle();

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    final addNoteButton = find.byKey(
      const ValueKey('accounting-work-queue-notes-add'),
    );
    await tester.ensureVisible(addNoteButton);
    await tester.pumpAndSettle();
    await tester.tap(addNoteButton);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('accounting-work-queue-note-body-field')),
      'Owner promised signed release support before noon.',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-note-save')),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();
    final note = restoredSnapshot.workQueueNotes.single;

    expect(note.queueId, 'auditor-evidence-gaps');
    expect(note.authorLabel, 'Auditor');
    expect(note.body, 'Owner promised signed release support before noon.');
    expect(find.text('Execution note added'), findsOneWidget);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final restoredQueueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(restoredQueueRow);
    await tester.pumpAndSettle();
    await tester.tap(restoredQueueRow);
    await tester.pumpAndSettle();

    final restoredDetailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: restoredDetailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text('Execution notes'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text(
          'Owner promised signed release support before noon.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('persists work queue evidence links', (tester) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final queueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(queueRow);
    await tester.pumpAndSettle();
    await tester.tap(queueRow);
    await tester.pumpAndSettle();

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

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
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();
    final link = restoredSnapshot.workQueueEvidenceLinks.single;

    expect(link.queueId, 'auditor-evidence-gaps');
    expect(link.addedByLabel, 'Auditor');
    expect(link.label, 'Signed controller approval');
    expect(link.reference, 'APP-42');
    expect(find.text('Evidence link added'), findsOneWidget);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pump();

    final restoredQueueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(restoredQueueRow);
    await tester.pumpAndSettle();
    await tester.tap(restoredQueueRow);
    await tester.pumpAndSettle();

    final restoredDetailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: restoredDetailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text('Evidence links'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: restoredDetailPanel,
        matching: find.text('Signed controller approval'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: restoredDetailPanel, matching: find.text('APP-42')),
      findsOneWidget,
    );
  });

  testWidgets('persists work queue evidence review decisions', (tester) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await repository.saveSnapshot(
      AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.auditor,
        selectedWorkQueueId: 'auditor-evidence-gaps',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.activity,
        workQueueEvidenceLinks: [
          AccountingWorkspaceWorkQueueEvidenceLink.create(
            id: 'link-1',
            queueId: 'auditor-evidence-gaps',
            label: 'Signed controller approval',
            reference: 'APP-42',
            addedByLabel: 'Auditor',
            addedAt: DateTime(2026, 6, 9, 10, 20),
          ),
        ],
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        initialSelectedWorkQueueId: 'auditor-evidence-gaps',
        initialSelectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.activity,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    final acceptButton = find.byKey(
      const ValueKey('accounting-work-queue-evidence-link-accept-link-1'),
    );
    await tester.ensureVisible(acceptButton);
    await tester.pumpAndSettle();
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });

    final restoredSnapshot = await repository.loadSnapshot();
    final reviewState = restoredSnapshot.workQueueEvidenceReviewStates.single;

    expect(reviewState.linkId, 'link-1');
    expect(
      reviewState.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
    );
    expect(reviewState.reviewedByLabel, 'Auditor');
    expect(reviewState.reviewedAt, isNotNull);
    expect(find.text('Evidence link accepted'), findsOneWidget);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        initialSelectedWorkQueueId: 'auditor-evidence-gaps',
        initialSelectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.activity,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('1/4 accepted'), findsOneWidget);
    expect(find.textContaining('Reviewed by Auditor'), findsOneWidget);
  });

  testWidgets('copies activity audit brief with evidence readiness', (
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

    await _pumpAccountingNavigation(
      tester,
      child: const AccountingNavigationScreen(
        initialQuery: 'evidence',
        initialScope: AccountingMenuSearchScope.shortcuts,
        initialRolePreset: AccountingWorkspaceRolePreset.auditor,
        preferInitialRolePreset: true,
      ),
    );
    await tester.pump();

    final queueRow = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );
    await tester.ensureVisible(queueRow);
    await tester.pumpAndSettle();
    await tester.tap(queueRow);
    await tester.pumpAndSettle();

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );
    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    final copyAuditButton = find.byKey(
      const ValueKey('accounting-work-queue-activity-copy-brief'),
    );
    await tester.ensureVisible(copyAuditButton);
    await tester.pumpAndSettle();
    await tester.tap(copyAuditButton);
    await tester.pumpAndSettle();

    expect(copiedText, contains('Activity trail: Audit evidence gaps'));
    expect(copiedText, contains('Evidence readiness: Audit evidence gaps'));
    expect(copiedText, contains('Status: Evidence missing'));
    expect(copiedText, contains('Coverage: 0/4 accepted'));
    expect(copiedText, contains('Evidence links: Audit evidence gaps'));
    expect(copiedText, contains('Execution notes: Audit evidence gaps'));
  });

  testWidgets('keeps accounting workspace role changes in the route', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        query: 'spt',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AccountingWorkspaceRolePreset>),
        matching: find.text('Auditor'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'spt',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
      ),
    );
  });

  testWidgets('keeps committed accounting workspace search in the route', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ledger');
    await tester.pump();

    expect(_currentRoute(router), AccountingPath.workspaceController);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'ledger',
        role: AccountingWorkspaceRolePreset.controller.storageValue,
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AccountingMenuSearchScope>),
        matching: find.text('Screens'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'ledger',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.controller.storageValue,
      ),
    );
  });

  testWidgets('keeps saved accounting workspace views in the route', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );

    await tester.ensureVisible(find.text('Report pack'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report pack'));
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'report pack',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.controller.storageValue,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-recent-view-screens:report pack')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'report pack',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.controller.storageValue,
      ),
    );
  });

  testWidgets(
    'removes accounting workspace search from the route when cleared',
    (tester) async {
      final router = await _pumpAccountingNavigationRoute(
        tester,
        initialLocation: AccountingPath.workspaceWithSearch(
          query: 'evidence',
          scope: AccountingMenuSearchScope.screens.queryValue,
          role: AccountingWorkspaceRolePreset.auditor.storageValue,
        ),
      );

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      expect(
        _currentRoute(router),
        AccountingPath.workspaceWithSearch(
          scope: AccountingMenuSearchScope.screens.queryValue,
          role: AccountingWorkspaceRolePreset.auditor.storageValue,
        ),
      );
    },
  );

  testWidgets('shows and resets active accounting workspace context', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
      ),
    );

    expect(find.text('Active Context'), findsOneWidget);
    expect(find.text('Role: Auditor'), findsOneWidget);
    expect(find.text('Scope: Screens'), findsOneWidget);
    expect(find.text('Search: evidence'), findsOneWidget);
    expect(find.textContaining('Matches:'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('accounting-workspace-reset')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, isEmpty);
    expect(_currentRoute(router), AccountingPath.workspaceAccountant);
    expect(find.text('Role: Accountant'), findsOneWidget);
    expect(find.text('Scope: All'), findsOneWidget);
    expect(find.text('Search: None'), findsOneWidget);
  });

  testWidgets('summarizes active accounting workspace overview metrics', (
    tester,
  ) async {
    await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
      ),
    );

    expect(find.text('Workspace Overview'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-overview-saved-views')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-overview-priority-actions')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-overview-screens')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-overview-shortcuts')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-overview-sections')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows role priority actions and opens a selected action', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
      ),
      extraRoutes: [
        GoRoute(
          path: AccountingPath.reportRelease,
          builder:
              (context, state) =>
                  Text('Report release ${state.uri.queryParameters['focus']}'),
        ),
      ],
    );

    expect(find.text('Priority Actions'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-next-action-auditor-release-evidence'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-next-action-auditor-release-evidence'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.reportReleaseEvidence);
    expect(find.text('Report release evidence'), findsOneWidget);
  });

  testWidgets('shows role work queues and opens a selected queue', (
    tester,
  ) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final initialLocation = AccountingPath.workspaceWithSearch(
      query: 'evidence',
      scope: AccountingMenuSearchScope.shortcuts.queryValue,
      role: AccountingWorkspaceRolePreset.auditor.storageValue,
    );
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: initialLocation,
      extraRoutes: [
        GoRoute(
          path: AccountingPath.reportRelease,
          builder:
              (context, state) =>
                  Text('Report release ${state.uri.queryParameters['focus']}'),
        ),
      ],
    );
    final workQueue = find.byKey(
      const ValueKey('accounting-work-queue-auditor-evidence-gaps'),
    );

    expect(find.text('Work Queues'), findsOneWidget);
    final commandCenter = find.byKey(
      const ValueKey('accounting-close-command-center'),
    );
    expect(commandCenter, findsOneWidget);
    expect(
      find.descendant(
        of: commandCenter,
        matching: find.text('Close Command Center'),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('accounting-close-command-decision')),
          )
          .data,
      'Lock blocked',
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('accounting-close-command-readiness')),
          )
          .data,
      '25% ready',
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-close-command-open')),
        matching: find.text('5 blocked'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-close-command-evidence')),
        matching: find.text('2 days max overdue'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-close-command-posting')),
        matching: find.text('No posting gate'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-close-command-owner')),
        matching: find.text('5 overdue'),
      ),
      findsOneWidget,
    );
    final blockerGate = find.byKey(
      const ValueKey('accounting-close-command-gate-blockers'),
    );
    final evidenceGate = find.byKey(
      const ValueKey('accounting-close-command-gate-evidence'),
    );
    final postingGate = find.byKey(
      const ValueKey('accounting-close-command-gate-posting'),
    );
    expect(blockerGate, findsOneWidget);
    expect(evidenceGate, findsOneWidget);
    expect(postingGate, findsOneWidget);
    expect(
      find.descendant(of: blockerGate, matching: find.text('Blocked')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: blockerGate,
        matching: find.text('5 blockers before lock'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: evidenceGate, matching: find.text('Blocked')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: evidenceGate,
        matching: find.text('2 days max overdue'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: postingGate, matching: find.text('Clear')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: postingGate, matching: find.text('No posting gate')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: commandCenter,
        matching: find.text(
          '#1 Critical overdue · Release blocker · Audit liaison · '
          '2 days overdue',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('accounting-close-command-review-next')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('accounting-close-command-copy-brief')),
    );
    await tester.pumpAndSettle();

    expect(copiedText, contains('Close decision: Lock blocked (25% ready)'));
    expect(
      copiedText,
      contains('Primary action: Clear release blockers before close'),
    );
    expect(copiedText, contains('Gate checks:'));
    expect(
      copiedText,
      contains('- Blockers: Blocked - 5 blockers before lock'),
    );
    expect(copiedText, contains('- Posting: Clear - No posting gate'));
    expect(copiedText, contains('Evidence: 5 - 2 days max overdue'));
    expect(
      copiedText,
      contains(
        'Next action: #1 Critical overdue · Release blocker · Audit liaison',
      ),
    );
    expect(find.text('Close decision brief copied'), findsOneWidget);

    expect(workQueue, findsOneWidget);
    expect(
      find.descendant(
        of: workQueue,
        matching: find.text('Audit evidence gaps'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-open')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-blocked')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-review')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-monitor')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(find.text('Close readiness'), findsOneWidget);
    expect(find.text('Release blocked'), findsOneWidget);
    expect(
      find.text('Clear release blockers before close or reporting lock'),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-readiness-score')),
        matching: find.text('25% ready'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-readiness-score')),
        matching: find.text('Lock blocked'),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Release blockers · 5 items blocking release'),
      findsOneWidget,
    );
    final readinessNextAction = find.byKey(
      const ValueKey('accounting-work-queue-readiness-next-action'),
    );
    expect(readinessNextAction, findsOneWidget);
    expect(
      find.descendant(
        of: readinessNextAction,
        matching: find.text('Audit evidence gaps'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: readinessNextAction,
        matching: find.text(
          '#1 Critical overdue · Release blocker · Audit liaison · '
          '2 days overdue',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('accounting-work-queue-readiness-review-next')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('accounting-work-queue-readiness-blockers'),
        ),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('accounting-work-queue-readiness-evidence'),
        ),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('accounting-work-queue-readiness-posting'),
        ),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-readiness-copy-plan')),
    );
    await tester.pumpAndSettle();

    expect(copiedText, contains('Close readiness: Release blocked'));
    expect(copiedText, contains('Lock gate: Lock blocked'));
    expect(
      copiedText,
      contains('Primary driver: Release blockers - 5 items blocking release'),
    );
    expect(
      copiedText,
      contains(
        '1. Audit evidence gaps - Critical overdue - Release blocker - '
        'Audit liaison',
      ),
    );
    expect(find.text('Close readiness plan copied'), findsOneWidget);

    expect(find.text('SLA pressure'), findsOneWidget);
    expect(find.text('5 time-sensitive'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-sla-overdue')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('accounting-work-queue-sla-worst-overdue'),
        ),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    final ownerCard = find.byKey(
      const ValueKey('accounting-work-queue-owner-Audit liaison'),
    );
    expect(find.text('Owner load'), findsOneWidget);
    expect(find.text('1 owner'), findsOneWidget);
    expect(ownerCard, findsOneWidget);
    expect(
      find.descendant(of: ownerCard, matching: find.text('5 overdue')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ownerCard, matching: find.text('5 items')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: workQueue, matching: find.text('Audit liaison')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: workQueue, matching: find.text('2 days overdue')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-close-command-review-next')),
    );
    await tester.pumpAndSettle();

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-auditor-evidence-gaps'),
    );

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        work: 'auditor-evidence-gaps',
      ),
    );
    expect(workQueue, findsOneWidget);
    expect(detailPanel, findsOneWidget);
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.byKey(
          const ValueKey('accounting-work-queue-detail-section-selector'),
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Overview')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Controls')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Request')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Root cause')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Risk & materiality'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Critical 93/100')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('High reporting materiality'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Release control risk'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Escalation plan')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Release blocker')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Audit liaison + Controller'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Daily until cleared'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Accounting impact'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Financial statement release package'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text(
          'Completeness and authorization of release evidence',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text(
          'No direct tax posting; indirect filing proof risk',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text(
          'Block report release until evidence is signed off',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Journal preview')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Disclosure evidence only'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('No debit/credit entry expected'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Controls')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        work: 'auditor-evidence-gaps',
        detail: 'controls',
      ),
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Clearance checklist'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('0 ready / 0 waiting / 4 blocked'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Owner acknowledgement'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Evidence pack')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Reviewer sign-off'),
      ),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Release or close gate'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Standards & filing'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('IFRS-aligned SAK Indonesia release evidence'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('OJK/IDX-style release governance and audit trail'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Blocks report release readiness'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Record escalation note'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Request')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        work: 'auditor-evidence-gaps',
        detail: 'request',
      ),
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Evidence request')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Evidence request: Audit evidence gaps'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Today before release or close lock'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Overdue follow-up'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Send request and record owner response today'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text(
          'Support completeness and authorization of release evidence',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.textContaining('Release manifest support'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: detailPanel, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        work: 'auditor-evidence-gaps',
        detail: 'activity',
      ),
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Activity trail')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Evidence request issued'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Reviewer sign-off'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.textContaining(
          'OJK/IDX-style release governance and audit trail',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('0/3 actions captured'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Acknowledge owner response'),
      ),
      findsOneWidget,
    );

    final acknowledgeOwnerButton = find.byKey(
      const ValueKey('accounting-work-queue-activity-acknowledge-owner'),
    );
    await tester.ensureVisible(acknowledgeOwnerButton);
    await tester.pumpAndSettle();
    await tester.tap(acknowledgeOwnerButton);
    await tester.pumpAndSettle();

    expect(find.text('Owner acknowledgement captured'), findsOneWidget);
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('1/3 actions captured'),
      ),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Owner acknowledged'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Record evidence receipt'),
      ),
      findsNWidgets(2),
    );

    final evidenceReceivedButton = find.byKey(
      const ValueKey('accounting-work-queue-activity-evidence-received'),
    );
    await tester.ensureVisible(evidenceReceivedButton);
    await tester.pumpAndSettle();
    await tester.tap(evidenceReceivedButton);
    await tester.pumpAndSettle();

    expect(find.text('Evidence receipt captured'), findsOneWidget);
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('2/3 actions captured'),
      ),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Evidence received'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Log escalation outcome'),
      ),
      findsNWidgets(2),
    );

    final logEscalationButton = find.byKey(
      const ValueKey('accounting-work-queue-activity-log-escalation'),
    );
    await tester.ensureVisible(logEscalationButton);
    await tester.pumpAndSettle();
    await tester.tap(logEscalationButton);
    await tester.pumpAndSettle();

    expect(find.text('Escalation outcome logged'), findsOneWidget);
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('3/3 actions captured'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Activity actions complete'),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Escalation logged'),
      ),
      findsOneWidget,
    );

    final copyBriefButton = find.byKey(
      const ValueKey('accounting-work-queue-detail-copy'),
    );
    await tester.ensureVisible(copyBriefButton);
    await tester.pumpAndSettle();
    await tester.tap(copyBriefButton);
    await tester.pumpAndSettle();

    expect(copiedText, contains('Work queue: Audit evidence gaps'));
    expect(copiedText, contains('Owner: Audit liaison'));
    expect(copiedText, contains('SLA: 2 days overdue'));
    expect(copiedText, contains('Risk: Critical (93/100)'));
    expect(copiedText, contains('Materiality: High reporting materiality'));
    expect(copiedText, contains('Control risk: Release control risk'));
    expect(copiedText, contains('Escalation: Release blocker'));
    expect(
      copiedText,
      contains('Escalation owner: Audit liaison + Controller'),
    );
    expect(copiedText, contains('Cadence: Daily until cleared'));
    expect(copiedText, contains('Deadline: Today before release'));
    expect(copiedText, contains('Clearance: 0 ready / 1 waiting / 3 blocked'));
    expect(
      copiedText,
      contains('Framework: IFRS-aligned SAK Indonesia release evidence'),
    );
    expect(copiedText, contains('Local rule: OJK/IDX-style release'));
    expect(copiedText, contains('Retention: Retain signed release pack'));
    expect(copiedText, contains('Filing impact: Blocks report release'));
    expect(
      copiedText,
      contains('Statement area: Financial statement release package'),
    );
    expect(copiedText, contains('Assertion: Completeness and authorization'));
    expect(copiedText, contains('Tax impact: No direct tax posting'));
    expect(copiedText, contains('Close gate: Block report release'));
    expect(copiedText, contains('Journal action: Disclosure evidence'));
    expect(
      copiedText,
      contains('Ledger focus: No debit/credit entry expected'),
    );
    expect(copiedText, contains('Posting gate: Do not release'));
    expect(copiedText, contains('Evidence needed: Release manifest support'));
    expect(copiedText, contains('Next action: Escalate'));
    expect(find.text('Work queue brief copied'), findsOneWidget);

    final copyLinkButton = find.byKey(
      const ValueKey('accounting-work-queue-detail-copy-link'),
    );
    await tester.ensureVisible(copyLinkButton);
    await tester.pumpAndSettle();
    await tester.tap(copyLinkButton);
    await tester.pumpAndSettle();

    expect(
      copiedText,
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.shortcuts.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        work: 'auditor-evidence-gaps',
        detail: 'activity',
      ),
    );
    expect(find.text('Work queue link copied'), findsOneWidget);

    final copyRequestButton = find.byKey(
      const ValueKey('accounting-work-queue-detail-copy-request'),
    );
    await tester.ensureVisible(copyRequestButton);
    await tester.pumpAndSettle();
    await tester.tap(copyRequestButton);
    await tester.pumpAndSettle();

    expect(copiedText, contains('Evidence request: Audit evidence gaps'));
    expect(copiedText, contains('To: Audit liaison'));
    expect(copiedText, contains('SLA: 2 days overdue'));
    expect(copiedText, contains('Response due: Today before release'));
    expect(copiedText, contains('Priority: Critical (93/100)'));
    expect(copiedText, contains('Tracking: Overdue follow-up'));
    expect(copiedText, contains('Follow-up: Daily until cleared'));
    expect(copiedText, contains('- Release manifest support'));
    expect(
      copiedText,
      contains('- Statement area: Financial statement release package'),
    );
    expect(copiedText, contains('- Journal action: Disclosure evidence only'));
    expect(
      copiedText,
      contains('- Ledger focus: No debit/credit entry expected'),
    );
    expect(copiedText, contains('- Close gate: Block report release'));
    expect(
      copiedText,
      contains('Tracking action: Send request and record owner response today'),
    );
    expect(find.text('Evidence request copied'), findsOneWidget);

    final openWorkspaceButton = find.byKey(
      const ValueKey('accounting-work-queue-detail-open'),
    );
    await tester.ensureVisible(openWorkspaceButton);
    await tester.pumpAndSettle();
    await tester.tap(openWorkspaceButton);
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.reportReleaseEvidence);
    expect(find.text('Report release evidence'), findsOneWidget);
  });

  testWidgets('initializes role work queue focus from the route', (
    tester,
  ) async {
    await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
      ),
    );

    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('initializes role work queue owner from the route', (
    tester,
  ) async {
    await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        owner: 'Report approver',
      ),
    );

    expect(find.text('Report approver selected'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsNothing,
    );
  });

  testWidgets('initializes selected work queue detail from the route', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        work: 'controller-close-blockers',
        detail: 'activity',
      ),
    );

    final detailPanel = find.byKey(
      const ValueKey('accounting-work-queue-detail-controller-close-blockers'),
    );

    expect(detailPanel, findsOneWidget);
    expect(
      find.descendant(of: detailPanel, matching: find.text('Close blockers')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Activity trail')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailPanel,
        matching: find.text('Evidence request issued'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailPanel, matching: find.text('Root cause')),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );

    final closeDetailButton = find.byKey(
      const ValueKey('accounting-work-queue-detail-close'),
    );
    await tester.ensureVisible(closeDetailButton);
    await tester.pumpAndSettle();
    await tester.tap(closeDetailButton);
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.workspaceController);
    expect(detailPanel, findsNothing);
  });

  testWidgets('filters role work queues by focus segment', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final focusSelector = find.byKey(
      const ValueKey('accounting-work-queue-focus-selector'),
    );

    expect(focusSelector, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-report-pack-exceptions',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: focusSelector, matching: find.text('Blocked')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-open')),
        matching: find.text('16'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-blocked')),
        matching: find.text('6'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('accounting-work-queue-health-review')),
        matching: find.text('10'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-report-pack-exceptions',
        ),
      ),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: focusSelector, matching: find.text('Monitor')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.monitor.queryValue,
      ),
    );
    expect(find.text('No work queues match this focus.'), findsOneWidget);
  });

  testWidgets('applies accounting work queue saved views', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final reportApproverView = find.byKey(
      const ValueKey(
        'accounting-work-queue-saved-view-controller-report-approver',
      ),
    );

    await tester.ensureVisible(reportApproverView);
    await tester.pumpAndSettle();
    await tester.tap(reportApproverView);
    await tester.pumpAndSettle();

    expect(find.text('Report approver selected'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-detail-controller-release-approvals',
        ),
      ),
      findsOneWidget,
    );
    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
        owner: 'Report approver',
        work: 'controller-release-approvals',
        detail: AccountingWorkspaceWorkQueueDetailSection.controls.queryValue,
      ),
    );
  });

  testWidgets('resets active accounting work queue view context', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
        owner: 'Report approver',
        work: 'controller-release-approvals',
        detail: AccountingWorkspaceWorkQueueDetailSection.controls.queryValue,
      ),
    );
    final resetView = find.byKey(
      const ValueKey('accounting-work-queue-reset-view'),
    );

    await tester.ensureVisible(resetView);
    await tester.pumpAndSettle();

    expect(find.text('Report approver selected'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-detail-controller-release-approvals',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(resetView);
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.workspaceController);
    expect(find.text('Report approver selected'), findsNothing);
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-detail-controller-release-approvals',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('saves and deletes custom accounting work queue views', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(
        initialRolePreset: AccountingWorkspaceRolePreset.controller,
        preferInitialRolePreset: true,
        recentViewRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    final focusSelector = find.byKey(
      const ValueKey('accounting-work-queue-focus-selector'),
    );
    await tester.tap(
      find.descendant(of: focusSelector, matching: find.text('Blocked')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-save-current-view')),
    );
    await tester.pumpAndSettle();

    final customViewKey = const ValueKey(
      'accounting-work-queue-saved-view-'
      'custom-controller-all-all-blocked-workflow-all-all-all-overview',
    );

    expect(find.text('Blocked queues / Workflow'), findsOneWidget);
    expect(find.byKey(customViewKey), findsOneWidget);
    expect(
      (await repository.loadSnapshot()).workQueueSavedViews.single.focus,
      AccountingWorkspaceWorkQueueFocus.blocked,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-label-'
          'custom-controller-all-all-blocked-workflow-all-all-all-overview',
        ),
      ),
      'Month-end blockers',
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-saved-view-manager-save-'
          'custom-controller-all-all-blocked-workflow-all-all-all-overview',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      (await repository.loadSnapshot()).workQueueSavedViews.single.label,
      'Month-end blockers',
    );

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-saved-view-manager-close'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Month-end blockers'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-save-current-view')),
    );
    await tester.pumpAndSettle();

    final repeatedSaveSnapshot = await repository.loadSnapshot();
    expect(repeatedSaveSnapshot.workQueueSavedViews, hasLength(1));
    expect(
      repeatedSaveSnapshot.workQueueSavedViews.single.label,
      'Month-end blockers',
    );
    expect(find.text('Month-end blockers'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(customViewKey),
        matching: find.byIcon(Icons.close_rounded),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(customViewKey), findsNothing);
    expect((await repository.loadSnapshot()).workQueueSavedViews, isEmpty);
    expect(find.text('Queue view deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.byKey(customViewKey), findsOneWidget);
    expect(
      (await repository.loadSnapshot()).workQueueSavedViews.single.label,
      'Month-end blockers',
    );
    expect(find.text('Queue view restored'), findsOneWidget);

    final restoredSnapshot = await repository.loadSnapshot();
    final auditBriefs =
        restoredSnapshot.workQueueSavedViewAuditEvents
            .map((event) => event.auditBrief)
            .toList();
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.map(
        (event) => event.viewId,
      ),
      everyElement(
        'custom-controller-all-all-blocked-workflow-all-all-all-overview',
      ),
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.map(
        (event) => event.rolePreset,
      ),
      everyElement(AccountingWorkspaceRolePreset.controller),
    );
    expect(
      restoredSnapshot.workQueueSavedViewAuditEvents.map(
        (event) => event.savedView?.id,
      ),
      everyElement(
        'custom-controller-all-all-blocked-workflow-all-all-all-overview',
      ),
    );
    expect(
      auditBriefs.any(
        (brief) => brief.contains('- Restored "Month-end blockers"'),
      ),
      isTrue,
    );
    expect(
      auditBriefs.any(
        (brief) => brief.contains('- Deleted "Month-end blockers"'),
      ),
      isTrue,
    );
    expect(
      auditBriefs.any(
        (brief) => brief.contains(
          '- Renamed "Blocked queues / Workflow" to "Month-end blockers"',
        ),
      ),
      isTrue,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent changes'), findsOneWidget);
    expect(find.text('Restored Month-end blockers'), findsOneWidget);
    expect(find.text('Deleted Month-end blockers'), findsOneWidget);
  });

  testWidgets(
    'opens saved view manager for persisted history without customs',
    (tester) async {
      final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
      final repository = AccountingWorkspaceRecentViewRepository(store: store);
      final deletedControllerView =
          AccountingWorkspaceWorkQueueSavedView.custom(
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
      final deletedApproverView = AccountingWorkspaceWorkQueueSavedView.custom(
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

      await repository.saveSnapshot(
        AccountingWorkspaceSnapshot(
          rolePreset: AccountingWorkspaceRolePreset.controller,
          workQueueSavedViewAuditEvents: [
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.deleted,
              previousLabel: deletedControllerView.label,
              viewId: deletedControllerView.id,
              rolePreset: AccountingWorkspaceRolePreset.controller,
              savedView: deletedControllerView,
            ),
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.deleted,
              previousLabel: deletedApproverView.label,
              viewId: deletedApproverView.id,
              rolePreset: AccountingWorkspaceRolePreset.controller,
              savedView: deletedApproverView,
            ),
            const WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.deleted,
              previousLabel: 'Tax filing blockers',
              viewId:
                  'custom-tax-shortcuts-spt-blocked-urgent-tax-reviewer-ready',
              rolePreset: AccountingWorkspaceRolePreset.tax,
            ),
          ],
        ),
      );

      await _pumpAccountingNavigation(
        tester,
        child: AccountingNavigationScreen(
          initialRolePreset: AccountingWorkspaceRolePreset.controller,
          preferInitialRolePreset: true,
          recentViewRepository: repository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Month-end blockers'), findsNothing);
      expect(
        find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('accounting-work-queue-manage-custom-views')),
      );
      await tester.pumpAndSettle();

      expect(find.text('No custom queue views saved.'), findsOneWidget);
      expect(find.text('Recent changes'), findsOneWidget);
      expect(find.text('Deleted Month-end blockers'), findsOneWidget);
      expect(find.text('Deleted Approver pulse'), findsOneWidget);
      expect(find.text('Deleted Tax filing blockers'), findsNothing);
      expect(
        find.text('2 deleted queue views can be restored'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey(
            'accounting-work-queue-saved-view-manager-history-restore-notice',
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey(
            'accounting-work-queue-saved-view-manager-history-restore-all',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Restored Month-end blockers'), findsOneWidget);
      expect(find.text('Restored Approver pulse'), findsOneWidget);
      final restoredSnapshot = await repository.loadSnapshot();
      expect(
        restoredSnapshot.workQueueSavedViews.map((view) => view.id),
        unorderedEquals([deletedControllerView.id, deletedApproverView.id]),
      );

      await tester.tap(
        find.byKey(
          const ValueKey('accounting-work-queue-saved-view-manager-close'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          ValueKey(
            'accounting-work-queue-saved-view-${deletedControllerView.id}',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey(
            'accounting-work-queue-saved-view-${deletedApproverView.id}',
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('promotes custom accounting work queue saved views when used', (
    tester,
  ) async {
    final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
    final repository = AccountingWorkspaceRecentViewRepository(store: store);
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

    await repository.saveSnapshot(
      AccountingWorkspaceSnapshot(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueSavedViews: [blockersView, approverView],
      ),
    );

    await _pumpAccountingNavigation(
      tester,
      child: AccountingNavigationScreen(recentViewRepository: repository),
    );
    await tester.pumpAndSettle();

    final blockersChip = find.byKey(
      ValueKey('accounting-work-queue-saved-view-${blockersView.id}'),
    );
    final approverChip = find.byKey(
      ValueKey('accounting-work-queue-saved-view-${approverView.id}'),
    );
    final defaultChip = find.byKey(
      const ValueKey(
        'accounting-work-queue-saved-view-controller-close-blockers',
      ),
    );

    expect(blockersChip, findsOneWidget);
    expect(approverChip, findsOneWidget);
    expect(defaultChip, findsOneWidget);
    expect(
      tester.getTopLeft(blockersChip).dy <= tester.getTopLeft(defaultChip).dy,
      isTrue,
    );

    await tester.tap(approverChip);
    await tester.pumpAndSettle();

    final snapshot = await repository.loadSnapshot();

    expect(snapshot.workQueueSavedViews.first.id, approverView.id);
    expect(snapshot.workQueueSavedViews.last.id, blockersView.id);
    expect(find.text('Report approver selected'), findsOneWidget);
  });

  testWidgets('sorts role work queues by urgency and keeps route shareable', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final sortSelector = find.byKey(
      const ValueKey('accounting-work-queue-sort-selector'),
    );
    final closeBlockers = find.byKey(
      const ValueKey('accounting-work-queue-controller-close-blockers'),
    );
    final releaseApprovals = find.byKey(
      const ValueKey('accounting-work-queue-controller-release-approvals'),
    );

    expect(sortSelector, findsOneWidget);
    expect(closeBlockers, findsOneWidget);
    expect(releaseApprovals, findsOneWidget);
    expect(
      tester.getTopLeft(closeBlockers).dy,
      lessThan(tester.getTopLeft(releaseApprovals).dy),
    );

    await tester.tap(
      find.descendant(of: sortSelector, matching: find.text('Urgent')),
    );
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );
    expect(
      tester.getTopLeft(releaseApprovals).dy,
      lessThan(tester.getTopLeft(closeBlockers).dy),
    );
  });

  testWidgets('focuses blocked work queues from close command blocker gate', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final blockerGate = find.byKey(
      const ValueKey('accounting-close-command-gate-blockers'),
    );

    expect(blockerGate, findsOneWidget);

    await tester.tap(blockerGate);
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsNothing,
    );
    final gateReview = find.byKey(
      const ValueKey('accounting-work-queue-gate-review'),
    );
    expect(gateReview, findsOneWidget);
    expect(
      find.descendant(
        of: gateReview,
        matching: find.text('Gate review: Blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: gateReview,
        matching: find.text('Blocked · 6 blockers before lock'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('sorts close command posting gate by largest load', (
    tester,
  ) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final postingGate = find.byKey(
      const ValueKey('accounting-close-command-gate-posting'),
    );

    expect(postingGate, findsOneWidget);

    await tester.tap(postingGate);
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        sort: AccountingWorkspaceWorkQueueSort.largest.queryValue,
      ),
    );
    final reconciliationExceptions = find.byKey(
      const ValueKey(
        'accounting-work-queue-controller-reconciliation-exceptions',
      ),
    );
    final reportPackExceptions = find.byKey(
      const ValueKey('accounting-work-queue-controller-report-pack-exceptions'),
    );
    expect(reconciliationExceptions, findsOneWidget);
    expect(reportPackExceptions, findsOneWidget);
    expect(
      tester.getTopLeft(reconciliationExceptions).dy,
      lessThan(tester.getTopLeft(reportPackExceptions).dy),
    );
    final gateReview = find.byKey(
      const ValueKey('accounting-work-queue-gate-review'),
    );
    expect(gateReview, findsOneWidget);
    expect(
      find.descendant(
        of: gateReview,
        matching: find.text('Gate review: Posting'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: gateReview,
        matching: find.text('Review · 14 posting gates before lock'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('clears active close command posting gate', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        sort: AccountingWorkspaceWorkQueueSort.largest.queryValue,
      ),
    );

    expect(
      find.byKey(
        const ValueKey('accounting-close-command-gate-posting-active'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('accounting-work-queue-gate-review')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('accounting-work-queue-gate-review-clear')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-gate-review-clear')),
    );
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.workspaceController);
    expect(
      find.byKey(
        const ValueKey('accounting-close-command-gate-posting-active'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('accounting-work-queue-gate-review')),
      findsNothing,
    );
  });

  testWidgets('opens period close workflow from execution panel', (
    tester,
  ) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
      extraRoutes: [
        GoRoute(
          path: AccountingPath.periodClose,
          builder: (context, state) => const Text('Period close workflow'),
        ),
      ],
    );
    final panel = find.byKey(
      const ValueKey('accounting-period-close-execution'),
    );

    expect(panel, findsOneWidget);
    expect(
      find.descendant(of: panel, matching: find.text('Period Close Execution')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('Lock blocked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('accounting-period-close-execution-review')),
      findsOneWidget,
    );
    final ownerHandoff = find.byKey(
      const ValueKey('accounting-period-close-execution-owner-handoff'),
    );
    expect(ownerHandoff, findsOneWidget);
    expect(
      find.descendant(
        of: ownerHandoff,
        matching: find.text('Owner handoff: Controller'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: ownerHandoff,
        matching: find.text('4 critical · 1 queue · 4 items'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-period-close-execution-owner-copy'),
      ),
    );
    await tester.pumpAndSettle();

    expect(copiedText, contains('Close owner handoff: Controller'));
    expect(copiedText, contains('Risk: 4 critical'));
    expect(
      copiedText,
      contains('Requested action: Review owner queue before period lock.'),
    );
    expect(find.text('Owner handoff brief copied'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-period-close-execution-owner-review'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Controller selected'), findsOneWidget);
    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        owner: 'Controller',
      ),
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsNothing,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('accounting-period-close-execution-copy')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('accounting-period-close-execution-copy')),
    );
    await tester.pumpAndSettle();

    expect(copiedText, contains('Period close execution: Lock blocked'));
    expect(copiedText, contains('Owner handoff: Controller'));
    expect(copiedText, contains('Execution steps:'));
    expect(find.text('Period close execution brief copied'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('accounting-period-close-execution-open')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('accounting-period-close-execution-open')),
    );
    await tester.pumpAndSettle();

    expect(_currentRoute(router), AccountingPath.periodClose);
    expect(find.text('Period close workflow'), findsOneWidget);
  });

  testWidgets('reviews period close execution gate steps', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );
    final blockerStep = find.byKey(
      const ValueKey('accounting-period-close-execution-step-blockers'),
    );

    expect(blockerStep, findsOneWidget);

    await tester.tap(blockerStep);
    await tester.pumpAndSettle();

    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );
    final gateReview = find.byKey(
      const ValueKey('accounting-work-queue-gate-review'),
    );
    expect(gateReview, findsOneWidget);
    expect(
      find.descendant(
        of: gateReview,
        matching: find.text('Gate review: Blockers'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('filters role work queues from owner load cards', (tester) async {
    final router = await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceController,
    );

    final ownerCard = find.byKey(
      const ValueKey('accounting-work-queue-owner-Report approver'),
    );

    expect(ownerCard, findsOneWidget);

    await tester.tap(ownerCard);
    await tester.pumpAndSettle();

    expect(find.text('Report approver selected'), findsOneWidget);
    expect(
      _currentRoute(router),
      AccountingPath.workspaceWithSearch(
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        owner: 'Report approver',
      ),
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-owner-clear')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Report approver selected'), findsNothing);
    expect(_currentRoute(router), AccountingPath.workspaceController);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'accounting-work-queue-controller-reconciliation-exceptions',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('copies the current accounting workspace link', (tester) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await _pumpAccountingNavigationRoute(
      tester,
      initialLocation: AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.review.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-workspace-copy-link')),
    );
    await tester.pumpAndSettle();

    expect(
      copiedText,
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.auditor.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.review.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
      ),
    );
    expect(find.text('Accounting workspace link copied'), findsOneWidget);
  });

  testWidgets(
    'explicit accounting role route overrides persisted role preset',
    (tester) async {
      final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
      final repository = AccountingWorkspaceRecentViewRepository(store: store);

      await repository.saveSnapshot(
        const AccountingWorkspaceSnapshot(
          rolePreset: AccountingWorkspaceRolePreset.tax,
        ),
      );

      await _pumpAccountingNavigation(
        tester,
        child: AccountingNavigationScreen(
          initialRolePreset: AccountingWorkspaceRolePreset.auditor,
          preferInitialRolePreset: true,
          recentViewRepository: repository,
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('accounting-saved-view-evidence')),
        findsOneWidget,
      );
      expect(find.text('SPT / statutory'), findsNothing);
    },
  );

  testWidgets(
    'explicit accounting queue route overrides persisted work queue focus',
    (tester) async {
      final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
      final repository = AccountingWorkspaceRecentViewRepository(store: store);

      await repository.saveSnapshot(
        const AccountingWorkspaceSnapshot(
          rolePreset: AccountingWorkspaceRolePreset.controller,
          workQueueFocus: AccountingWorkspaceWorkQueueFocus.blocked,
        ),
      );

      await _pumpAccountingNavigation(
        tester,
        child: AccountingNavigationScreen(
          initialRolePreset: AccountingWorkspaceRolePreset.controller,
          initialWorkQueueFocus: AccountingWorkspaceWorkQueueFocus.review,
          preferInitialRolePreset: true,
          preferInitialWorkQueueFocus: true,
          recentViewRepository: repository,
        ),
      );
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey(
            'accounting-work-queue-controller-reconciliation-exceptions',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('accounting-work-queue-controller-close-blockers'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'explicit accounting sort route overrides persisted work queue sort',
    (tester) async {
      final store = MemoryAccountingWorkspaceRecentViewSnapshotStore();
      final repository = AccountingWorkspaceRecentViewRepository(store: store);

      await repository.saveSnapshot(
        const AccountingWorkspaceSnapshot(
          rolePreset: AccountingWorkspaceRolePreset.controller,
          workQueueSort: AccountingWorkspaceWorkQueueSort.owner,
        ),
      );

      await _pumpAccountingNavigation(
        tester,
        child: AccountingNavigationScreen(
          initialRolePreset: AccountingWorkspaceRolePreset.controller,
          initialWorkQueueSort: AccountingWorkspaceWorkQueueSort.urgent,
          preferInitialRolePreset: true,
          preferInitialWorkQueueSort: true,
          recentViewRepository: repository,
        ),
      );
      await tester.pump();

      final closeBlockers = find.byKey(
        const ValueKey('accounting-work-queue-controller-close-blockers'),
      );
      final releaseApprovals = find.byKey(
        const ValueKey('accounting-work-queue-controller-release-approvals'),
      );

      expect(releaseApprovals, findsOneWidget);
      expect(closeBlockers, findsOneWidget);
      expect(
        tester.getTopLeft(releaseApprovals).dy,
        lessThan(tester.getTopLeft(closeBlockers).dy),
      );
    },
  );
}

Future<void> _pumpAccountingNavigation(
  WidgetTester tester, {
  Widget child = const AccountingNavigationScreen(),
}) async {
  _setAccountingNavigationSurface(tester);

  await tester.pumpWidget(MaterialApp(home: child));
}

Future<GoRouter> _pumpAccountingNavigationRoute(
  WidgetTester tester, {
  required String initialLocation,
  List<RouteBase> extraRoutes = const [],
}) async {
  _setAccountingNavigationSurface(tester);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AccountingPath.workspace,
        builder: (context, state) {
          final rolePreset = accountingWorkspaceRolePresetFromStorage(
            state.uri.queryParameters[AccountingPath.workspaceRoleParam],
          );

          return AccountingNavigationScreen(
            initialQuery:
                state.uri.queryParameters[AccountingPath
                    .workspaceSearchParam] ??
                '',
            initialScope: accountingMenuSearchScopeFromQuery(
              state.uri.queryParameters[AccountingPath.workspaceScopeParam],
            ),
            initialRolePreset:
                rolePreset ?? AccountingWorkspaceRolePreset.accountant,
            initialWorkQueueFocus: accountingWorkspaceWorkQueueFocusFromQuery(
              state.uri.queryParameters[AccountingPath.workspaceQueueParam],
            ),
            initialWorkQueueSort: accountingWorkspaceWorkQueueSortFromQuery(
              state.uri.queryParameters[AccountingPath.workspaceSortParam],
            ),
            initialWorkQueueOwnerFilter:
                state.uri.queryParameters[AccountingPath.workspaceOwnerParam],
            initialSelectedWorkQueueId:
                state.uri.queryParameters[AccountingPath.workspaceWorkParam],
            initialSelectedWorkQueueDetailSection:
                accountingWorkspaceWorkQueueDetailSectionFromQuery(
                  state.uri.queryParameters[AccountingPath
                      .workspaceWorkDetailParam],
                ),
            preferInitialRolePreset: rolePreset != null,
            preferInitialWorkQueueFocus: state.uri.queryParameters.containsKey(
              AccountingPath.workspaceQueueParam,
            ),
            preferInitialWorkQueueSort: state.uri.queryParameters.containsKey(
              AccountingPath.workspaceSortParam,
            ),
          );
        },
      ),
      ...extraRoutes,
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));

  return router;
}

String _currentRoute(GoRouter router) {
  return router.routerDelegate.currentConfiguration.uri.toString();
}

void _setAccountingNavigationSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
