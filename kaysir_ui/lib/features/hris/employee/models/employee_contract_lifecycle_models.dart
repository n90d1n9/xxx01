enum EmployeeContractType {
  permanent('Permanent'),
  fixedTerm('Fixed term'),
  probation('Probation'),
  internship('Internship'),
  contractor('Contractor');

  final String label;

  const EmployeeContractType(this.label);
}

enum EmployeeContractStatus {
  active('Active'),
  probation('Probation'),
  renewalDue('Renewal due'),
  pendingSignature('Pending signature'),
  expired('Expired'),
  terminated('Terminated');

  final String label;

  const EmployeeContractStatus(this.label);
}

enum EmployeeContractChangeType {
  renewal('Renewal'),
  extension('Extension'),
  conversion('Conversion'),
  compensationClause('Compensation clause'),
  endDateChange('End-date change');

  final String label;

  const EmployeeContractChangeType(this.label);
}

enum EmployeeContractChangeStatus {
  submitted('Submitted'),
  approved('Approved'),
  signed('Signed'),
  activated('Activated'),
  rejected('Rejected');

  final String label;

  const EmployeeContractChangeStatus(this.label);
}

class EmployeeContractRecord {
  final String employeeId;
  final String employeeName;
  final EmployeeContractType type;
  final EmployeeContractStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? probationEndDate;
  final DateTime? renewalDueDate;
  final String owner;
  final int version;
  final DateTime? signedAt;

  const EmployeeContractRecord({
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.probationEndDate,
    required this.renewalDueDate,
    required this.owner,
    required this.version,
    required this.signedAt,
  });

  bool isProbationDue(DateTime asOfDate) {
    final endDate = probationEndDate;
    if (endDate == null || status != EmployeeContractStatus.probation) {
      return false;
    }
    final today = _dateOnly(asOfDate);
    return !endDate.isAfter(today.add(const Duration(days: 14)));
  }

  bool isRenewalDue(DateTime asOfDate) {
    final dueDate = renewalDueDate;
    if (status == EmployeeContractStatus.renewalDue) {
      return true;
    }
    if (dueDate == null ||
        status == EmployeeContractStatus.terminated ||
        status == EmployeeContractStatus.expired) {
      return false;
    }
    final today = _dateOnly(asOfDate);
    return !dueDate.isAfter(today.add(const Duration(days: 30)));
  }

  bool isExpired(DateTime asOfDate) {
    final contractEndDate = endDate;
    if (status == EmployeeContractStatus.expired) {
      return true;
    }
    if (contractEndDate == null ||
        status == EmployeeContractStatus.terminated) {
      return false;
    }
    return contractEndDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeContractStatus.pendingSignature ||
        status == EmployeeContractStatus.renewalDue ||
        isProbationDue(asOfDate) ||
        isRenewalDue(asOfDate) ||
        isExpired(asOfDate);
  }

  EmployeeContractRecord copyWith({
    EmployeeContractType? type,
    EmployeeContractStatus? status,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? probationEndDate,
    bool clearProbationEndDate = false,
    DateTime? renewalDueDate,
    bool clearRenewalDueDate = false,
    int? version,
    DateTime? signedAt,
  }) {
    return EmployeeContractRecord(
      employeeId: employeeId,
      employeeName: employeeName,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      probationEndDate:
          clearProbationEndDate
              ? null
              : probationEndDate ?? this.probationEndDate,
      renewalDueDate:
          clearRenewalDueDate ? null : renewalDueDate ?? this.renewalDueDate,
      owner: owner,
      version: version ?? this.version,
      signedAt: signedAt ?? this.signedAt,
    );
  }
}

class EmployeeContractChangeRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeContractChangeType type;
  final String title;
  final String requestedBy;
  final DateTime effectiveDate;
  final String detail;
  final EmployeeContractChangeStatus status;
  final DateTime submittedAt;

  const EmployeeContractChangeRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.effectiveDate,
    required this.detail,
    required this.status,
    required this.submittedAt,
  });

  bool get canApprove => status == EmployeeContractChangeStatus.submitted;

  bool get canSign => status == EmployeeContractChangeStatus.approved;

  bool get canActivate => status == EmployeeContractChangeStatus.signed;

  bool get canReject => status == EmployeeContractChangeStatus.submitted;

  EmployeeContractChangeRequest copyWith({
    EmployeeContractChangeStatus? status,
  }) {
    return EmployeeContractChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      requestedBy: requestedBy,
      effectiveDate: effectiveDate,
      detail: detail,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

class EmployeeContractLifecycleProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeContractRecord contract;
  final List<EmployeeContractChangeRequest> changes;

  const EmployeeContractLifecycleProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.contract,
    required this.changes,
  });

  EmployeeContractLifecycleProfile copyWith({
    EmployeeContractRecord? contract,
    List<EmployeeContractChangeRequest>? changes,
  }) {
    return EmployeeContractLifecycleProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      contract: contract ?? this.contract,
      changes: changes ?? this.changes,
    );
  }

  int get probationDueCount => contract.isProbationDue(asOfDate) ? 1 : 0;

  int get renewalDueCount => contract.isRenewalDue(asOfDate) ? 1 : 0;

  int get expiredCount => contract.isExpired(asOfDate) ? 1 : 0;

  int get pendingSignatureCount {
    return contract.status == EmployeeContractStatus.pendingSignature ? 1 : 0;
  }

  int get submittedChangeCount {
    return changes
        .where(
          (change) => change.status == EmployeeContractChangeStatus.submitted,
        )
        .length;
  }

  int get approvedChangeCount {
    return changes
        .where(
          (change) => change.status == EmployeeContractChangeStatus.approved,
        )
        .length;
  }

  int get signedChangeCount {
    return changes
        .where((change) => change.status == EmployeeContractChangeStatus.signed)
        .length;
  }

  int get attentionCount {
    return probationDueCount +
        renewalDueCount +
        expiredCount +
        pendingSignatureCount +
        submittedChangeCount +
        approvedChangeCount +
        signedChangeCount;
  }

  String get nextAction {
    if (expiredCount > 0) return 'Resolve expired contract terms.';
    if (probationDueCount > 0) return 'Complete probation decision.';
    if (renewalDueCount > 0) return 'Renew fixed-term contract.';
    if (pendingSignatureCount > 0) return 'Collect contract signature.';
    if (signedChangeCount > 0) {
      return 'Activate $signedChangeCount signed contract change${signedChangeCount == 1 ? '' : 's'}.';
    }
    if (approvedChangeCount > 0) {
      return 'Collect signature for $approvedChangeCount approved contract change${approvedChangeCount == 1 ? '' : 's'}.';
    }
    if (submittedChangeCount > 0) {
      return 'Review $submittedChangeCount submitted contract change${submittedChangeCount == 1 ? '' : 's'}.';
    }
    return 'Contract lifecycle is current.';
  }
}

class EmployeeContractChangeDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeContractChangeType type;
  final String title;
  final String requestedBy;
  final DateTime effectiveDate;
  final String detail;

  const EmployeeContractChangeDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.effectiveDate,
    required this.detail,
  });

  EmployeeContractChangeDraft copyWith({
    EmployeeContractChangeType? type,
    String? title,
    String? requestedBy,
    DateTime? effectiveDate,
    String? detail,
  }) {
    return EmployeeContractChangeDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      requestedBy: requestedBy ?? this.requestedBy,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      detail: detail ?? this.detail,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Title must be at least 4 characters');
    }
    if (requestedBy.trim().length < 3) {
      errors.add('Requester is required');
    }
    if (effectiveDate.isBefore(asOfDate)) {
      errors.add('Effective date cannot be before today');
    }
    if (detail.trim().length < 12) {
      errors.add('Detail must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          requestedBy.trim().length >= 3,
          !effectiveDate.isBefore(asOfDate),
          detail.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 4;
  }

  EmployeeContractChangeRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeContractChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      requestedBy: requestedBy.trim(),
      effectiveDate: effectiveDate,
      detail: detail.trim(),
      status: EmployeeContractChangeStatus.submitted,
      submittedAt: asOfDate,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
