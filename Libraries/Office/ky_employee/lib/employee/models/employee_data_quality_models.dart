enum EmployeeDataQualityIssueType {
  missingData('Missing data'),
  staleData('Stale data'),
  inconsistentData('Inconsistent data'),
  duplicateRisk('Duplicate risk'),
  governance('Governance'),
  manual('Manual review');

  final String label;

  const EmployeeDataQualityIssueType(this.label);
}

enum EmployeeDataQualitySeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const EmployeeDataQualitySeverity(this.label);
}

enum EmployeeDataQualityStatus {
  open('Open'),
  reviewed('Reviewed'),
  resolved('Resolved'),
  waived('Waived');

  final String label;

  const EmployeeDataQualityStatus(this.label);
}

class EmployeeDataQualityIssue {
  final String id;
  final String employeeId;
  final String field;
  final String title;
  final String detail;
  final String owner;
  final String sourceLabel;
  final DateTime detectedAt;
  final DateTime dueDate;
  final EmployeeDataQualityIssueType type;
  final EmployeeDataQualitySeverity severity;
  final EmployeeDataQualityStatus status;

  const EmployeeDataQualityIssue({
    required this.id,
    required this.employeeId,
    required this.field,
    required this.title,
    required this.detail,
    required this.owner,
    required this.sourceLabel,
    required this.detectedAt,
    required this.dueDate,
    required this.type,
    required this.severity,
    required this.status,
  });

  bool get isOpen {
    return status == EmployeeDataQualityStatus.open ||
        status == EmployeeDataQualityStatus.reviewed;
  }

  bool get isHighRisk {
    return severity == EmployeeDataQualitySeverity.high ||
        severity == EmployeeDataQualitySeverity.critical;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return isOpen && (isHighRisk || isOverdue(asOfDate));
  }

  EmployeeDataQualityIssue copyWith({
    EmployeeDataQualityStatus? status,
    DateTime? dueDate,
  }) {
    return EmployeeDataQualityIssue(
      id: id,
      employeeId: employeeId,
      field: field,
      title: title,
      detail: detail,
      owner: owner,
      sourceLabel: sourceLabel,
      detectedAt: detectedAt,
      dueDate: dueDate ?? this.dueDate,
      type: type,
      severity: severity,
      status: status ?? this.status,
    );
  }
}

class EmployeeDataQualityProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDataQualityIssue> issues;

  const EmployeeDataQualityProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.issues,
  });

  EmployeeDataQualityProfile copyWith({
    List<EmployeeDataQualityIssue>? issues,
  }) {
    return EmployeeDataQualityProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      issues: issues ?? this.issues,
    );
  }

  List<EmployeeDataQualityIssue> get sortedIssues {
    final sorted = [...issues]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final severityCompare = _severityRank(
        a.severity,
      ).compareTo(_severityRank(b.severity));
      if (severityCompare != 0) return severityCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  int get openCount => issues.where((issue) => issue.isOpen).length;

  int get highRiskCount {
    return issues.where((issue) => issue.isOpen && issue.isHighRisk).length;
  }

  int get overdueCount {
    return issues.where((issue) => issue.isOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return issues.where((issue) => issue.needsAttention(asOfDate)).length;
  }

  int get reviewedCount {
    return issues
        .where((issue) => issue.status == EmployeeDataQualityStatus.reviewed)
        .length;
  }

  int get resolvedCount {
    return issues
        .where((issue) => issue.status == EmployeeDataQualityStatus.resolved)
        .length;
  }

  int get waivedCount {
    return issues
        .where((issue) => issue.status == EmployeeDataQualityStatus.waived)
        .length;
  }

  int get score {
    final penalty = issues
        .where((issue) => issue.isOpen)
        .fold<int>(0, (sum, issue) => sum + _severityPenalty(issue.severity));
    return (100 - penalty).clamp(0, 100);
  }

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue data quality issue${overdueCount == 1 ? '' : 's'}.';
    }
    if (highRiskCount > 0) {
      return 'Review $highRiskCount high-risk employee data issue${highRiskCount == 1 ? '' : 's'}.';
    }
    if (openCount > 0) {
      return 'Triage $openCount open employee data issue${openCount == 1 ? '' : 's'}.';
    }
    return 'Employee data quality is clear.';
  }
}

class EmployeeDataQualityIssueDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String field;
  final String title;
  final String detail;
  final String owner;
  final EmployeeDataQualityIssueType type;
  final EmployeeDataQualitySeverity severity;
  final DateTime? dueDate;

  const EmployeeDataQualityIssueDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.field,
    required this.title,
    required this.detail,
    required this.owner,
    required this.type,
    required this.severity,
    required this.dueDate,
  });

  EmployeeDataQualityIssueDraft copyWith({
    String? field,
    String? title,
    String? detail,
    String? owner,
    EmployeeDataQualityIssueType? type,
    EmployeeDataQualitySeverity? severity,
    DateTime? dueDate,
  }) {
    return EmployeeDataQualityIssueDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      field: field ?? this.field,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      owner: owner ?? this.owner,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final due = dueDate == null ? null : _dateOnly(dueDate!);

    if (title.trim().length < 6) {
      errors.add('Issue title must be at least 6 characters');
    }
    if (field.trim().length < 3) {
      errors.add('Enter the affected field or area');
    }
    if (owner.trim().length < 3) {
      errors.add('Assign a data owner');
    }
    if (detail.trim().length < 12) {
      errors.add('Describe the issue in at least 12 characters');
    }
    if (due == null) {
      errors.add('Select a due date');
    } else if (due.isBefore(_dateOnly(asOfDate))) {
      errors.add('Due date cannot be in the past');
    }

    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 6) complete++;
    if (field.trim().length >= 3) complete++;
    if (owner.trim().length >= 3) complete++;
    if (detail.trim().length >= 12) complete++;
    if (dueDate != null && !_dateOnly(dueDate!).isBefore(asOfDate)) {
      complete++;
    }
    return complete / 5;
  }

  EmployeeDataQualityIssue toIssue({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDataQualityIssue(
      id: id,
      employeeId: employeeId,
      field: field.trim(),
      title: title.trim(),
      detail: detail.trim(),
      owner: owner.trim(),
      sourceLabel: 'Manual data review',
      detectedAt: _dateOnly(asOfDate),
      dueDate: _dateOnly(dueDate!),
      type: type,
      severity: severity,
      status: EmployeeDataQualityStatus.open,
    );
  }
}

int _attentionRank(EmployeeDataQualityIssue issue, DateTime asOfDate) {
  return issue.needsAttention(asOfDate) ? 0 : 1;
}

int _statusRank(EmployeeDataQualityStatus status) {
  return switch (status) {
    EmployeeDataQualityStatus.open => 0,
    EmployeeDataQualityStatus.reviewed => 1,
    EmployeeDataQualityStatus.resolved => 2,
    EmployeeDataQualityStatus.waived => 3,
  };
}

int _severityRank(EmployeeDataQualitySeverity severity) {
  return switch (severity) {
    EmployeeDataQualitySeverity.critical => 0,
    EmployeeDataQualitySeverity.high => 1,
    EmployeeDataQualitySeverity.medium => 2,
    EmployeeDataQualitySeverity.low => 3,
  };
}

int _severityPenalty(EmployeeDataQualitySeverity severity) {
  return switch (severity) {
    EmployeeDataQualitySeverity.critical => 35,
    EmployeeDataQualitySeverity.high => 24,
    EmployeeDataQualitySeverity.medium => 14,
    EmployeeDataQualitySeverity.low => 6,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
