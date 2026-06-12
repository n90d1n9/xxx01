import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_summary.dart';
import 'package:kaysir/features/finance/accounting/services/work_queue_close_packet_composer.dart';

void main() {
  const composer = AccountingWorkspaceWorkQueueClosePacketComposer();

  test(
    'composes close packet with role, filter, next action, and priorities',
    () {
      const summary = AccountingWorkspaceWorkQueueResolutionSummary(
        queueCount: 4,
        clearedQueueCount: 1,
        readyToClearQueueCount: 1,
        blockedQueueCount: 1,
        waitingQueueCount: 1,
        nextAction: AccountingWorkspaceWorkQueueResolutionNextAction(
          queueId: 'ready-evidence-pack',
          title: 'Ready evidence pack',
          statusLabel: 'Ready to clear',
          actionLabel: 'Mark queue cleared',
          ownerLabel: 'Controller',
          dueLabel: 'Due today',
        ),
      );

      final packet = composer.compose(
        summary: summary,
        filter: AccountingWorkspaceWorkQueueResolutionFilter.all,
        rolePreset: AccountingWorkspaceRolePreset.controller,
        scope: AccountingMenuSearchScope.shortcuts,
        query: 'evidence',
        generatedAt: DateTime(2026, 6, 9, 10, 20),
        briefItems: const [
          AccountingWorkspaceWorkQueueResolutionBriefItem(
            rank: 1,
            queueId: 'ready-evidence-pack',
            title: 'Ready evidence pack',
            statusLabel: 'Ready to clear',
            actionLabel: 'Mark queue cleared',
            ownerLabel: 'Controller',
            dueLabel: 'Due today',
          ),
        ],
        evidenceReadiness: [
          _readiness(
            queueId: 'ready-evidence-pack',
            status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready,
            requestedItemCount: 2,
            linkedEvidenceCount: 2,
            acceptedEvidenceCount: 2,
          ),
          _readiness(
            queueId: 'returned-support',
            status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework,
            requestedItemCount: 2,
            linkedEvidenceCount: 1,
            reworkEvidenceCount: 1,
            remainingRequestedItems: const ['Owner rework memo'],
          ),
        ],
        evidenceQueueTitlesById: const {
          'ready-evidence-pack': 'Ready evidence pack',
          'returned-support': 'Returned support',
        },
      );

      expect(packet, contains('Accounting close packet'));
      expect(packet, contains('Generated: 2026-06-09 10:20'));
      expect(packet, contains('Role: Controller'));
      expect(packet, contains('Scope: Shortcuts'));
      expect(packet, contains('Search: evidence'));
      expect(packet, contains('Resolution view: All'));
      expect(packet, contains('Clearance score: 25% cleared'));
      expect(
        packet,
        contains(
          'Queue coverage: 1 cleared | 1 ready | '
          '1 blocked | 1 waiting',
        ),
      );
      expect(
        packet,
        contains(
          'Control note: Clearance is gated by accepted '
          'evidence, reviewer sign-off, and open checklist blockers.',
        ),
      );
      expect(packet, contains('Next action'));
      expect(packet, contains('Evidence posture'));
      expect(packet, contains('Status: Evidence rework needed'));
      expect(packet, contains('Accepted support: 2/4 accepted'));
      expect(
        packet,
        contains(
          'Queues: 1 ready | 0 review | 1 rework | '
          '0 partial | 0 missing',
        ),
      );
      expect(
        packet,
        contains(
          'Evidence links: 3 linked | '
          '0 pending review | 1 rework',
        ),
      );
      expect(
        packet,
        contains(
          '- Returned support - Rework needed - '
          '0/2 accepted',
        ),
      );
      expect(packet, contains('Ready evidence pack'));
      expect(packet, contains('1. Ready evidence pack - Ready to clear'));
      expect(packet, contains('Review brief'));
      expect(packet, contains('Queue resolution: 1 ready to clear'));
    },
  );

  test('composes filtered packet without query or active next action', () {
    const summary = AccountingWorkspaceWorkQueueResolutionSummary(
      queueCount: 2,
      clearedQueueCount: 2,
      readyToClearQueueCount: 0,
      blockedQueueCount: 0,
      waitingQueueCount: 0,
    );

    final packet = composer.compose(
      summary: summary,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.cleared,
      rolePreset: AccountingWorkspaceRolePreset.auditor,
      scope: AccountingMenuSearchScope.all,
      query: '   ',
      generatedAt: DateTime(2026, 6, 9, 11, 5),
    );

    expect(packet, contains('Generated: 2026-06-09 11:05'));
    expect(packet, contains('Role: Auditor'));
    expect(packet, isNot(contains('Search:')));
    expect(packet, contains('Resolution view: Cleared'));
    expect(packet, contains('Status: All queues cleared'));
    expect(packet, contains('No evidence readiness captured for this packet.'));
    expect(packet, contains('No active cleared review action.'));
    expect(packet, contains('No queues in this packet.'));
    expect(packet, contains('Cleared queue resolution: 2 queues'));
  });
}

AccountingWorkspaceWorkQueueEvidenceReadiness _readiness({
  required String queueId,
  required AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
  required int requestedItemCount,
  required int linkedEvidenceCount,
  int acceptedEvidenceCount = 0,
  int pendingReviewCount = 0,
  int reworkEvidenceCount = 0,
  Iterable<String> remainingRequestedItems = const [],
}) {
  return AccountingWorkspaceWorkQueueEvidenceReadiness(
    queueId: queueId,
    requestedItemCount: requestedItemCount,
    linkedEvidenceCount: linkedEvidenceCount,
    acceptedEvidenceCount: acceptedEvidenceCount,
    pendingReviewCount: pendingReviewCount,
    reworkEvidenceCount: reworkEvidenceCount,
    status: status,
    remainingRequestedItems: remainingRequestedItems,
  );
}
