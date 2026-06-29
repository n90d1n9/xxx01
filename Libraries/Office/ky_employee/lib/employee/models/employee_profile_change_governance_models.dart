/// Governed employee profile fields that can be changed with an effective date.
enum EmployeeProfileChangeField {
  roleTitle('Role title'),
  department('Department'),
  manager('Manager'),
  employmentStatus('Employment status'),
  payrollGroup('Payroll group'),
  jobLevel('Job level'),
  costCenter('Cost center');

  final String label;

  const EmployeeProfileChangeField(this.label);

  bool get affectsPayroll {
    return switch (this) {
      EmployeeProfileChangeField.employmentStatus ||
      EmployeeProfileChangeField.payrollGroup ||
      EmployeeProfileChangeField.jobLevel ||
      EmployeeProfileChangeField.costCenter => true,
      EmployeeProfileChangeField.roleTitle ||
      EmployeeProfileChangeField.department ||
      EmployeeProfileChangeField.manager => false,
    };
  }

  bool get affectsReporting {
    return switch (this) {
      EmployeeProfileChangeField.department ||
      EmployeeProfileChangeField.manager ||
      EmployeeProfileChangeField.roleTitle => true,
      EmployeeProfileChangeField.employmentStatus ||
      EmployeeProfileChangeField.payrollGroup ||
      EmployeeProfileChangeField.jobLevel ||
      EmployeeProfileChangeField.costCenter => false,
    };
  }
}

/// Workflow status for an effective-dated employee profile change request.
enum EmployeeProfileChangeStatus {
  submitted('Submitted'),
  inReview('In review'),
  approved('Approved'),
  scheduled('Scheduled'),
  applied('Applied'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String label;

  const EmployeeProfileChangeStatus(this.label);
}

/// Immutable request for a governed employee profile change.
class EmployeeProfileChangeRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeProfileChangeField field;
  final String currentValue;
  final String proposedValue;
  final DateTime effectiveDate;
  final String reason;
  final String requester;
  final String reviewer;
  final String approver;
  final DateTime createdAt;
  final EmployeeProfileChangeStatus status;

  const EmployeeProfileChangeRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.field,
    required this.currentValue,
    required this.proposedValue,
    required this.effectiveDate,
    required this.reason,
    required this.requester,
    required this.reviewer,
    required this.approver,
    required this.createdAt,
    required this.status,
  });

  bool get isOpen {
    return status == EmployeeProfileChangeStatus.submitted ||
        status == EmployeeProfileChangeStatus.inReview ||
        status == EmployeeProfileChangeStatus.approved ||
        status == EmployeeProfileChangeStatus.scheduled;
  }

  bool get canStartReview => status == EmployeeProfileChangeStatus.submitted;

  bool get canApprove => status == EmployeeProfileChangeStatus.inReview;

  bool get canSchedule => status == EmployeeProfileChangeStatus.approved;

  bool canApply(DateTime asOfDate) {
    return status == EmployeeProfileChangeStatus.scheduled &&
        !effectiveDate.isAfter(_dateOnly(asOfDate));
  }

  bool get canReject {
    return status == EmployeeProfileChangeStatus.submitted ||
        status == EmployeeProfileChangeStatus.inReview;
  }

  bool get canCancel {
    return status == EmployeeProfileChangeStatus.submitted ||
        status == EmployeeProfileChangeStatus.inReview ||
        status == EmployeeProfileChangeStatus.approved ||
        status == EmployeeProfileChangeStatus.scheduled;
  }

  bool isDueSoon(DateTime asOfDate) {
    final today = _dateOnly(asOfDate);
    return status == EmployeeProfileChangeStatus.scheduled &&
        !effectiveDate.isBefore(today) &&
        !effectiveDate.isAfter(today.add(const Duration(days: 14)));
  }

  String get impactLabel {
    return '${field.label}: $currentValue -> $proposedValue';
  }

  String get riskLabel {
    if (field.affectsPayroll) return 'Payroll impact';
    if (field.affectsReporting) return 'Reporting impact';
    return 'Profile impact';
  }

  EmployeeProfileChangeRequest copyWith({
    EmployeeProfileChangeStatus? status,
    DateTime? effectiveDate,
  }) {
    return EmployeeProfileChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      field: field,
      currentValue: currentValue,
      proposedValue: proposedValue,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      reason: reason,
      requester: requester,
      reviewer: reviewer,
      approver: approver,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

/// Per-employee profile change governance queue and summary.
class EmployeeProfileChangeGovernanceProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeProfileChangeRequest> requests;

  const EmployeeProfileChangeGovernanceProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.requests,
  });

  EmployeeProfileChangeGovernanceProfile copyWith({
    List<EmployeeProfileChangeRequest>? requests,
  }) {
    return EmployeeProfileChangeGovernanceProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      requests: requests ?? this.requests,
    );
  }

  List<EmployeeProfileChangeRequest> get sortedRequests {
    final sorted = [...requests]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      return a.effectiveDate.compareTo(b.effectiveDate);
    });
    return sorted;
  }

  int get openCount => requests.where((request) => request.isOpen).length;

  int get submittedCount {
    return requests
        .where(
          (request) => request.status == EmployeeProfileChangeStatus.submitted,
        )
        .length;
  }

  int get inReviewCount {
    return requests
        .where(
          (request) => request.status == EmployeeProfileChangeStatus.inReview,
        )
        .length;
  }

  int get approvedCount {
    return requests
        .where(
          (request) => request.status == EmployeeProfileChangeStatus.approved,
        )
        .length;
  }

  int get scheduledCount {
    return requests
        .where(
          (request) => request.status == EmployeeProfileChangeStatus.scheduled,
        )
        .length;
  }

  int get dueToApplyCount {
    return requests.where((request) => request.canApply(asOfDate)).length;
  }

  int get payrollImpactCount {
    return requests
        .where((request) => request.isOpen && request.field.affectsPayroll)
        .length;
  }

  int get attentionCount {
    return submittedCount + inReviewCount + approvedCount + dueToApplyCount;
  }

  String get nextAction {
    if (dueToApplyCount > 0) {
      return 'Apply $dueToApplyCount effective profile change${dueToApplyCount == 1 ? '' : 's'}.';
    }
    if (approvedCount > 0) {
      return 'Schedule $approvedCount approved profile change${approvedCount == 1 ? '' : 's'}.';
    }
    if (inReviewCount > 0) {
      return 'Approve or reject $inReviewCount profile change${inReviewCount == 1 ? '' : 's'}.';
    }
    if (submittedCount > 0) {
      return 'Start review for $submittedCount submitted profile change${submittedCount == 1 ? '' : 's'}.';
    }
    if (scheduledCount > 0) {
      return '$scheduledCount profile change${scheduledCount == 1 ? '' : 's'} scheduled.';
    }
    return 'No governed profile changes pending.';
  }
}

