import 'journal_approval.dart';

/// Posting and reversal linkage for one journal approval request.
class JournalPostingTrace {
  const JournalPostingTrace({
    required this.requestId,
    required this.reference,
    required this.amount,
    required this.status,
    this.postingId,
    this.postedAt,
    this.postingFoundInLedger = false,
    this.originalRequestId,
    this.originalReference,
    this.reversalRequestId,
    this.reversalReference,
    this.reversalStatus,
    this.reversalPostingId,
    this.reversalPostedAt,
    this.reversalAmount = 0,
    this.reversalPostingFoundInLedger = false,
  });

  final String requestId;
  final String reference;
  final double amount;
  final JournalApprovalStatus status;
  final String? postingId;
  final DateTime? postedAt;
  final bool postingFoundInLedger;
  final String? originalRequestId;
  final String? originalReference;
  final String? reversalRequestId;
  final String? reversalReference;
  final JournalApprovalStatus? reversalStatus;
  final String? reversalPostingId;
  final DateTime? reversalPostedAt;
  final double reversalAmount;
  final bool reversalPostingFoundInLedger;

  bool get hasPosting => postingId?.trim().isNotEmpty ?? false;

  bool get hasOriginalLink => originalRequestId?.trim().isNotEmpty ?? false;

  bool get hasReversalLink => reversalRequestId?.trim().isNotEmpty ?? false;

  bool get hasTrace =>
      hasPosting || hasOriginalLink || hasReversalLink || status.isPosted;

  bool get isFullyReversed =>
      status.isPosted && reversalStatus == JournalApprovalStatus.posted;

  double get netExposure => isFullyReversed ? amount - reversalAmount : amount;
}

/// Convenience helpers for journal approval trace status checks.
extension JournalPostingTraceStatus on JournalApprovalStatus {
  bool get isPosted => this == JournalApprovalStatus.posted;
}
