enum EmployeeLeaveType {
  vacation('Vacation'),
  sick('Sick leave'),
  personal('Personal'),
  unpaid('Unpaid'),
  bereavement('Bereavement');

  final String label;

  const EmployeeLeaveType(this.label);
}

enum EmployeeLeaveRequestStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String label;

  const EmployeeLeaveRequestStatus(this.label);
}

enum EmployeeLeaveRiskType {
  blackoutConflict('Blackout conflict'),
  lowBalance('Low balance'),
  pendingApproval('Pending approval');

  final String label;

  const EmployeeLeaveRiskType(this.label);
}

class EmployeeLeaveBalance {
  final EmployeeLeaveType type;
  final int accruedDays;
  final int usedDays;
  final int pendingDays;
  final int approvedUpcomingDays;

  const EmployeeLeaveBalance({
    required this.type,
    required this.accruedDays,
    required this.usedDays,
    required this.pendingDays,
    required this.approvedUpcomingDays,
  });

  int get remainingDays => accruedDays - usedDays;

  int get availableDays => remainingDays - pendingDays - approvedUpcomingDays;

  double get usageRatio {
    if (accruedDays <= 0) return 0;
    return usedDays / accruedDays;
  }

  bool get isLow => availableDays <= 2;

  EmployeeLeaveBalance reservePending(int days) {
    return copyWith(pendingDays: pendingDays + days);
  }

  EmployeeLeaveBalance releasePending(int days) {
    return copyWith(pendingDays: _clampNonNegative(pendingDays - days));
  }

  EmployeeLeaveBalance approvePending(int days) {
    return copyWith(
      pendingDays: _clampNonNegative(pendingDays - days),
      approvedUpcomingDays: approvedUpcomingDays + days,
    );
  }

  EmployeeLeaveBalance releaseApproved(int days) {
    return copyWith(
      approvedUpcomingDays: _clampNonNegative(approvedUpcomingDays - days),
    );
  }

  EmployeeLeaveBalance copyWith({
    int? accruedDays,
    int? usedDays,
    int? pendingDays,
    int? approvedUpcomingDays,
  }) {
    return EmployeeLeaveBalance(
      type: type,
      accruedDays: accruedDays ?? this.accruedDays,
      usedDays: usedDays ?? this.usedDays,
      pendingDays: pendingDays ?? this.pendingDays,
      approvedUpcomingDays: approvedUpcomingDays ?? this.approvedUpcomingDays,
    );
  }
}

class EmployeeLeaveRequest {
  final String id;
  final String employeeId;
  final EmployeeLeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String coverageOwner;
  final EmployeeLeaveRequestStatus status;
  final DateTime submittedAt;

