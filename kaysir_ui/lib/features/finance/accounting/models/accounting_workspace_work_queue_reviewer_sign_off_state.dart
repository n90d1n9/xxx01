enum AccountingWorkspaceWorkQueueReviewerDecision {
  pending,
  approved,
  returned,
  blocked,
}

class AccountingWorkspaceWorkQueueReviewerSignOffState {
  const AccountingWorkspaceWorkQueueReviewerSignOffState({
    required this.queueId,
    this.decision = AccountingWorkspaceWorkQueueReviewerDecision.pending,
  });

  factory AccountingWorkspaceWorkQueueReviewerSignOffState.fromJson(
    Map<String, Object?> json,
  ) {
    return AccountingWorkspaceWorkQueueReviewerSignOffState(
      queueId: _stringValue(json['queueId']).trim(),
      decision: accountingWorkspaceWorkQueueReviewerDecisionFromStorage(
        json['decision'],
      ),
    );
  }

  final String queueId;
  final AccountingWorkspaceWorkQueueReviewerDecision decision;

  bool get hasDecision =>
      decision != AccountingWorkspaceWorkQueueReviewerDecision.pending;

  bool get isApproved =>
      decision == AccountingWorkspaceWorkQueueReviewerDecision.approved;

  String get statusLabel {
    switch (decision) {
      case AccountingWorkspaceWorkQueueReviewerDecision.pending:
        return 'Pending review';
      case AccountingWorkspaceWorkQueueReviewerDecision.approved:
        return 'Approved';
      case AccountingWorkspaceWorkQueueReviewerDecision.returned:
        return 'Returned';
      case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
        return 'Blocked';
    }
  }

  String get detailLabel {
    switch (decision) {
      case AccountingWorkspaceWorkQueueReviewerDecision.pending:
        return 'Reviewer sign-off has not been recorded';
      case AccountingWorkspaceWorkQueueReviewerDecision.approved:
        return 'Reviewer approved clearance evidence';
      case AccountingWorkspaceWorkQueueReviewerDecision.returned:
        return 'Reviewer returned evidence for owner rework';
      case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
        return 'Reviewer blocked clearance';
    }
  }

  String get nextActionLabel {
    switch (decision) {
      case AccountingWorkspaceWorkQueueReviewerDecision.pending:
        return 'Review evidence and record a decision';
      case AccountingWorkspaceWorkQueueReviewerDecision.approved:
        return 'Move release or close gate forward';
      case AccountingWorkspaceWorkQueueReviewerDecision.returned:
        return 'Send evidence back to owner';
      case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
        return 'Escalate reviewer blocker';
    }
  }

  String get decisionBrief {
    return [
      'Reviewer sign-off: $statusLabel',
      'Detail: $detailLabel',
      'Next action: $nextActionLabel',
    ].join('\n');
  }

  AccountingWorkspaceWorkQueueReviewerSignOffState copyWith({
    AccountingWorkspaceWorkQueueReviewerDecision? decision,
  }) {
    return AccountingWorkspaceWorkQueueReviewerSignOffState(
      queueId: queueId,
      decision: decision ?? this.decision,
    );
  }

  Map<String, Object?> toJson() {
    return {'queueId': queueId, 'decision': decision.storageValue};
  }
}

extension AccountingWorkspaceWorkQueueReviewerDecisionStorage
    on AccountingWorkspaceWorkQueueReviewerDecision {
  String get storageValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueReviewerDecision.pending:
        return 'pending';
      case AccountingWorkspaceWorkQueueReviewerDecision.approved:
        return 'approved';
      case AccountingWorkspaceWorkQueueReviewerDecision.returned:
        return 'returned';
      case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
        return 'blocked';
    }
  }
}

AccountingWorkspaceWorkQueueReviewerDecision
accountingWorkspaceWorkQueueReviewerDecisionFromStorage(Object? value) {
  switch (_stringValue(value).trim().toLowerCase()) {
    case 'approved':
    case 'approve':
      return AccountingWorkspaceWorkQueueReviewerDecision.approved;
    case 'returned':
    case 'return':
      return AccountingWorkspaceWorkQueueReviewerDecision.returned;
    case 'blocked':
    case 'block':
      return AccountingWorkspaceWorkQueueReviewerDecision.blocked;
    default:
      return AccountingWorkspaceWorkQueueReviewerDecision.pending;
  }
}

String _stringValue(Object? value) => value is String ? value : '';
