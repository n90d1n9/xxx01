import 'work_queue_evidence_readiness.dart';

/// Approval guard that connects reviewer sign-off with evidence readiness.
class AccountingWorkspaceWorkQueueReviewerSignOffGuard {
  const AccountingWorkspaceWorkQueueReviewerSignOffGuard({
    required this.readiness,
  });

  final AccountingWorkspaceWorkQueueEvidenceReadiness readiness;

  bool get canApprove =>
      readiness.status ==
      AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready;

  String get statusLabel {
    if (canApprove) return 'Approval ready';

    return 'Evidence gate blocked';
  }

  String get detailLabel {
    switch (readiness.status) {
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
        return 'Accepted evidence is complete for reviewer approval.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
        return 'Requested evidence must be attached and accepted first.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
        return 'Attached evidence needs review before approval.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
        return 'Returned evidence needs owner rework before approval.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
        return 'Remaining requested evidence still needs accepted support.';
    }
  }

  String get actionLabel {
    if (canApprove) return 'Approve is available';

    return readiness.nextActionLabel;
  }
}
