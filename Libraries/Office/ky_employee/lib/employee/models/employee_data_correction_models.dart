import 'employee_data_quality_models.dart';

enum EmployeeDataCorrectionStatus {
  submitted('Submitted'),
  inReview('In review'),
  approved('Approved'),
  applied('Applied'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String label;

  const EmployeeDataCorrectionStatus(this.label);
}

class EmployeeDataCorrectionRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String issueId;
  final String issueTitle;
  final String field;
  final String currentValue;
  final String proposedValue;
  final String rationale;
  final String requester;
  final String reviewer;
  final DateTime createdAt;
  final DateTime dueDate;
  final EmployeeDataQualitySeverity severity;
  final EmployeeDataCorrectionStatus status;

  const EmployeeDataCorrectionRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.issueId,
    required this.issueTitle,
    required this.field,
    required this.currentValue,
    required this.proposedValue,
    required this.rationale,
    required this.requester,
    required this.reviewer,
    required this.createdAt,
    required this.dueDate,
    required this.severity,
    required this.status,
  });

  bool get isOpen {
    return status == EmployeeDataCorrectionStatus.submitted ||
        status == EmployeeDataCorrectionStatus.inReview ||
        status == EmployeeDataCorrectionStatus.approved;
  }

  bool get canReview => status == EmployeeDataCorrectionStatus.submitted;

  bool get canApprove => status == EmployeeDataCorrectionStatus.inReview;

  bool get canApply => status == EmployeeDataCorrectionStatus.approved;

  bool get canReject {
    return status == EmployeeDataCorrectionStatus.submitted ||
        status == EmployeeDataCorrectionStatus.inReview;
  }

  bool get canCancel {
    return status == EmployeeDataCorrectionStatus.submitted ||
        status == EmployeeDataCorrectionStatus.inReview;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeDataCorrectionRequest copyWith({
    EmployeeDataCorrectionStatus? status,
    DateTime? dueDate,
  }) {
    return EmployeeDataCorrectionRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      issueId: issueId,
      issueTitle: issueTitle,
      field: field,
      currentValue: currentValue,
      proposedValue: proposedValue,
      rationale: rationale,
      requester: requester,
      reviewer: reviewer,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      severity: severity,
      status: status ?? this.status,
    );
  }
}

class EmployeeDataCorrectionProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDataQualityIssue> issues;
  final List<EmployeeDataCorrectionRequest> requests;

  const EmployeeDataCorrectionProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.issues,
    required this.requests,
  });

  EmployeeDataCorrectionProfile copyWith({
    List<EmployeeDataCorrectionRequest>? requests,
  }) {
    return EmployeeDataCorrectionProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      issues: issues,
      requests: requests ?? this.requests,
    );
  }

  List<EmployeeDataQualityIssue> get openIssues {
    return issues.where((issue) => issue.isOpen).toList();
  }

  List<EmployeeDataCorrectionRequest> get sortedRequests {
    final sorted = [...requests]..sort((a, b) {
      final overdueCompare = _overdueRank(
        a,
        asOfDate,
      ).compareTo(_overdueRank(b, asOfDate));
      if (overdueCompare != 0) return overdueCompare;

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

  int get openCount => requests.where((request) => request.isOpen).length;

  int get submittedCount {
    return requests
        .where(
          (request) => request.status == EmployeeDataCorrectionStatus.submitted,
        )
        .length;
  }

  int get inReviewCount {
    return requests
        .where(
          (request) => request.status == EmployeeDataCorrectionStatus.inReview,
        )
        .length;
  }

  int get approvedCount {
    return requests
        .where(
          (request) => request.status == EmployeeDataCorrectionStatus.approved,
        )
        .length;
  }

  int get appliedCount {
    return requests
        .where(
          (request) => request.status == EmployeeDataCorrectionStatus.applied,
        )
        .length;
  }

  int get overdueCount {
    return requests.where((request) => request.isOverdue(asOfDate)).length;
  }

  int get attentionCount => overdueCount + inReviewCount + approvedCount;

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue data correction request${overdueCount == 1 ? '' : 's'}.';
    }
    if (approvedCount > 0) {
      return 'Apply $approvedCount approved data correction${approvedCount == 1 ? '' : 's'}.';
    }
    if (inReviewCount > 0) {
      return 'Approve or reject $inReviewCount data correction request${inReviewCount == 1 ? '' : 's'}.';
    }
    if (submittedCount > 0) {
      return 'Start review for $submittedCount submitted data correction${submittedCount == 1 ? '' : 's'}.';
    }
    if (openIssues.isNotEmpty) {
      return 'Create correction requests for ${openIssues.length} open data issue${openIssues.length == 1 ? '' : 's'}.';
    }
    return 'No employee data corrections pending.';
  }
}

class EmployeeDataCorrectionDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String issueId;
  final String issueTitle;
  final String field;
  final String currentValue;
  final String proposedValue;
  final String rationale;
  final String requester;
  final String reviewer;
  final EmployeeDataQualitySeverity severity;
  final DateTime? dueDate;

  const EmployeeDataCorrectionDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.issueId,
    required this.issueTitle,
    required this.field,
    required this.currentValue,
    required this.proposedValue,
    required this.rationale,
    required this.requester,
    required this.reviewer,
    required this.severity,
    required this.dueDate,
  });

  factory EmployeeDataCorrectionDraft.fromIssue({
    required String employeeId,
    required String employeeName,
    required DateTime asOfDate,
    required EmployeeDataQualityIssue? issue,
    required String currentValue,
  }) {
    return EmployeeDataCorrectionDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: _dateOnly(asOfDate),
      issueId: issue?.id ?? '',
      issueTitle: issue?.title ?? 'Manual data correction',
      field: issue?.field ?? 'Profile data',
      currentValue: currentValue,
      proposedValue: '',
      rationale: '',
      requester: 'People Operations',
      reviewer: issue?.owner ?? 'HR Business Partner',
      severity: issue?.severity ?? EmployeeDataQualitySeverity.medium,
      dueDate: _dateOnly(asOfDate).add(const Duration(days: 3)),
    );
  }

  EmployeeDataCorrectionDraft copyWith({
    String? issueId,
    String? issueTitle,
    String? field,
    String? currentValue,
    String? proposedValue,
    String? rationale,
    String? requester,
    String? reviewer,
    EmployeeDataQualitySeverity? severity,
    DateTime? dueDate,
  }) {
    return EmployeeDataCorrectionDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      issueId: issueId ?? this.issueId,
      issueTitle: issueTitle ?? this.issueTitle,
      field: field ?? this.field,
      currentValue: currentValue ?? this.currentValue,
      proposedValue: proposedValue ?? this.proposedValue,
      rationale: rationale ?? this.rationale,
      requester: requester ?? this.requester,
      reviewer: reviewer ?? this.reviewer,
      severity: severity ?? this.severity,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final due = dueDate == null ? null : _dateOnly(dueDate!);

    if (issueId.trim().isEmpty) {
      errors.add('Select a data quality issue');
    }
    if (field.trim().length < 3) {
      errors.add('Enter the corrected field');
    }
    if (requester.trim().length < 3) {
      errors.add('Enter the requester');
    }
    if (reviewer.trim().length < 3) {
      errors.add('Assign a reviewer');
    }
    if (proposedValue.trim().length < 2) {
      errors.add('Enter the proposed value');
    }
    if (proposedValue.trim().toLowerCase() ==
        currentValue.trim().toLowerCase()) {
      errors.add('Proposed value must differ from current value');
    }
    if (rationale.trim().length < 12) {
      errors.add('Add a rationale with at least 12 characters');
    }
    if (due == null) {
      errors.add('Select a due date');
    } else if (due.isBefore(_dateOnly(asOfDate))) {
      errors.add('Due date cannot be in the past');
    }

    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (issueId.trim().isNotEmpty) complete++;
    if (field.trim().length >= 3) complete++;
    if (requester.trim().length >= 3) complete++;
    if (reviewer.trim().length >= 3) complete++;
    if (proposedValue.trim().length >= 2 &&
        proposedValue.trim().toLowerCase() !=
            currentValue.trim().toLowerCase()) {
      complete++;
    }
    if (rationale.trim().length >= 12) complete++;
    if (dueDate != null && !_dateOnly(dueDate!).isBefore(asOfDate)) {
      complete++;
    }
    return complete / 7;
  }

  EmployeeDataCorrectionRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDataCorrectionRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      issueId: issueId,
      issueTitle: issueTitle,
      field: field.trim(),
      currentValue: currentValue.trim(),
      proposedValue: proposedValue.trim(),
      rationale: rationale.trim(),
      requester: requester.trim(),
      reviewer: reviewer.trim(),
      createdAt: _dateOnly(asOfDate),
      dueDate: _dateOnly(dueDate!),
      severity: severity,
      status: EmployeeDataCorrectionStatus.submitted,
    );
  }
}

int _overdueRank(EmployeeDataCorrectionRequest request, DateTime asOfDate) {
  return request.isOverdue(asOfDate) ? 0 : 1;
}

int _statusRank(EmployeeDataCorrectionStatus status) {
  return switch (status) {
    EmployeeDataCorrectionStatus.approved => 0,
    EmployeeDataCorrectionStatus.inReview => 1,
    EmployeeDataCorrectionStatus.submitted => 2,
    EmployeeDataCorrectionStatus.rejected => 3,
    EmployeeDataCorrectionStatus.cancelled => 4,
    EmployeeDataCorrectionStatus.applied => 5,
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

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
