import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_work_queue_detail_components.dart';

void main() {
  testWidgets('controls tab blocks reviewer approval until evidence is ready', (
    tester,
  ) async {
    var approved = false;
    const service = AccountingWorkspaceWorkQueueService();
    final queue = service
        .queuesFor(
          rolePreset: AccountingWorkspaceRolePreset.auditor,
          query: 'evidence',
          scope: AccountingMenuSearchScope.shortcuts,
        )
        .firstWhere((queue) => queue.id == 'auditor-evidence-gaps');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AccountingNavigationWorkQueueDetailPanel(
              queue: queue,
              detail: service.detailFor(queue),
              section: AccountingWorkspaceWorkQueueDetailSection.controls,
              onOpen: _noop,
              onCopyBrief: _noop,
              onCopyEvidenceRequest: _noop,
              onCopyLink: _noop,
              onCopyActivityAuditBrief: _noop,
              onCopyClearancePlan: _noop,
              onSectionChanged: (_) {},
              activityActionState:
                  const AccountingWorkspaceWorkQueueActivityActionState(
                    queueId: 'auditor-evidence-gaps',
                  ),
              reviewerSignOffState:
                  const AccountingWorkspaceWorkQueueReviewerSignOffState(
                    queueId: 'auditor-evidence-gaps',
                  ),
              resolutionState:
                  const AccountingWorkspaceWorkQueueResolutionState(
                    queueId: 'auditor-evidence-gaps',
                  ),
              evidenceLinks: const [],
              evidenceReviewStates: const {},
              executionNotes: const [],
              onActivityOwnerAcknowledged: _noop,
              onActivityEvidenceReceived: _noop,
              onActivityEscalationLogged: _noop,
              onEvidenceLinkAdded: (_) {},
              onEvidenceLinkReviewDecisionChanged: (_, _) {},
              onCopyEvidenceLinks: _noop,
              onExecutionNoteAdded: (_) {},
              onCopyExecutionNotes: _noop,
              onReviewerApproved: () => approved = true,
              onReviewerReturned: _noop,
              onReviewerBlocked: _noop,
              onQueueCleared: _noop,
              onClose: _noop,
            ),
          ),
        ),
      ),
    );

    final signOffPanel = find.byKey(
      const ValueKey('accounting-work-queue-reviewer-sign-off-panel'),
    );
    expect(signOffPanel, findsOneWidget);
    expect(
      find.descendant(
        of: signOffPanel,
        matching: find.text('Reviewer sign-off'),
      ),
      findsOneWidget,
    );
    expect(find.text('Evidence gate blocked · 0/4 accepted'), findsOneWidget);
    final resolutionGate = find.byKey(
      const ValueKey('accounting-work-queue-resolution-gate-panel'),
    );
    expect(resolutionGate, findsOneWidget);
    expect(
      find.descendant(
        of: resolutionGate,
        matching: find.text('Evidence gate blocked'),
      ),
      findsOneWidget,
    );
    final markClearedButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('accounting-work-queue-mark-cleared')),
    );
    expect(markClearedButton.onPressed, isNull);
    final approveButton = find.byKey(
      const ValueKey('accounting-work-queue-reviewer-approve'),
    );
    await tester.ensureVisible(approveButton);
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pump();

    expect(approved, isFalse);
  });
}

void _noop() {}
