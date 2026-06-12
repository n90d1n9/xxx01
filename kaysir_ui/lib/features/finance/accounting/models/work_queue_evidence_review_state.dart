/// Reviewer decision captured against a work queue evidence reference.
enum AccountingWorkspaceWorkQueueEvidenceReviewDecision {
  pending,
  accepted,
  rework,
}

/// Persisted review state for a single accounting work queue evidence link.
class AccountingWorkspaceWorkQueueEvidenceReviewState {
  const AccountingWorkspaceWorkQueueEvidenceReviewState({
    required this.queueId,
    required this.linkId,
    this.decision = AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending,
    this.reviewNote = '',
    this.reviewedByLabel = '',
    this.reviewedAt,
  });

  factory AccountingWorkspaceWorkQueueEvidenceReviewState.fromJson(
    Map<String, Object?> json,
  ) {
    return AccountingWorkspaceWorkQueueEvidenceReviewState(
      queueId: _stringValue(json['queueId']).trim(),
      linkId: _stringValue(json['linkId']).trim(),
      decision: accountingWorkspaceWorkQueueEvidenceReviewDecisionFromStorage(
        json['decision'],
      ),
      reviewNote:
          _normalizedStringValue(json['reviewNote']) ??
          _normalizedStringValue(json['note']) ??
          '',
      reviewedByLabel:
          _normalizedStringValue(json['reviewedByLabel']) ??
          _normalizedStringValue(json['reviewerLabel']) ??
          '',
      reviewedAt: _dateTimeValue(json['reviewedAt']),
    );
  }

  final String queueId;
  final String linkId;
  final AccountingWorkspaceWorkQueueEvidenceReviewDecision decision;
  final String reviewNote;
  final String reviewedByLabel;
  final DateTime? reviewedAt;

  bool get isPersistable =>
      queueId.trim().isNotEmpty &&
      linkId.trim().isNotEmpty &&
      decision != AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending;

  bool get isAccepted =>
      decision == AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted;

  bool get needsRework =>
      decision == AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework;

  bool get hasReviewNote => reviewNote.trim().isNotEmpty;

  String get normalizedReviewNote => reviewNote.trim();

  bool get hasReviewer => reviewedByLabel.trim().isNotEmpty;

  String get reviewedByDisplayLabel {
    final normalizedReviewer = reviewedByLabel.trim();
    if (normalizedReviewer.isEmpty) return 'Accounting reviewer';

    return normalizedReviewer;
  }

  bool get hasReviewedAt => reviewedAt != null;

  String get reviewedAtLabel {
    final value = reviewedAt;
    if (value == null) return '';

    return _dateTimeLabel(value);
  }

  bool get hasReviewTrail => hasReviewer || hasReviewedAt;

  String get reviewTrailLabel {
    if (!hasReviewTrail) return '';

    final parts = [
      'Reviewed by $reviewedByDisplayLabel',
      if (hasReviewedAt) reviewedAtLabel,
    ];

    return parts.join(' · ');
  }

  String get statusLabel {
    switch (decision) {
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending:
        return 'Review pending';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted:
        return 'Accepted';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework:
        return 'Needs rework';
    }
  }

  String get detailLabel {
    switch (decision) {
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending:
        return 'Evidence support has not been reviewed';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted:
        return 'Evidence support is accepted for clearance';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework:
        return 'Evidence support needs owner rework';
    }
  }

  AccountingWorkspaceWorkQueueEvidenceReviewState copyWith({
    AccountingWorkspaceWorkQueueEvidenceReviewDecision? decision,
    String? reviewNote,
    String? reviewedByLabel,
    DateTime? reviewedAt,
  }) {
    return AccountingWorkspaceWorkQueueEvidenceReviewState(
      queueId: queueId,
      linkId: linkId,
      decision: decision ?? this.decision,
      reviewNote: reviewNote ?? this.reviewNote,
      reviewedByLabel: reviewedByLabel ?? this.reviewedByLabel,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'queueId': queueId,
      'linkId': linkId,
      'decision': decision.storageValue,
      if (hasReviewNote) 'reviewNote': normalizedReviewNote,
      if (hasReviewer) 'reviewedByLabel': reviewedByDisplayLabel,
      if (hasReviewedAt) 'reviewedAt': reviewedAt!.toIso8601String(),
    };
  }
}

/// Draft review decision submitted from the evidence review UI.
class AccountingWorkspaceWorkQueueEvidenceReviewDraft {
  const AccountingWorkspaceWorkQueueEvidenceReviewDraft({
    required this.decision,
    this.reviewNote = '',
  });

  final AccountingWorkspaceWorkQueueEvidenceReviewDecision decision;
  final String reviewNote;

  bool get requiresReviewNote =>
      decision == AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework;

  String get normalizedReviewNote => reviewNote.trim();

  bool get canSubmit =>
      decision != AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending &&
      (!requiresReviewNote || normalizedReviewNote.isNotEmpty);
}

extension AccountingWorkspaceWorkQueueEvidenceReviewDecisionStorage
    on AccountingWorkspaceWorkQueueEvidenceReviewDecision {
  String get storageValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending:
        return 'pending';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted:
        return 'accepted';
      case AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework:
        return 'rework';
    }
  }
}

AccountingWorkspaceWorkQueueEvidenceReviewDecision
accountingWorkspaceWorkQueueEvidenceReviewDecisionFromStorage(Object? value) {
  switch (_stringValue(value).trim().toLowerCase()) {
    case 'accepted':
    case 'accept':
    case 'approved':
    case 'approve':
      return AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted;
    case 'rework':
    case 'returned':
    case 'return':
    case 'reject':
    case 'rejected':
      return AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework;
    default:
      return AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending;
  }
}

String _stringValue(Object? value) => value is String ? value : '';

DateTime? _dateTimeValue(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value)?.toLocal();

  return null;
}

String _dateTimeLabel(DateTime value) {
  final localValue = value.toLocal();

  return '${localValue.year.toString().padLeft(4, '0')}-'
      '${localValue.month.toString().padLeft(2, '0')}-'
      '${localValue.day.toString().padLeft(2, '0')} '
      '${localValue.hour.toString().padLeft(2, '0')}:'
      '${localValue.minute.toString().padLeft(2, '0')}';
}

String? _normalizedStringValue(Object? value) {
  final normalized = _stringValue(value).trim();
  if (normalized.isEmpty) return null;

  return normalized;
}
