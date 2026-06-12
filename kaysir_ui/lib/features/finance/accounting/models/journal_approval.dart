import '../accounting_core/models/journal_entry.dart';

/// Lifecycle state for a journal approval request before and after GL posting.
enum JournalApprovalStatus { pendingReview, returned, approved, posted }

/// Risk band used to prioritize journal review and evidence requirements.
enum JournalApprovalRisk { low, medium, high }

/// Audit action captured for journal approval lifecycle events.
enum JournalApprovalAuditAction {
  submitted,
  approved,
  returned,
  resubmitted,
  posted,
  reversalRequested,
}

/// Immutable audit event for one journal approval lifecycle action.
class JournalApprovalAuditEvent {
  const JournalApprovalAuditEvent({
    required this.id,
    required this.action,
    required this.actorName,
    required this.occurredAt,
    this.note,
  });

  factory JournalApprovalAuditEvent.fromJson(Map<String, dynamic> json) {
    return JournalApprovalAuditEvent(
      id: json['id'] as String,
      action: _auditActionFromJson(json['action'] as String?),
      actorName: json['actorName'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      note: json['note'] as String?,
    );
  }

  final String id;
  final JournalApprovalAuditAction action;
  final String actorName;
  final DateTime occurredAt;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'actorName': actorName,
      'occurredAt': occurredAt.toIso8601String(),
      'note': note,
    };
  }
}

/// Journal approval work item that wraps a balanced journal draft with review metadata.
class JournalApprovalRequest {
  const JournalApprovalRequest({
    required this.id,
    required this.draft,
    required this.preparerName,
    required this.reviewerName,
    required this.status,
    required this.submittedAt,
    required this.dueAt,
    this.evidenceReference,
    this.returnReason,
    this.approvalNote,
    this.reviewedAt,
    this.postedAt,
    this.postingId,
    this.reversalDate,
    this.reversalRequestId,
    this.auditTrail = const [],
  });

  factory JournalApprovalRequest.fromJson(Map<String, dynamic> json) {
    final rawAuditTrail = json['auditTrail'] as Iterable? ?? const [];
    return JournalApprovalRequest(
      id: json['id'] as String,
      draft: JournalDraft.fromJson(
        Map<String, dynamic>.from(json['draft'] as Map),
      ),
      preparerName: json['preparerName'] as String,
      reviewerName: json['reviewerName'] as String,
      status: _approvalStatusFromJson(json['status'] as String?),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      evidenceReference: json['evidenceReference'] as String?,
      returnReason: json['returnReason'] as String?,
      approvalNote: json['approvalNote'] as String?,
      reviewedAt: _optionalDateTime(json['reviewedAt']),
      postedAt: _optionalDateTime(json['postedAt']),
      postingId: json['postingId'] as String?,
      reversalDate: _optionalDateTime(json['reversalDate']),
      reversalRequestId: json['reversalRequestId'] as String?,
      auditTrail: [
        for (final rawEvent in rawAuditTrail)
          JournalApprovalAuditEvent.fromJson(
            Map<String, dynamic>.from(rawEvent as Map),
          ),
      ],
    );
  }

  final String id;
  final JournalDraft draft;
  final String preparerName;
  final String reviewerName;
  final JournalApprovalStatus status;
  final DateTime submittedAt;
  final DateTime dueAt;
  final String? evidenceReference;
  final String? returnReason;
  final String? approvalNote;
  final DateTime? reviewedAt;
  final DateTime? postedAt;
  final String? postingId;
  final DateTime? reversalDate;
  final String? reversalRequestId;
  final List<JournalApprovalAuditEvent> auditTrail;

  double get totalAmount => draft.debitTotal;

  JournalApprovalRisk get risk {
    if (draft.source == JournalSource.periodClose || totalAmount >= 100000000) {
      return JournalApprovalRisk.high;
    }
    if (totalAmount >= 25000000) return JournalApprovalRisk.medium;

    return JournalApprovalRisk.low;
  }

  bool get requiresEvidence => risk != JournalApprovalRisk.low;

  bool get hasEvidence => evidenceReference?.trim().isNotEmpty ?? false;

  bool get hasReversalSchedule => reversalDate != null;

  bool get reversalRequested => reversalRequestId?.trim().isNotEmpty ?? false;

  JournalApprovalAuditEvent? get latestAuditEvent =>
      auditTrail.isEmpty ? null : auditTrail.last;

  bool isOverdue(DateTime now) {
    return status == JournalApprovalStatus.pendingReview && dueAt.isBefore(now);
  }

  JournalApprovalRequest copyWith({
    String? id,
    JournalDraft? draft,
    String? preparerName,
    String? reviewerName,
    JournalApprovalStatus? status,
    DateTime? submittedAt,
    DateTime? dueAt,
    Object? evidenceReference = _unset,
    Object? returnReason = _unset,
    Object? approvalNote = _unset,
    Object? reviewedAt = _unset,
    Object? postedAt = _unset,
    Object? postingId = _unset,
    Object? reversalDate = _unset,
    Object? reversalRequestId = _unset,
    List<JournalApprovalAuditEvent>? auditTrail,
  }) {
    return JournalApprovalRequest(
      id: id ?? this.id,
      draft: draft ?? this.draft,
      preparerName: preparerName ?? this.preparerName,
      reviewerName: reviewerName ?? this.reviewerName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      dueAt: dueAt ?? this.dueAt,
      evidenceReference:
          evidenceReference == _unset
              ? this.evidenceReference
              : evidenceReference as String?,
      returnReason:
          returnReason == _unset ? this.returnReason : returnReason as String?,
      approvalNote:
          approvalNote == _unset ? this.approvalNote : approvalNote as String?,
      reviewedAt:
          reviewedAt == _unset ? this.reviewedAt : reviewedAt as DateTime?,
      postedAt: postedAt == _unset ? this.postedAt : postedAt as DateTime?,
      postingId: postingId == _unset ? this.postingId : postingId as String?,
      reversalDate:
          reversalDate == _unset
              ? this.reversalDate
              : reversalDate as DateTime?,
      reversalRequestId:
          reversalRequestId == _unset
              ? this.reversalRequestId
              : reversalRequestId as String?,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draft': draft.toJson(),
      'preparerName': preparerName,
      'reviewerName': reviewerName,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'dueAt': dueAt.toIso8601String(),
      'evidenceReference': evidenceReference,
      'returnReason': returnReason,
      'approvalNote': approvalNote,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'postedAt': postedAt?.toIso8601String(),
      'postingId': postingId,
      'reversalDate': reversalDate?.toIso8601String(),
      'reversalRequestId': reversalRequestId,
      'auditTrail': auditTrail.map((event) => event.toJson()).toList(),
    };
  }
}