/// Draft input state for creating a governed employee profile change.
class EmployeeProfileChangeDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeProfileChangeField field;
  final String currentValue;
  final String proposedValue;
  final DateTime? effectiveDate;
  final String reason;
  final String requester;
  final String reviewer;
  final String approver;

  const EmployeeProfileChangeDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.field,
    required this.currentValue,
    required this.proposedValue,
    required this.effectiveDate,
    required this.reason,
    required this.requester,
    required this.reviewer,
    required this.approver,
  });

  EmployeeProfileChangeDraft copyWith({
    EmployeeProfileChangeField? field,
    String? currentValue,
    String? proposedValue,
    DateTime? effectiveDate,
    String? reason,
    String? requester,
    String? reviewer,
    String? approver,
  }) {
    return EmployeeProfileChangeDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      field: field ?? this.field,
      currentValue: currentValue ?? this.currentValue,
      proposedValue: proposedValue ?? this.proposedValue,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      reason: reason ?? this.reason,
      requester: requester ?? this.requester,
      reviewer: reviewer ?? this.reviewer,
      approver: approver ?? this.approver,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final proposed = proposedValue.trim();
    final current = currentValue.trim();

    if (current.length < 2) {
      errors.add('Current value is required');
    }
    if (proposed.length < 2) {
      errors.add('Proposed value is required');
    }
    if (proposed.toLowerCase() == current.toLowerCase()) {
      errors.add('Proposed value must differ from current value');
    }
    if (effectiveDate == null) {
      errors.add('Effective date is required');
    } else if (effectiveDate!.isBefore(_dateOnly(asOfDate))) {
      errors.add('Effective date cannot be before today');
    }
    if (reason.trim().length < 12) {
      errors.add('Reason must be at least 12 characters');
    }
    if (requester.trim().length < 3) {
      errors.add('Requester is required');
    }
    if (reviewer.trim().length < 3) {
      errors.add('Reviewer is required');
    }
    if (approver.trim().length < 3) {
      errors.add('Approver is required');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          currentValue.trim().length >= 2,
          proposedValue.trim().length >= 2,
          proposedValue.trim().toLowerCase() !=
              currentValue.trim().toLowerCase(),
          effectiveDate != null && !effectiveDate!.isBefore(asOfDate),
          reason.trim().length >= 12,
          requester.trim().length >= 3,
          reviewer.trim().length >= 3,
          approver.trim().length >= 3,
        ].where((item) => item).length;
    return completed / 8;
  }

  EmployeeProfileChangeRequest toRequest({
    required String id,
    required DateTime createdAt,
  }) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeProfileChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      field: field,
      currentValue: currentValue.trim(),
      proposedValue: proposedValue.trim(),
      effectiveDate: effectiveDate!,
      reason: reason.trim(),
      requester: requester.trim(),
      reviewer: reviewer.trim(),
      approver: approver.trim(),
      createdAt: createdAt,
      status: EmployeeProfileChangeStatus.submitted,
    );
  }
}

int _attentionRank(EmployeeProfileChangeRequest request, DateTime asOfDate) {
  if (request.canApply(asOfDate)) return 0;
  if (request.status == EmployeeProfileChangeStatus.inReview) return 1;
  if (request.status == EmployeeProfileChangeStatus.submitted) return 2;
  if (request.status == EmployeeProfileChangeStatus.approved) return 3;
  if (request.isDueSoon(asOfDate)) return 4;
  return 5;
}

int _statusRank(EmployeeProfileChangeStatus status) {
  return switch (status) {
    EmployeeProfileChangeStatus.inReview => 0,
    EmployeeProfileChangeStatus.submitted => 1,
    EmployeeProfileChangeStatus.approved => 2,
    EmployeeProfileChangeStatus.scheduled => 3,
    EmployeeProfileChangeStatus.applied => 4,
    EmployeeProfileChangeStatus.rejected => 5,
    EmployeeProfileChangeStatus.cancelled => 6,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
