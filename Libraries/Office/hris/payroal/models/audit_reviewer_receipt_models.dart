import 'audit_handoff_delivery_models.dart';

/// Defines the reviewer decision captured after audit handoff delivery.
enum AuditReviewerReceiptDecision {
  acknowledged('Acknowledged'),
  accepted('Accepted'),
  needsClarification('Needs clarification');

  final String label;

  const AuditReviewerReceiptDecision(this.label);
}

/// Captures reviewer acknowledgement evidence for a delivered audit package.
class AuditReviewerReceiptRecord {
  final String packageId;
  final String reviewer;
  final String reviewerRole;
  final DateTime reviewedAt;
  final AuditReviewerReceiptDecision decision;
  final String note;

  const AuditReviewerReceiptRecord({
    required this.packageId,
    required this.reviewer,
    required this.reviewerRole,
    required this.reviewedAt,
    required this.decision,
    required this.note,
  });

  bool get isComplete {
    return packageId.trim().isNotEmpty &&
        reviewer.trim().isNotEmpty &&
        reviewerRole.trim().isNotEmpty &&
        note.trim().length >= 16;
  }

  bool get isAccepted => decision == AuditReviewerReceiptDecision.accepted;

  bool get needsClarification {
    return decision == AuditReviewerReceiptDecision.needsClarification;
  }
}

/// Stores editable reviewer receipt input before acknowledgement is recorded.
class AuditReviewerReceiptDraft {
  final String reviewer;
  final String reviewerRole;
  final DateTime reviewedAt;
  final AuditReviewerReceiptDecision decision;
  final String note;

  const AuditReviewerReceiptDraft({
    required this.reviewer,
    required this.reviewerRole,
    required this.reviewedAt,
    required this.decision,
    required this.note,
  });

  factory AuditReviewerReceiptDraft.empty(DateTime reviewedAt) {
    return AuditReviewerReceiptDraft(
      reviewer: 'Internal Audit',
      reviewerRole: 'Audit Reviewer',
      reviewedAt: reviewedAt,
      decision: AuditReviewerReceiptDecision.acknowledged,
      note: 'Audit handoff package received for reviewer validation.',
    );
  }

  AuditReviewerReceiptDraft copyWith({
    String? reviewer,
    String? reviewerRole,
    DateTime? reviewedAt,
    AuditReviewerReceiptDecision? decision,
    String? note,
  }) {
    return AuditReviewerReceiptDraft(
      reviewer: reviewer ?? this.reviewer,
      reviewerRole: reviewerRole ?? this.reviewerRole,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      decision: decision ?? this.decision,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    return [
      if (reviewer.trim().isEmpty) 'Enter a reviewer',
      if (reviewerRole.trim().isEmpty) 'Enter a reviewer role',
      if (note.trim().length < 16) 'Enter reviewer notes',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  AuditReviewerReceiptRecord toRecord({required String packageId}) {
    return AuditReviewerReceiptRecord(
      packageId: packageId,
      reviewer: reviewer.trim(),
      reviewerRole: reviewerRole.trim(),
      reviewedAt: reviewedAt,
      decision: decision,
      note: note.trim(),
    );
  }
}

/// Summarizes reviewer receipt status for a delivered audit package.
class AuditReviewerReceiptSummary {
  final AuditHandoffDeliverySummary delivery;
  final AuditReviewerReceiptDraft draft;
  final AuditReviewerReceiptRecord? record;

  const AuditReviewerReceiptSummary({
    required this.delivery,
    required this.draft,
    required this.record,
  });

  bool get isRecorded => record?.isComplete == true;

  bool get canRecord => delivery.isDelivered && !isRecorded;

  bool get canReopen => isRecorded;

  bool get needsClarification => record?.needsClarification == true;

  String get periodLabel => delivery.periodLabel;

  String get statusLabel {
    if (needsClarification) return 'Clarification';
    if (isRecorded) return record!.decision.label;
    if (delivery.isDelivered) return 'Ready';
    return 'Blocked';
  }

  String get nextAction {
    if (needsClarification) {
      return 'Reviewer requested clarification from ${record!.reviewer}.';
    }
    if (isRecorded) {
      return '${record!.reviewer} ${record!.decision.label.toLowerCase()} the handoff package.';
    }
    if (!delivery.isDelivered) return delivery.nextAction;
    return 'Capture reviewer receipt for delivered audit package.';
  }
}
