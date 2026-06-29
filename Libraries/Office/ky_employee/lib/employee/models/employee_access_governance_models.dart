enum EmployeeAccessGovernanceScope {
  productivity('Productivity'),
  engineering('Engineering'),
  finance('Finance'),
  hris('HRIS'),
  admin('Admin');

  final String label;

  const EmployeeAccessGovernanceScope(this.label);
}

enum EmployeeAccessGovernanceRisk {
  standard('Standard'),
  staleAccess('Stale access'),
  privilegedAccess('Privileged access'),
  separationOfDuties('Separation of duties'),
  externalAccess('External access'),
  orphanedAccount('Orphaned account');

  final String label;

  const EmployeeAccessGovernanceRisk(this.label);
}

enum EmployeeAccessGovernanceStatus {
  dueReview('Due review'),
  approved('Approved'),
  revokeRequested('Revoke requested'),
  revoked('Revoked'),
  exception('Exception');

  final String label;

  const EmployeeAccessGovernanceStatus(this.label);
}

class EmployeeAccessGovernanceReview {
  final String id;
  final String employeeId;
  final String employeeName;
  final String systemName;
  final String roleName;
  final EmployeeAccessGovernanceScope scope;
  final EmployeeAccessGovernanceRisk risk;
  final String owner;
  final String reviewer;
  final DateTime grantedAt;
  final DateTime dueDate;
  final DateTime? reviewedAt;
  final String businessJustification;
  final EmployeeAccessGovernanceStatus status;

  const EmployeeAccessGovernanceReview({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.systemName,
    required this.roleName,
    required this.scope,
    required this.risk,
    required this.owner,
    required this.reviewer,
    required this.grantedAt,
    required this.dueDate,
    required this.reviewedAt,
    required this.businessJustification,
    required this.status,
  });

  bool get canApprove {
    return status == EmployeeAccessGovernanceStatus.dueReview ||
        status == EmployeeAccessGovernanceStatus.exception;
  }

  bool get canRequestRevoke {
    return status == EmployeeAccessGovernanceStatus.dueReview ||
        status == EmployeeAccessGovernanceStatus.exception;
  }

  bool get canCompleteRevoke {
    return status == EmployeeAccessGovernanceStatus.revokeRequested;
  }

  bool get canMarkException {
    return status == EmployeeAccessGovernanceStatus.dueReview;
  }

  bool get isPrivileged {
    return risk == EmployeeAccessGovernanceRisk.privilegedAccess ||
        scope == EmployeeAccessGovernanceScope.admin;
  }

  bool isOverdue(DateTime asOfDate) {
    if (status == EmployeeAccessGovernanceStatus.approved ||
        status == EmployeeAccessGovernanceStatus.revoked) {
      return false;
    }
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return dueDate.isBefore(today);
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeAccessGovernanceStatus.dueReview ||
        status == EmployeeAccessGovernanceStatus.revokeRequested ||
        status == EmployeeAccessGovernanceStatus.exception ||
        isOverdue(asOfDate);
  }

  EmployeeAccessGovernanceReview copyWith({
    EmployeeAccessGovernanceStatus? status,
    DateTime? reviewedAt,
  }) {
    return EmployeeAccessGovernanceReview(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      systemName: systemName,
      roleName: roleName,
      scope: scope,
      risk: risk,
      owner: owner,
      reviewer: reviewer,
      grantedAt: grantedAt,
      dueDate: dueDate,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      businessJustification: businessJustification,
      status: status ?? this.status,
    );
  }
}

class EmployeeAccessGovernanceProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeAccessGovernanceReview> reviews;

  const EmployeeAccessGovernanceProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.reviews,
  });

  EmployeeAccessGovernanceProfile copyWith({
    List<EmployeeAccessGovernanceReview>? reviews,
  }) {
    return EmployeeAccessGovernanceProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      reviews: reviews ?? this.reviews,
    );
  }

  int get dueReviewCount {
    return reviews
        .where(
          (review) => review.status == EmployeeAccessGovernanceStatus.dueReview,
        )
        .length;
  }

  int get revokeRequestedCount {
    return reviews
        .where(
          (review) =>
              review.status == EmployeeAccessGovernanceStatus.revokeRequested,
        )
        .length;
  }

  int get exceptionCount {
    return reviews
        .where(
          (review) => review.status == EmployeeAccessGovernanceStatus.exception,
        )
        .length;
  }

  int get privilegedCount {
    return reviews
        .where(
          (review) =>
              review.isPrivileged &&
              review.status != EmployeeAccessGovernanceStatus.revoked,
        )
        .length;
  }

  int get overdueCount {
    return reviews.where((review) => review.isOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return reviews.where((review) => review.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (revokeRequestedCount > 0) {
      return 'Complete $revokeRequestedCount access revoke request${revokeRequestedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue access review${overdueCount == 1 ? '' : 's'}.';
    }
    if (exceptionCount > 0) {
      return 'Review $exceptionCount access exception${exceptionCount == 1 ? '' : 's'}.';
    }
    if (dueReviewCount > 0) {
      return 'Review $dueReviewCount access grant${dueReviewCount == 1 ? '' : 's'}.';
    }
    return 'Access governance is current.';
  }
}

class EmployeeAccessGovernanceDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String systemName;
  final String roleName;
  final EmployeeAccessGovernanceScope scope;
  final EmployeeAccessGovernanceRisk risk;
  final String owner;
  final String reviewer;
  final DateTime dueDate;
  final String businessJustification;

  const EmployeeAccessGovernanceDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.systemName,
    required this.roleName,
    required this.scope,
    required this.risk,
    required this.owner,
    required this.reviewer,
    required this.dueDate,
    required this.businessJustification,
  });

  EmployeeAccessGovernanceDraft copyWith({
    String? systemName,
    String? roleName,
    EmployeeAccessGovernanceScope? scope,
    EmployeeAccessGovernanceRisk? risk,
    String? owner,
    String? reviewer,
    DateTime? dueDate,
    String? businessJustification,
  }) {
    return EmployeeAccessGovernanceDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      systemName: systemName ?? this.systemName,
      roleName: roleName ?? this.roleName,
      scope: scope ?? this.scope,
      risk: risk ?? this.risk,
      owner: owner ?? this.owner,
      reviewer: reviewer ?? this.reviewer,
      dueDate: dueDate ?? this.dueDate,
      businessJustification:
          businessJustification ?? this.businessJustification,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (systemName.trim().length < 3) {
      errors.add('System name must be at least 3 characters');
    }
    if (roleName.trim().length < 3) {
      errors.add('Role name must be at least 3 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (reviewer.trim().length < 3) {
      errors.add('Reviewer is required');
    }
    if (dueDate.isBefore(asOfDate)) {
      errors.add('Review due date cannot be before today');
    }
    if (businessJustification.trim().length < 12) {
      errors.add('Business justification must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          systemName.trim().length >= 3,
          roleName.trim().length >= 3,
          owner.trim().length >= 3,
          reviewer.trim().length >= 3,
          !dueDate.isBefore(asOfDate),
          businessJustification.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 6;
  }

  EmployeeAccessGovernanceReview toReview({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeAccessGovernanceReview(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      systemName: systemName.trim(),
      roleName: roleName.trim(),
      scope: scope,
      risk: risk,
      owner: owner.trim(),
      reviewer: reviewer.trim(),
      grantedAt: asOfDate,
      dueDate: dueDate,
      reviewedAt: null,
      businessJustification: businessJustification.trim(),
      status: EmployeeAccessGovernanceStatus.dueReview,
    );
  }
}
