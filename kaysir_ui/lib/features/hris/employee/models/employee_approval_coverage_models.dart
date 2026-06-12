import 'employee_directory_models.dart';

enum EmployeeApprovalCoverageArea {
  timeOff('Time off'),
  expense('Expense'),
  payroll('Payroll'),
  access('Access'),
  documents('Documents'),
  performance('Performance');

  final String label;

  const EmployeeApprovalCoverageArea(this.label);
}

enum EmployeeApprovalCoverageStatus {
  active('Active'),
  pending('Pending'),
  blocked('Blocked'),
  expired('Expired');

  final String label;

  const EmployeeApprovalCoverageStatus(this.label);
}

enum EmployeeApprovalCoverageRisk {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeApprovalCoverageRisk(this.label);
}

class EmployeeApprovalDelegation {
  final String id;
  final String employeeId;
  final EmployeeApprovalCoverageArea area;
  final String primaryApprover;
  final String delegateApprover;
  final DateTime startDate;
  final DateTime endDate;
  final EmployeeApprovalCoverageStatus status;
  final EmployeeApprovalCoverageRisk risk;
  final String reason;

  const EmployeeApprovalDelegation({
    required this.id,
    required this.employeeId,
    required this.area,
    required this.primaryApprover,
    required this.delegateApprover,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.risk,
    required this.reason,
  });

  bool get isActive => status == EmployeeApprovalCoverageStatus.active;

  bool get isPending => status == EmployeeApprovalCoverageStatus.pending;

  bool get isBlocked => status == EmployeeApprovalCoverageStatus.blocked;

  bool get isExpired => status == EmployeeApprovalCoverageStatus.expired;

  bool get needsAttention => isPending || isBlocked || isExpired;

  bool expiresWithin(DateTime asOfDate, int days) {
    if (!isActive) return false;
    final today = _dateOnly(asOfDate);
    final horizon = today.add(Duration(days: days));
    return !endDate.isBefore(today) && !endDate.isAfter(horizon);
  }

  EmployeeApprovalDelegation copyWith({
    EmployeeApprovalCoverageArea? area,
    String? primaryApprover,
    String? delegateApprover,
    DateTime? startDate,
    DateTime? endDate,
    EmployeeApprovalCoverageStatus? status,
    EmployeeApprovalCoverageRisk? risk,
    String? reason,
  }) {
    return EmployeeApprovalDelegation(
      id: id,
      employeeId: employeeId,
      area: area ?? this.area,
      primaryApprover: primaryApprover ?? this.primaryApprover,
      delegateApprover: delegateApprover ?? this.delegateApprover,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      reason: reason ?? this.reason,
    );
  }
}

class EmployeeApprovalCoverageProfile {
  final String employeeId;
  final String employeeName;
  final String manager;
  final DateTime asOfDate;
  final List<EmployeeApprovalDelegation> delegations;

  const EmployeeApprovalCoverageProfile({
    required this.employeeId,
    required this.employeeName,
    required this.manager,
    required this.asOfDate,
    required this.delegations,
  });

  EmployeeApprovalCoverageProfile copyWith({
    List<EmployeeApprovalDelegation>? delegations,
  }) {
    return EmployeeApprovalCoverageProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      manager: manager,
      asOfDate: asOfDate,
      delegations: delegations ?? this.delegations,
    );
  }

  List<EmployeeApprovalDelegation> get sortedDelegations {
    final sorted = [...delegations]..sort((a, b) {
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      return a.endDate.compareTo(b.endDate);
    });
    return sorted;
  }

  int get activeCount => delegations.where((item) => item.isActive).length;

  int get pendingCount => delegations.where((item) => item.isPending).length;

  int get blockedCount => delegations.where((item) => item.isBlocked).length;

  int get expiredCount => delegations.where((item) => item.isExpired).length;

  int get expiringSoonCount {
    return delegations.where((item) => item.expiresWithin(asOfDate, 14)).length;
  }

  int get attentionCount {
    return pendingCount + blockedCount + expiredCount + expiringSoonCount;
  }

  double get coverageRatio {
    if (delegations.isEmpty) return 0;
    return activeCount / delegations.length;
  }

  EmployeeApprovalDelegation? get nextDelegation {
    final active = sortedDelegations.where((item) => item.needsAttention);
    if (active.isNotEmpty) return active.first;
    final expiring = sortedDelegations.where(
      (item) => item.expiresWithin(asOfDate, 14),
    );
    if (expiring.isNotEmpty) return expiring.first;
    if (sortedDelegations.isEmpty) return null;
    return sortedDelegations.first;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked approval delegation${blockedCount == 1 ? '' : 's'}.';
    }
    if (expiredCount > 0) {
      return 'Renew $expiredCount expired approval delegation${expiredCount == 1 ? '' : 's'}.';
    }
    if (pendingCount > 0) {
      return 'Activate $pendingCount pending approval delegation${pendingCount == 1 ? '' : 's'}.';
    }
    if (expiringSoonCount > 0) {
      return 'Review $expiringSoonCount approval delegation${expiringSoonCount == 1 ? '' : 's'} expiring soon.';
    }
    if (delegations.isEmpty) {
      return 'No approval coverage is configured.';
    }
    return 'Approval coverage is active.';
  }
}

class EmployeeApprovalDelegationDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeApprovalCoverageArea area;
  final String primaryApprover;
  final String delegateApprover;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmployeeApprovalCoverageRisk risk;
  final String reason;

  const EmployeeApprovalDelegationDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.area,
    required this.primaryApprover,
    required this.delegateApprover,
    required this.startDate,
    required this.endDate,
    required this.risk,
    required this.reason,
  });

  factory EmployeeApprovalDelegationDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeApprovalDelegationDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      area: EmployeeApprovalCoverageArea.timeOff,
      primaryApprover: member.manager,
      delegateApprover: '',
      startDate: today,
      endDate: today.add(const Duration(days: 30)),
      risk: EmployeeApprovalCoverageRisk.medium,
      reason: '',
    );
  }

  EmployeeApprovalDelegationDraft copyWith({
    EmployeeApprovalCoverageArea? area,
    String? primaryApprover,
    String? delegateApprover,
    DateTime? startDate,
    DateTime? endDate,
    EmployeeApprovalCoverageRisk? risk,
    String? reason,
  }) {
    return EmployeeApprovalDelegationDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      area: area ?? this.area,
      primaryApprover: primaryApprover ?? this.primaryApprover,
      delegateApprover: delegateApprover ?? this.delegateApprover,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      risk: risk ?? this.risk,
      reason: reason ?? this.reason,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (primaryApprover.trim().length < 3) {
      errors.add('Primary approver is required');
    }
    if (delegateApprover.trim().length < 3) {
      errors.add('Delegate approver is required');
    }
    if (primaryApprover.trim().toLowerCase() ==
        delegateApprover.trim().toLowerCase()) {
      errors.add('Delegate must be different from primary approver');
    }
    final start = startDate;
    final end = endDate;
    if (start == null) {
      errors.add('Start date is required');
    }
    if (end == null) {
      errors.add('End date is required');
    }
    if (start != null && start.isBefore(asOfDate)) {
      errors.add('Start date cannot be before today');
    }
    if (start != null && end != null && end.isBefore(start)) {
      errors.add('End date must be after start date');
    }
    if (reason.trim().length < 12) {
      errors.add('Reason must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          primaryApprover.trim().length >= 3,
          delegateApprover.trim().length >= 3 &&
              primaryApprover.trim().toLowerCase() !=
                  delegateApprover.trim().toLowerCase(),
          startDate != null,
          endDate != null,
          reason.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 5;
  }

  EmployeeApprovalDelegation toDelegation({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeApprovalDelegation(
      id: id,
      employeeId: employeeId,
      area: area,
      primaryApprover: primaryApprover.trim(),
      delegateApprover: delegateApprover.trim(),
      startDate: startDate!,
      endDate: endDate!,
      status: EmployeeApprovalCoverageStatus.pending,
      risk: risk,
      reason: reason.trim(),
    );
  }
}

int _statusRank(EmployeeApprovalCoverageStatus status) {
  return switch (status) {
    EmployeeApprovalCoverageStatus.blocked => 0,
    EmployeeApprovalCoverageStatus.expired => 1,
    EmployeeApprovalCoverageStatus.pending => 2,
    EmployeeApprovalCoverageStatus.active => 3,
  };
}

int _riskRank(EmployeeApprovalCoverageRisk risk) {
  return switch (risk) {
    EmployeeApprovalCoverageRisk.high => 0,
    EmployeeApprovalCoverageRisk.medium => 1,
    EmployeeApprovalCoverageRisk.low => 2,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
