enum EmployeeAuditTrailSource {
  profile('Profile'),
  records('Records'),
  work('Work'),
  growth('Growth'),
  pay('Pay'),
  security('Security'),
  system('System');

  final String label;

  const EmployeeAuditTrailSource(this.label);
}

enum EmployeeAuditTrailActionType {
  created('Created'),
  updated('Updated'),
  verified('Verified'),
  approved('Approved'),
  rejected('Rejected'),
  escalated('Escalated'),
  archived('Archived'),
  note('Note');

  final String label;

  const EmployeeAuditTrailActionType(this.label);
}

enum EmployeeAuditTrailSeverity {
  info('Info'),
  notice('Notice'),
  warning('Warning'),
  critical('Critical');

  final String label;

  const EmployeeAuditTrailSeverity(this.label);
}

enum EmployeeAuditTrailReviewStatus {
  logged('Logged'),
  reviewRequired('Review required'),
  reviewed('Reviewed'),
  escalated('Escalated'),
  archived('Archived');

  final String label;

  const EmployeeAuditTrailReviewStatus(this.label);
}

class EmployeeAuditTrailEntry {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeAuditTrailSource source;
  final EmployeeAuditTrailActionType actionType;
  final EmployeeAuditTrailSeverity severity;
  final EmployeeAuditTrailReviewStatus reviewStatus;
  final String title;
  final String detail;
  final String actor;
  final DateTime occurredAt;
  final DateTime retentionUntil;
  final bool containsSensitiveData;

  const EmployeeAuditTrailEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.source,
    required this.actionType,
    required this.severity,
    required this.reviewStatus,
    required this.title,
    required this.detail,
    required this.actor,
    required this.occurredAt,
    required this.retentionUntil,
    required this.containsSensitiveData,
  });

  bool get canReview {
    return reviewStatus == EmployeeAuditTrailReviewStatus.reviewRequired ||
        reviewStatus == EmployeeAuditTrailReviewStatus.escalated;
  }

  bool get canEscalate {
    return reviewStatus != EmployeeAuditTrailReviewStatus.escalated &&
        reviewStatus != EmployeeAuditTrailReviewStatus.archived;
  }

  bool get canArchive {
    return reviewStatus != EmployeeAuditTrailReviewStatus.archived;
  }

  bool isRecent(DateTime asOfDate) {
    return !occurredAt.isBefore(
      _dateOnly(asOfDate).subtract(const Duration(days: 30)),
    );
  }

  bool isRetentionDueSoon(DateTime asOfDate) {
    if (reviewStatus == EmployeeAuditTrailReviewStatus.archived) return false;
    final today = _dateOnly(asOfDate);
    return !retentionUntil.isBefore(today) &&
        !retentionUntil.isAfter(today.add(const Duration(days: 30)));
  }

  bool needsAttention(DateTime asOfDate) {
    return reviewStatus == EmployeeAuditTrailReviewStatus.reviewRequired ||
        reviewStatus == EmployeeAuditTrailReviewStatus.escalated ||
        isRetentionDueSoon(asOfDate);
  }

  EmployeeAuditTrailEntry copyWith({
    EmployeeAuditTrailSeverity? severity,
    EmployeeAuditTrailReviewStatus? reviewStatus,
    String? detail,
  }) {
    return EmployeeAuditTrailEntry(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      source: source,
      actionType: actionType,
      severity: severity ?? this.severity,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      title: title,
      detail: detail ?? this.detail,
      actor: actor,
      occurredAt: occurredAt,
      retentionUntil: retentionUntil,
      containsSensitiveData: containsSensitiveData,
    );
  }
}

class EmployeeAuditTrailProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeAuditTrailEntry> entries;

  const EmployeeAuditTrailProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.entries,
  });

  EmployeeAuditTrailProfile copyWith({List<EmployeeAuditTrailEntry>? entries}) {
    return EmployeeAuditTrailProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      entries: entries ?? this.entries,
    );
  }

  int get recentCount {
    return entries.where((entry) => entry.isRecent(asOfDate)).length;
  }

  int get reviewRequiredCount {
    return entries
        .where(
          (entry) =>
              entry.reviewStatus ==
              EmployeeAuditTrailReviewStatus.reviewRequired,
        )
        .length;
  }

  int get escalatedCount {
    return entries
        .where(
          (entry) =>
              entry.reviewStatus == EmployeeAuditTrailReviewStatus.escalated,
        )
        .length;
  }

  int get sensitiveCount {
    return entries.where((entry) => entry.containsSensitiveData).length;
  }

  int get retentionRiskCount {
    return entries.where((entry) => entry.isRetentionDueSoon(asOfDate)).length;
  }

  int get attentionCount {
    return entries.where((entry) => entry.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (escalatedCount > 0) {
      return 'Resolve $escalatedCount escalated audit event${escalatedCount == 1 ? '' : 's'}.';
    }
    if (reviewRequiredCount > 0) {
      return 'Review $reviewRequiredCount audit event${reviewRequiredCount == 1 ? '' : 's'}.';
    }
    if (retentionRiskCount > 0) {
      return 'Review $retentionRiskCount audit retention item${retentionRiskCount == 1 ? '' : 's'}.';
    }
    return 'Audit trail is current.';
  }
}

class EmployeeAuditTrailDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeAuditTrailSource source;
  final EmployeeAuditTrailActionType actionType;
  final EmployeeAuditTrailSeverity severity;
  final String title;
  final String detail;
  final String actor;
  final bool containsSensitiveData;

  const EmployeeAuditTrailDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.source,
    required this.actionType,
    required this.severity,
    required this.title,
    required this.detail,
    required this.actor,
    required this.containsSensitiveData,
  });

  EmployeeAuditTrailDraft copyWith({
    EmployeeAuditTrailSource? source,
    EmployeeAuditTrailActionType? actionType,
    EmployeeAuditTrailSeverity? severity,
    String? title,
    String? detail,
    String? actor,
    bool? containsSensitiveData,
  }) {
    return EmployeeAuditTrailDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      source: source ?? this.source,
      actionType: actionType ?? this.actionType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      actor: actor ?? this.actor,
      containsSensitiveData:
          containsSensitiveData ?? this.containsSensitiveData,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Audit title must be at least 4 characters');
    }
    if (detail.trim().length < 12) {
      errors.add('Audit detail must be at least 12 characters');
    }
    if (actor.trim().length < 3) {
      errors.add('Actor is required');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          detail.trim().length >= 12,
          actor.trim().length >= 3,
        ].where((item) => item).length;
    return complete / 3;
  }

  EmployeeAuditTrailEntry toEntry({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeAuditTrailEntry(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      source: source,
      actionType: actionType,
      severity: severity,
      reviewStatus: _initialReviewStatus(
        severity: severity,
        containsSensitiveData: containsSensitiveData,
      ),
      title: title.trim(),
      detail: detail.trim(),
      actor: actor.trim(),
      occurredAt: asOfDate,
      retentionUntil: asOfDate.add(const Duration(days: 365 * 7)),
      containsSensitiveData: containsSensitiveData,
    );
  }
}

EmployeeAuditTrailReviewStatus _initialReviewStatus({
  required EmployeeAuditTrailSeverity severity,
  required bool containsSensitiveData,
}) {
  if (severity == EmployeeAuditTrailSeverity.critical ||
      severity == EmployeeAuditTrailSeverity.warning ||
      containsSensitiveData) {
    return EmployeeAuditTrailReviewStatus.reviewRequired;
  }
  return EmployeeAuditTrailReviewStatus.logged;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
