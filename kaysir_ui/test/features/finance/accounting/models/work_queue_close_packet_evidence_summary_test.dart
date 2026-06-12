import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_close_packet_evidence_summary.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';

void main() {
  test('summarizes evidence posture across close packet queues', () {
    final summary =
        AccountingWorkspaceWorkQueueClosePacketEvidenceSummary.fromReadiness([
          _readiness(
            queueId: 'ready',
            status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready,
            requestedItemCount: 2,
            linkedEvidenceCount: 2,
            acceptedEvidenceCount: 2,
          ),
          _readiness(
            queueId: 'review',
            status:
                AccountingWorkspaceWorkQueueEvidenceReadinessStatus
                    .reviewNeeded,
            requestedItemCount: 2,
            linkedEvidenceCount: 1,
            pendingReviewCount: 1,
            remainingRequestedItems: const ['Bank confirmation'],
          ),
          _readiness(
            queueId: 'rework',
            status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework,
            requestedItemCount: 1,
            linkedEvidenceCount: 1,
            reworkEvidenceCount: 1,
            remainingRequestedItems: const ['Owner memo'],
          ),
        ]);

    expect(summary.queueCount, 3);
    expect(summary.readyQueueCount, 1);
    expect(summary.reviewNeededQueueCount, 1);
    expect(summary.reworkQueueCount, 1);
    expect(summary.requestedEvidenceCount, 5);
    expect(summary.linkedEvidenceCount, 4);
    expect(summary.acceptedEvidenceCount, 2);
    expect(summary.pendingReviewCount, 1);
    expect(summary.reworkEvidenceCount, 1);
    expect(summary.statusLabel, 'Evidence rework needed');
    expect(summary.coverageLabel, '2/5 accepted');
    expect(
      summary.queueBreakdownLabel,
      '1 ready | 1 review | 1 rework | 0 partial | 0 missing',
    );
    expect(summary.linkReviewLabel, '4 linked | 1 pending review | 1 rework');
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
