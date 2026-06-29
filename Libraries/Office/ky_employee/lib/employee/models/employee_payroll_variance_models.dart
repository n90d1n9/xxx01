enum EmployeePayrollVarianceSource {
  overtime('Overtime'),
  reimbursement('Reimbursement'),
  compensationChange('Compensation change'),
  leave('Leave and absence'),
  payrollProfile('Payroll profile'),
  payrollCutoff('Payroll cutoff'),
  manualAdjustment('Manual adjustment');

  final String label;

  const EmployeePayrollVarianceSource(this.label);
}

enum EmployeePayrollVarianceSeverity {
  blocker('Blocker'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeePayrollVarianceSeverity(this.label);
}

enum EmployeePayrollVarianceStatus {
  open('Open'),
  reviewed('Reviewed'),
  approved('Approved'),
  excluded('Excluded');

  final String label;

  const EmployeePayrollVarianceStatus(this.label);
}

class EmployeePayrollVarianceLine {
  final String id;
  final EmployeePayrollVarianceSource source;
  final EmployeePayrollVarianceSeverity severity;
  final EmployeePayrollVarianceStatus status;
  final String title;
  final String detail;
  final String owner;
  final double amount;
  final String currencyCode;
  final bool requiresApproval;
  final bool taxableImpact;

  const EmployeePayrollVarianceLine({
    required this.id,
    required this.source,
    required this.severity,
    required this.status,
    required this.title,
    required this.detail,
    required this.owner,
    required this.amount,
    required this.currencyCode,
    required this.requiresApproval,
    required this.taxableImpact,
  });

  bool get isOpen {
    return status == EmployeePayrollVarianceStatus.open ||
        status == EmployeePayrollVarianceStatus.reviewed;
  }

  bool get isClosed {
    return status == EmployeePayrollVarianceStatus.approved ||
        status == EmployeePayrollVarianceStatus.excluded;
  }

  bool get isHighRisk {
    return severity == EmployeePayrollVarianceSeverity.blocker ||
        severity == EmployeePayrollVarianceSeverity.high;
  }

  bool get needsAttention => isOpen && (requiresApproval || isHighRisk);

  bool get isMonetary => amount != 0;

  double get absoluteAmount => amount.abs();

  EmployeePayrollVarianceLine copyWith({
    EmployeePayrollVarianceStatus? status,
  }) {
    return EmployeePayrollVarianceLine(
      id: id,
      source: source,
      severity: severity,
      status: status ?? this.status,
      title: title,
      detail: detail,
      owner: owner,
      amount: amount,
      currencyCode: currencyCode,
      requiresApproval: requiresApproval,
      taxableImpact: taxableImpact,
    );
  }
}

class EmployeePayrollVarianceProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currencyCode;
  final double baselineGrossPay;
  final List<EmployeePayrollVarianceLine> lines;

  const EmployeePayrollVarianceProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.currencyCode,
    required this.baselineGrossPay,
    required this.lines,
  });

  EmployeePayrollVarianceProfile copyWith({
    List<EmployeePayrollVarianceLine>? lines,
  }) {
    return EmployeePayrollVarianceProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      currencyCode: currencyCode,
      baselineGrossPay: baselineGrossPay,
      lines: lines ?? this.lines,
    );
  }

  List<EmployeePayrollVarianceLine> get sortedLines {
    final sorted = [...lines];
    sorted.sort((a, b) {
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final severityCompare = _severityRank(
        a.severity,
      ).compareTo(_severityRank(b.severity));
      if (severityCompare != 0) return severityCompare;

      return b.absoluteAmount.compareTo(a.absoluteAmount);
    });
    return sorted;
  }

  double get projectedGrossPay {
    return baselineGrossPay +
        lines
            .where(
              (line) => line.status != EmployeePayrollVarianceStatus.excluded,
            )
            .fold<double>(0, (total, line) => total + line.amount);
  }

  double get varianceAmount => projectedGrossPay - baselineGrossPay;

  double get variancePercent {
    if (baselineGrossPay <= 0) return 0;
    return varianceAmount / baselineGrossPay;
  }

  int get monetaryLineCount => lines.where((line) => line.isMonetary).length;

  int get varianceRiskCount {
    return lines.where((line) => line.isOpen && line.isHighRisk).length;
  }

  int get approvalRequiredCount {
    return lines.where((line) => line.isOpen && line.requiresApproval).length;
  }

  int get manualAdjustmentCount {
    return lines
        .where(
          (line) =>
              line.source == EmployeePayrollVarianceSource.manualAdjustment,
        )
        .length;
  }

  int get approvedLineCount {
    return lines
        .where((line) => line.status == EmployeePayrollVarianceStatus.approved)
        .length;
  }

  int get excludedLineCount {
    return lines
        .where((line) => line.status == EmployeePayrollVarianceStatus.excluded)
        .length;
  }

  int get attentionCount => lines.where((line) => line.needsAttention).length;

  bool get isWithinTolerance => variancePercent.abs() <= 0.03;

  String get nextAction {
    if (varianceRiskCount > 0) {
      return 'Review $varianceRiskCount high-risk payroll variance item${varianceRiskCount == 1 ? '' : 's'}.';
    }
    if (approvalRequiredCount > 0) {
      return 'Approve $approvalRequiredCount payroll variance item${approvalRequiredCount == 1 ? '' : 's'}.';
    }
    if (!isWithinTolerance) {
      return 'Review payroll variance outside tolerance.';
    }
    return 'Payroll variance is within tolerance.';
  }
}

class EmployeePayrollVarianceAdjustmentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String currencyCode;
  final String title;
  final double amount;
  final String owner;
  final String reason;
  final bool taxableImpact;

  const EmployeePayrollVarianceAdjustmentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.currencyCode,
    required this.title,
    required this.amount,
    required this.owner,
    required this.reason,
    required this.taxableImpact,
  });

  EmployeePayrollVarianceAdjustmentDraft copyWith({
    String? title,
    double? amount,
    String? owner,
    String? reason,
    bool? taxableImpact,
  }) {
    return EmployeePayrollVarianceAdjustmentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      currencyCode: currencyCode,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      owner: owner ?? this.owner,
      reason: reason ?? this.reason,
      taxableImpact: taxableImpact ?? this.taxableImpact,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Adjustment title must be at least 4 characters');
    }
    if (amount == 0) {
      errors.add('Adjustment amount must not be zero');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (reason.trim().length < 12) {
      errors.add('Adjustment reason must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          title.trim().length >= 4,
          amount != 0,
          owner.trim().length >= 3,
          reason.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 4;
  }

  EmployeePayrollVarianceLine toLine({
    required String id,
    required double baselineGrossPay,
  }) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    final severity =
        amount.abs() >= baselineGrossPay * 0.05
            ? EmployeePayrollVarianceSeverity.high
            : EmployeePayrollVarianceSeverity.medium;

    return EmployeePayrollVarianceLine(
      id: id,
      source: EmployeePayrollVarianceSource.manualAdjustment,
      severity: severity,
      status: EmployeePayrollVarianceStatus.open,
      title: title.trim(),
      detail: reason.trim(),
      owner: owner.trim(),
      amount: amount,
      currencyCode: currencyCode,
      requiresApproval: true,
      taxableImpact: taxableImpact,
    );
  }
}

int _statusRank(EmployeePayrollVarianceStatus status) {
  return switch (status) {
    EmployeePayrollVarianceStatus.open => 0,
    EmployeePayrollVarianceStatus.reviewed => 1,
    EmployeePayrollVarianceStatus.approved => 2,
    EmployeePayrollVarianceStatus.excluded => 3,
  };
}

int _severityRank(EmployeePayrollVarianceSeverity severity) {
  return switch (severity) {
    EmployeePayrollVarianceSeverity.blocker => 0,
    EmployeePayrollVarianceSeverity.high => 1,
    EmployeePayrollVarianceSeverity.medium => 2,
    EmployeePayrollVarianceSeverity.low => 3,
  };
}