/// Aggregated counts used by the journal approval dashboard.
class JournalApprovalQueueSummary {
  const JournalApprovalQueueSummary({
    required this.pendingReview,
    required this.returned,
    required this.approved,
    required this.posted,
    required this.totalAmount,
  });

  final int pendingReview;
  final int returned;
  final int approved;
  final int posted;
  final double totalAmount;

  int get openItems => pendingReview + returned + approved;

  factory JournalApprovalQueueSummary.fromRequests(
    Iterable<JournalApprovalRequest> requests,
  ) {
    var pendingReview = 0;
    var returned = 0;
    var approved = 0;
    var posted = 0;
    var totalAmount = 0.0;

    for (final request in requests) {
      totalAmount += request.totalAmount;
      switch (request.status) {
        case JournalApprovalStatus.pendingReview:
          pendingReview++;
        case JournalApprovalStatus.returned:
          returned++;
        case JournalApprovalStatus.approved:
          approved++;
        case JournalApprovalStatus.posted:
          posted++;
      }
    }

    return JournalApprovalQueueSummary(
      pendingReview: pendingReview,
      returned: returned,
      approved: approved,
      posted: posted,
      totalAmount: totalAmount,
    );
  }
}

/// Human-friendly labels for journal approval status values.
extension JournalApprovalStatusLabel on JournalApprovalStatus {
  String get label {
    switch (this) {
      case JournalApprovalStatus.pendingReview:
        return 'Pending review';
      case JournalApprovalStatus.returned:
        return 'Returned';
      case JournalApprovalStatus.approved:
        return 'Approved';
      case JournalApprovalStatus.posted:
        return 'Posted';
    }
  }
}

/// Human-friendly labels for journal approval risk bands.
extension JournalApprovalRiskLabel on JournalApprovalRisk {
  String get label {
    switch (this) {
      case JournalApprovalRisk.low:
        return 'Low risk';
      case JournalApprovalRisk.medium:
        return 'Medium risk';
      case JournalApprovalRisk.high:
        return 'High risk';
    }
  }
}

/// Human-friendly labels for journal approval audit actions.
extension JournalApprovalAuditActionLabel on JournalApprovalAuditAction {
  String get label {
    switch (this) {
      case JournalApprovalAuditAction.submitted:
        return 'Submitted';
      case JournalApprovalAuditAction.approved:
        return 'Approved';
      case JournalApprovalAuditAction.returned:
        return 'Returned';
      case JournalApprovalAuditAction.resubmitted:
        return 'Resubmitted';
      case JournalApprovalAuditAction.posted:
        return 'Posted';
      case JournalApprovalAuditAction.reversalRequested:
        return 'Reversal requested';
    }
  }
}

/// Human-friendly labels for journal source values.
extension JournalSourceLabel on JournalSource {
  String get label {
    switch (this) {
      case JournalSource.manualAdjustment:
        return 'Manual adjustment';
      case JournalSource.receivableInvoice:
        return 'Receivable invoice';
      case JournalSource.receivablePayment:
        return 'Receivable payment';
      case JournalSource.payableBill:
        return 'Payable bill';
      case JournalSource.payablePayment:
        return 'Payable payment';
      case JournalSource.periodClose:
        return 'Period close';
    }
  }
}

/// Human-friendly labels for journal line debit and credit sides.
extension JournalSideLabel on JournalSide {
  String get label {
    switch (this) {
      case JournalSide.debit:
        return 'Debit';
      case JournalSide.credit:
        return 'Credit';
    }
  }
}

const _unset = Object();

JournalApprovalStatus _approvalStatusFromJson(String? value) {
  switch (value) {
    case 'returned':
      return JournalApprovalStatus.returned;
    case 'approved':
      return JournalApprovalStatus.approved;
    case 'posted':
      return JournalApprovalStatus.posted;
    case 'pendingReview':
    default:
      return JournalApprovalStatus.pendingReview;
  }
}

JournalApprovalAuditAction _auditActionFromJson(String? value) {
  switch (value) {
    case 'approved':
      return JournalApprovalAuditAction.approved;
    case 'returned':
      return JournalApprovalAuditAction.returned;
    case 'resubmitted':
      return JournalApprovalAuditAction.resubmitted;
    case 'posted':
      return JournalApprovalAuditAction.posted;
    case 'reversalRequested':
      return JournalApprovalAuditAction.reversalRequested;
    case 'submitted':
    default:
      return JournalApprovalAuditAction.submitted;
  }
}

DateTime? _optionalDateTime(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;

  return DateTime.parse(value);
}