  const EmployeeLeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.coverageOwner,
    required this.status,
    required this.submittedAt,
  });

  int get durationDays {
    final value = endDate.difference(startDate).inDays + 1;
    return value < 0 ? 0 : value;
  }

  bool get isPending => status == EmployeeLeaveRequestStatus.pending;

  bool get isApproved => status == EmployeeLeaveRequestStatus.approved;

  bool get canApprove => isPending;

  bool get canReject => isPending;

  bool get canCancel => isPending || isApproved;

  bool overlaps(EmployeeLeaveBlackoutPeriod blackout) {
    return !endDate.isBefore(blackout.startDate) &&
        !startDate.isAfter(blackout.endDate);
  }

  EmployeeLeaveRequest copyWith({EmployeeLeaveRequestStatus? status}) {
    return EmployeeLeaveRequest(
      id: id,
      employeeId: employeeId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      coverageOwner: coverageOwner,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

class EmployeeLeaveBlackoutPeriod {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String owner;

  const EmployeeLeaveBlackoutPeriod({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.owner,
  });
}

class EmployeeLeaveRiskSignal {
  final EmployeeLeaveRiskType type;
  final String title;
  final String detail;

  const EmployeeLeaveRiskSignal({
    required this.type,
    required this.title,
    required this.detail,
  });
}

class EmployeeLeaveProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeLeaveBalance> balances;
  final List<EmployeeLeaveRequest> requests;
  final List<EmployeeLeaveBlackoutPeriod> blackouts;

  const EmployeeLeaveProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.balances,
    required this.requests,
    required this.blackouts,
  });

  EmployeeLeaveProfile copyWith({
    List<EmployeeLeaveBalance>? balances,
    List<EmployeeLeaveRequest>? requests,
    List<EmployeeLeaveBlackoutPeriod>? blackouts,
  }) {
    return EmployeeLeaveProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      balances: balances ?? this.balances,
      requests: requests ?? this.requests,
      blackouts: blackouts ?? this.blackouts,
    );
  }

  int get pendingRequestCount {
    return requests.where((request) => request.isPending).length;
  }

  int get approvedUpcomingCount {
    return requests
        .where(
          (request) =>
              request.isApproved && !request.startDate.isBefore(asOfDate),
        )
        .length;
  }

  int get lowBalanceCount {
    return balances.where((balance) => balance.isLow).length;
  }

  int get blackoutConflictCount {
    return requests.where(_hasBlackoutConflict).length;
  }

  int get attentionCount {
    return pendingRequestCount + lowBalanceCount + blackoutConflictCount;
  }

  List<EmployeeLeaveRiskSignal> get risks {
    final items = <EmployeeLeaveRiskSignal>[];

    if (blackoutConflictCount > 0) {
      items.add(
        EmployeeLeaveRiskSignal(
          type: EmployeeLeaveRiskType.blackoutConflict,
          title: 'Blackout conflict',
          detail:
              '$blackoutConflictCount leave request${blackoutConflictCount == 1 ? '' : 's'} overlap blackout coverage.',
        ),
      );
    }
    if (pendingRequestCount > 0) {
      items.add(
        EmployeeLeaveRiskSignal(
          type: EmployeeLeaveRiskType.pendingApproval,
          title: 'Pending approval',
          detail:
              '$pendingRequestCount leave request${pendingRequestCount == 1 ? '' : 's'} need manager review.',
        ),
      );
    }
    if (lowBalanceCount > 0) {
      items.add(
        EmployeeLeaveRiskSignal(
          type: EmployeeLeaveRiskType.lowBalance,
          title: 'Low leave balance',
          detail:
              '$lowBalanceCount leave balance${lowBalanceCount == 1 ? '' : 's'} are at or below 2 available days.',
        ),
      );
    }

    return items;
  }

  String get nextAction {
    if (blackoutConflictCount > 0) {
      return 'Resolve $blackoutConflictCount blackout leave conflict${blackoutConflictCount == 1 ? '' : 's'}.';
    }
    if (pendingRequestCount > 0) {
      return 'Review $pendingRequestCount leave request${pendingRequestCount == 1 ? '' : 's'}.';
    }
    if (lowBalanceCount > 0) {
      return 'Review $lowBalanceCount low leave balance${lowBalanceCount == 1 ? '' : 's'}.';
    }
    return 'Leave plan is current.';
  }

  EmployeeLeaveBalance? balanceFor(EmployeeLeaveType type) {
    for (final balance in balances) {
      if (balance.type == type) return balance;
    }
    return null;
  }

  bool _hasBlackoutConflict(EmployeeLeaveRequest request) {
    if (!request.isPending && !request.isApproved) return false;
    return blackouts.any(request.overlaps);
  }
}

class EmployeeLeaveRequestDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeLeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String coverageOwner;

  const EmployeeLeaveRequestDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.coverageOwner,
  });

  int get durationDays {
    final value = endDate.difference(startDate).inDays + 1;
    return value < 0 ? 0 : value;
  }

  EmployeeLeaveRequestDraft copyWith({
    EmployeeLeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? coverageOwner,
  }) {
    return EmployeeLeaveRequestDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      coverageOwner: coverageOwner ?? this.coverageOwner,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (startDate.isBefore(asOfDate)) {
      errors.add('Start date cannot be before today');
    }
    if (durationDays <= 0) {
      errors.add('End date must be after start date');
    }
    if (reason.trim().length < 12) {
      errors.add('Reason must be at least 12 characters');
    }
    if (coverageOwner.trim().length < 3) {
      errors.add('Coverage owner is required');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          !startDate.isBefore(asOfDate),
          durationDays > 0,
          reason.trim().length >= 12,
          coverageOwner.trim().length >= 3,
        ].where((item) => item).length;
    return completed / 4;
  }

  EmployeeLeaveRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeLeaveRequest(
      id: id,
      employeeId: employeeId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason.trim(),
      coverageOwner: coverageOwner.trim(),
      status: EmployeeLeaveRequestStatus.pending,
      submittedAt: asOfDate,
    );
  }
}

int _clampNonNegative(int value) {
  return value < 0 ? 0 : value;
}
