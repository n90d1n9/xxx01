enum CompanyControlDomain {
  legalEntity,
  document,
  payroll,
  approval,
  dataPrivacy,
  workLocation,
}

enum CompanyControlStatus { healthy, monitoring, remediation, overdue, waived }

enum CompanyControlSeverity { low, medium, high, critical }

enum CompanyControlIssue {
  missingEntity,
  missingOwner,
  missingEvidence,
  missingRemediation,
  overdueReview,
  remediationRequired,
  criticalSeverity,
}

extension CompanyControlDomainLabels on CompanyControlDomain {
  String get label {
    switch (this) {
      case CompanyControlDomain.legalEntity:
        return 'Legal entity';
      case CompanyControlDomain.document:
        return 'Document';
      case CompanyControlDomain.payroll:
        return 'Payroll';
      case CompanyControlDomain.approval:
        return 'Approval';
      case CompanyControlDomain.dataPrivacy:
        return 'Data privacy';
      case CompanyControlDomain.workLocation:
        return 'Work location';
    }
  }
}

extension CompanyControlStatusLabels on CompanyControlStatus {
  String get label {
    switch (this) {
      case CompanyControlStatus.healthy:
        return 'Healthy';
      case CompanyControlStatus.monitoring:
        return 'Monitoring';
      case CompanyControlStatus.remediation:
        return 'Remediation';
      case CompanyControlStatus.overdue:
        return 'Overdue';
      case CompanyControlStatus.waived:
        return 'Waived';
    }
  }
}

extension CompanyControlSeverityLabels on CompanyControlSeverity {
  String get label {
    switch (this) {
      case CompanyControlSeverity.low:
        return 'Low';
      case CompanyControlSeverity.medium:
        return 'Medium';
      case CompanyControlSeverity.high:
        return 'High';
      case CompanyControlSeverity.critical:
        return 'Critical';
    }
  }
}

extension CompanyControlIssueLabels on CompanyControlIssue {
  String get label {
    switch (this) {
      case CompanyControlIssue.missingEntity:
        return 'Assign entity';
      case CompanyControlIssue.missingOwner:
        return 'Assign owner';
      case CompanyControlIssue.missingEvidence:
        return 'Attach evidence';
      case CompanyControlIssue.missingRemediation:
        return 'Add remediation';
      case CompanyControlIssue.overdueReview:
        return 'Review overdue';
      case CompanyControlIssue.remediationRequired:
        return 'Remediation required';
      case CompanyControlIssue.criticalSeverity:
        return 'Critical control';
    }
  }
}

class CompanyControl {
  final String id;
  final String title;
  final String entityName;
  final CompanyControlDomain domain;
  final CompanyControlStatus status;
  final CompanyControlSeverity severity;
  final String ownerName;
  final DateTime nextReviewDate;
  final String evidenceSummary;
  final String remediationAction;
  final String linkedRecord;

  const CompanyControl({
    required this.id,
    required this.title,
    required this.entityName,
    required this.domain,
    required this.status,
    required this.severity,
    required this.ownerName,
    required this.nextReviewDate,
    required this.evidenceSummary,
    required this.remediationAction,
    required this.linkedRecord,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyControlIssue> issues(DateTime asOfDate) {
    final remediationNeeded =
        status == CompanyControlStatus.remediation ||
        status == CompanyControlStatus.overdue;
    final missingEvidence =
        evidenceSummary.trim().isEmpty && status != CompanyControlStatus.waived;

    return [
      if (entityName.trim().isEmpty) CompanyControlIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyControlIssue.missingOwner,
      if (missingEvidence) CompanyControlIssue.missingEvidence,
      if (remediationNeeded && remediationAction.trim().isEmpty)
        CompanyControlIssue.missingRemediation,
      if (daysUntilReview(asOfDate) < 0) CompanyControlIssue.overdueReview,
      if (remediationNeeded) CompanyControlIssue.remediationRequired,
      if (severity == CompanyControlSeverity.critical)
        CompanyControlIssue.criticalSeverity,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyControl copyWith({
    String? id,
    String? title,
    String? entityName,
    CompanyControlDomain? domain,
    CompanyControlStatus? status,
    CompanyControlSeverity? severity,
    String? ownerName,
    DateTime? nextReviewDate,
    String? evidenceSummary,
    String? remediationAction,
    String? linkedRecord,
  }) {
    return CompanyControl(
      id: id ?? this.id,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      ownerName: ownerName ?? this.ownerName,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      remediationAction: remediationAction ?? this.remediationAction,
      linkedRecord: linkedRecord ?? this.linkedRecord,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyControlDraft {
  final String title;
  final String entityName;
  final CompanyControlDomain domain;
  final CompanyControlStatus status;
  final CompanyControlSeverity severity;
  final String ownerName;
  final String nextReviewDateText;
  final String evidenceSummary;
  final String remediationAction;
  final String linkedRecord;

  const CompanyControlDraft({
    required this.title,
    required this.entityName,
    required this.domain,
    required this.status,
    required this.severity,
    required this.ownerName,
    required this.nextReviewDateText,
    required this.evidenceSummary,
    required this.remediationAction,
    required this.linkedRecord,
  });

  factory CompanyControlDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyControlDraft(
      title: '',
      entityName: entityName,
      domain: CompanyControlDomain.legalEntity,
      status: CompanyControlStatus.monitoring,
      severity: CompanyControlSeverity.medium,
      ownerName: '',
      nextReviewDateText: '',
      evidenceSummary: '',
      remediationAction: '',
      linkedRecord: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    return title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        nextReviewDate != null &&
        evidenceSummary.trim().isNotEmpty;
  }

  CompanyControl toControl(String id) {
    if (!isReady) {
      throw StateError('Complete company control fields before saving.');
    }
    return CompanyControl(
      id: id,
      title: title.trim(),
      entityName: entityName.trim(),
      domain: domain,
      status: status,
      severity: severity,
      ownerName: ownerName.trim(),
      nextReviewDate: nextReviewDate!,
      evidenceSummary: evidenceSummary.trim(),
      remediationAction: remediationAction.trim(),
      linkedRecord: linkedRecord.trim(),
    );
  }

  CompanyControlDraft copyWith({
    String? title,
    String? entityName,
    CompanyControlDomain? domain,
    CompanyControlStatus? status,
    CompanyControlSeverity? severity,
    String? ownerName,
    String? nextReviewDateText,
    String? evidenceSummary,
    String? remediationAction,
    String? linkedRecord,
  }) {
    return CompanyControlDraft(
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      ownerName: ownerName ?? this.ownerName,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      remediationAction: remediationAction ?? this.remediationAction,
      linkedRecord: linkedRecord ?? this.linkedRecord,
    );
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }
}
