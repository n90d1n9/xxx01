enum EmployeePayrollCutoffItemSource {
  payrollProfile('Payroll profile'),
  timekeeping('Timekeeping'),
  leave('Leave and absence'),
  schedule('Pay schedule');

  final String label;

  const EmployeePayrollCutoffItemSource(this.label);
}

enum EmployeePayrollCutoffItemSeverity {
  blocker('Blocker'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeePayrollCutoffItemSeverity(this.label);
}

enum EmployeePayrollCutoffItemStatus {
  open('Open'),
  inReview('In review'),
  resolved('Resolved'),
  waived('Waived');

  final String label;

  const EmployeePayrollCutoffItemStatus(this.label);
}

enum EmployeePayrollCutoffStage {
  collectingInputs('Collecting inputs'),
  resolvingExceptions('Resolving exceptions'),
  managerReview('Manager review'),
  readyForPayroll('Ready for payroll'),
  signedOff('Signed off');

  final String label;

  const EmployeePayrollCutoffStage(this.label);
}

class EmployeePayrollCutoffItem {
  final String id;
  final EmployeePayrollCutoffItemSource source;
  final EmployeePayrollCutoffItemSeverity severity;
  final EmployeePayrollCutoffItemStatus status;
  final String title;
  final String detail;
  final String owner;
  final DateTime dueDate;
  final bool payrollImpact;

  const EmployeePayrollCutoffItem({
    required this.id,
    required this.source,
    required this.severity,
    required this.status,
    required this.title,
    required this.detail,
    required this.owner,
    required this.dueDate,
    required this.payrollImpact,
  });

  bool get isOpen {
    return status == EmployeePayrollCutoffItemStatus.open ||
        status == EmployeePayrollCutoffItemStatus.inReview;
  }

  bool get isClosed {
    return status == EmployeePayrollCutoffItemStatus.resolved ||
        status == EmployeePayrollCutoffItemStatus.waived;
  }

  bool get isBlocking {
    return isOpen &&
        payrollImpact &&
        (severity == EmployeePayrollCutoffItemSeverity.blocker ||
            severity == EmployeePayrollCutoffItemSeverity.high);
  }

  bool get isWarning => isOpen && !isBlocking;

  EmployeePayrollCutoffItem copyWith({
    EmployeePayrollCutoffItemStatus? status,
  }) {
    return EmployeePayrollCutoffItem(
      id: id,
      source: source,
      severity: severity,
      status: status ?? this.status,
      title: title,
      detail: detail,
      owner: owner,
      dueDate: _dateOnly(dueDate),
      payrollImpact: payrollImpact,
    );
  }
}

class EmployeePayrollCutoffSignoff {
  final String id;
  final String employeeId;
  final String reviewer;
  final DateTime reviewedAt;
  final String note;
  final int acceptedWarningCount;

  const EmployeePayrollCutoffSignoff({
    required this.id,
    required this.employeeId,
    required this.reviewer,
    required this.reviewedAt,
    required this.note,
    required this.acceptedWarningCount,
  });
}

class EmployeePayrollCutoffReconciliationProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime cutoffDate;
  final DateTime nextPayDate;
  final String currencyCode;
  final List<EmployeePayrollCutoffItem> items;
  final EmployeePayrollCutoffSignoff? signoff;

  const EmployeePayrollCutoffReconciliationProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.cutoffDate,
    required this.nextPayDate,
    required this.currencyCode,
    required this.items,
    required this.signoff,
  });

  EmployeePayrollCutoffReconciliationProfile copyWith({
    List<EmployeePayrollCutoffItem>? items,
    EmployeePayrollCutoffSignoff? signoff,
  }) {
    return EmployeePayrollCutoffReconciliationProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      cutoffDate: cutoffDate,
      nextPayDate: nextPayDate,
      currencyCode: currencyCode,
      items: items ?? this.items,
      signoff: signoff ?? this.signoff,
    );
  }

  List<EmployeePayrollCutoffItem> get sortedItems {
    final sorted = [...items];
    sorted.sort((a, b) {
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

  int get blockingCount => items.where((item) => item.isBlocking).length;

  int get openWarningCount => items.where((item) => item.isWarning).length;

  int get inReviewCount {
    return items
        .where(
          (item) => item.status == EmployeePayrollCutoffItemStatus.inReview,
        )
        .length;
  }

  int get resolvedCount {
    return items
        .where(
          (item) => item.status == EmployeePayrollCutoffItemStatus.resolved,
        )
        .length;
  }

  int get waivedCount {
    return items
        .where((item) => item.status == EmployeePayrollCutoffItemStatus.waived)
        .length;
  }

  int get attentionCount {
    if (signoff != null) return 0;
    return blockingCount + openWarningCount;
  }

  double get completionRatio {
    if (items.isEmpty) return 1;
    final closedCount = items.where((item) => item.isClosed).length;
    return closedCount / items.length;
  }

  bool get isReadyForApproval => blockingCount == 0;

  bool get canSignOff => signoff == null && isReadyForApproval;

  EmployeePayrollCutoffStage get stage {
    if (signoff != null) return EmployeePayrollCutoffStage.signedOff;
    if (items.isEmpty) return EmployeePayrollCutoffStage.collectingInputs;
    if (blockingCount > 0) {
      return EmployeePayrollCutoffStage.resolvingExceptions;
    }
    if (openWarningCount > 0 || inReviewCount > 0) {
      return EmployeePayrollCutoffStage.managerReview;
    }
    return EmployeePayrollCutoffStage.readyForPayroll;
  }

  String get nextAction {
    if (signoff != null) {
      return 'Payroll cutoff signed off by ${signoff!.reviewer}.';
    }
    if (blockingCount > 0) {
      return 'Resolve $blockingCount payroll cutoff blocker${blockingCount == 1 ? '' : 's'}.';
    }
    if (openWarningCount > 0) {
      return 'Review $openWarningCount payroll cutoff warning${openWarningCount == 1 ? '' : 's'}.';
    }
    if (items.isEmpty) return 'Collect payroll cutoff inputs.';
    return 'Ready for payroll sign-off.';
  }
}

class EmployeePayrollCutoffSignoffDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String reviewer;
  final DateTime reviewDate;
  final String note;
  final bool acceptOpenWarnings;

  const EmployeePayrollCutoffSignoffDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.reviewer,
    required this.reviewDate,
    required this.note,
    required this.acceptOpenWarnings,
  });

  EmployeePayrollCutoffSignoffDraft copyWith({
    String? reviewer,
    DateTime? reviewDate,
    String? note,
    bool? acceptOpenWarnings,
  }) {
    return EmployeePayrollCutoffSignoffDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      reviewer: reviewer ?? this.reviewer,
      reviewDate: _dateOnly(reviewDate ?? this.reviewDate),
      note: note ?? this.note,
      acceptOpenWarnings: acceptOpenWarnings ?? this.acceptOpenWarnings,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (reviewer.trim().length < 3) {
      errors.add('Reviewer is required');
    }
    if (reviewDate.isBefore(asOfDate)) {
      errors.add('Review date cannot be before today');
    }
    if (note.trim().length < 12) {
      errors.add('Sign-off note must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          reviewer.trim().length >= 3,
          !reviewDate.isBefore(asOfDate),
          note.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 3;
  }

  EmployeePayrollCutoffSignoff toSignoff({
    required String id,
    required int acceptedWarningCount,
  }) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeePayrollCutoffSignoff(
      id: id,
      employeeId: employeeId,
      reviewer: reviewer.trim(),
      reviewedAt: _dateOnly(reviewDate),
      note: note.trim(),
      acceptedWarningCount: acceptedWarningCount,
    );
  }
}

int _statusRank(EmployeePayrollCutoffItemStatus status) {
  return switch (status) {
    EmployeePayrollCutoffItemStatus.open => 0,
    EmployeePayrollCutoffItemStatus.inReview => 1,
    EmployeePayrollCutoffItemStatus.resolved => 2,
    EmployeePayrollCutoffItemStatus.waived => 3,
  };
}

int _severityRank(EmployeePayrollCutoffItemSeverity severity) {
  return switch (severity) {
    EmployeePayrollCutoffItemSeverity.blocker => 0,
    EmployeePayrollCutoffItemSeverity.high => 1,
    EmployeePayrollCutoffItemSeverity.medium => 2,
    EmployeePayrollCutoffItemSeverity.low => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
