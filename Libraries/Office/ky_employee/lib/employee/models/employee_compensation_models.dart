enum EmployeeCompensationReviewType {
  meritIncrease('Merit increase'),
  marketAdjustment('Market adjustment'),
  retention('Retention'),
  correction('Correction');

  final String label;

  const EmployeeCompensationReviewType(this.label);
}

enum EmployeeCompensationReviewStatus {
  submitted('Submitted'),
  approved('Approved'),
  applied('Applied');

  final String label;

  const EmployeeCompensationReviewStatus(this.label);
}

class EmployeeCompensationPackage {
  final String employeeId;
  final String employeeName;
  final String currencyCode;
  final double baseSalary;
  final double bandMin;
  final double bandMid;
  final double bandMax;
  final String payCycle;
  final DateTime lastReviewDate;
  final DateTime nextReviewDate;

  const EmployeeCompensationPackage({
    required this.employeeId,
    required this.employeeName,
    required this.currencyCode,
    required this.baseSalary,
    required this.bandMin,
    required this.bandMid,
    required this.bandMax,
    required this.payCycle,
    required this.lastReviewDate,
    required this.nextReviewDate,
  });

  double get compaRatio {
    if (bandMid <= 0) return 0;
    return baseSalary / bandMid;
  }

  double get bandPosition {
    final range = bandMax - bandMin;
    if (range <= 0) return 0;
    return ((baseSalary - bandMin) / range).clamp(0, 1).toDouble();
  }

  bool isReviewDue(DateTime asOfDate) {
    return !nextReviewDate.isAfter(_dateOnly(asOfDate));
  }

  bool isReviewDueSoon(DateTime asOfDate) {
    final normalizedAsOf = _dateOnly(asOfDate);
    return nextReviewDate.isAfter(normalizedAsOf) &&
        !nextReviewDate.isAfter(normalizedAsOf.add(const Duration(days: 45)));
  }

  EmployeeCompensationPackage copyWith({
    double? baseSalary,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
  }) {
    return EmployeeCompensationPackage(
      employeeId: employeeId,
      employeeName: employeeName,
      currencyCode: currencyCode,
      baseSalary: baseSalary ?? this.baseSalary,
      bandMin: bandMin,
      bandMid: bandMid,
      bandMax: bandMax,
      payCycle: payCycle,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}

class EmployeeCompensationImpact {
  final double currentBaseSalary;
  final double proposedBaseSalary;
  final double bandMid;

  const EmployeeCompensationImpact({
    required this.currentBaseSalary,
    required this.proposedBaseSalary,
    required this.bandMid,
  });

  double get increaseAmount => proposedBaseSalary - currentBaseSalary;

  double get increasePercent {
    if (currentBaseSalary <= 0) return 0;
    return increaseAmount / currentBaseSalary;
  }

  double get proposedCompaRatio {
    if (bandMid <= 0) return 0;
    return proposedBaseSalary / bandMid;
  }

  bool get hasIncrease => increaseAmount > 0;
}

class EmployeeCompensationReviewDraft {
  final EmployeeCompensationPackage package;
  final DateTime asOfDate;
  final EmployeeCompensationReviewType reviewType;
  final double proposedBaseSalary;
  final DateTime? effectiveDate;
  final String justification;

  const EmployeeCompensationReviewDraft({
    required this.package,
    required this.asOfDate,
    required this.reviewType,
    required this.proposedBaseSalary,
    required this.effectiveDate,
    required this.justification,
  });

  factory EmployeeCompensationReviewDraft.fromPackage({
    required EmployeeCompensationPackage package,
    required DateTime asOfDate,
  }) {
    return EmployeeCompensationReviewDraft(
      package: package,
      asOfDate: _dateOnly(asOfDate),
      reviewType: EmployeeCompensationReviewType.meritIncrease,
      proposedBaseSalary: _defaultProposedSalary(package),
      effectiveDate: _dateOnly(asOfDate).add(const Duration(days: 30)),
      justification: '',
    );
  }

  EmployeeCompensationReviewDraft copyWith({
    EmployeeCompensationReviewType? reviewType,
    double? proposedBaseSalary,
    DateTime? effectiveDate,
    String? justification,
  }) {
    return EmployeeCompensationReviewDraft(
      package: package,
      asOfDate: asOfDate,
      reviewType: reviewType ?? this.reviewType,
      proposedBaseSalary: proposedBaseSalary ?? this.proposedBaseSalary,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      justification: justification ?? this.justification,
    );
  }

  EmployeeCompensationImpact get impact {
    return EmployeeCompensationImpact(
      currentBaseSalary: package.baseSalary,
      proposedBaseSalary: proposedBaseSalary,
      bandMid: package.bandMid,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (proposedBaseSalary <= package.baseSalary) {
      errors.add('Proposed salary must be above current salary');
    }
    if (proposedBaseSalary > package.bandMax * 1.15) {
      errors.add('Proposed salary exceeds review guardrail');
    }
    if (effectiveDate == null) {
      errors.add('Effective date is required');
    } else if (effectiveDate!.isBefore(asOfDate)) {
      errors.add('Effective date cannot be before today');
    }
    if (justification.trim().length < 12) {
      errors.add('Justification must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (proposedBaseSalary > package.baseSalary) completed++;
    if (proposedBaseSalary <= package.bandMax * 1.15) completed++;
    if (effectiveDate != null && !effectiveDate!.isBefore(asOfDate)) {
      completed++;
    }
    if (justification.trim().length >= 12) completed++;
    return completed / 4;
  }

  EmployeeCompensationReviewRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeCompensationReviewRequest(
      id: id,
      employeeId: package.employeeId,
      employeeName: package.employeeName,
      currencyCode: package.currencyCode,
      reviewType: reviewType,
      currentBaseSalary: package.baseSalary,
      proposedBaseSalary: proposedBaseSalary,
      bandMid: package.bandMid,
      effectiveDate: effectiveDate!,
      justification: justification.trim(),
      status: EmployeeCompensationReviewStatus.submitted,
    );
  }
}

class EmployeeCompensationReviewRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String currencyCode;
  final EmployeeCompensationReviewType reviewType;
  final double currentBaseSalary;
  final double proposedBaseSalary;
  final double bandMid;
  final DateTime effectiveDate;
  final String justification;
  final EmployeeCompensationReviewStatus status;

  const EmployeeCompensationReviewRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.currencyCode,
    required this.reviewType,
    required this.currentBaseSalary,
    required this.proposedBaseSalary,
    required this.bandMid,
    required this.effectiveDate,
    required this.justification,
    required this.status,
  });

  EmployeeCompensationImpact get impact {
    return EmployeeCompensationImpact(
      currentBaseSalary: currentBaseSalary,
      proposedBaseSalary: proposedBaseSalary,
      bandMid: bandMid,
    );
  }

  bool get canApprove => status == EmployeeCompensationReviewStatus.submitted;

  bool get canApply => status == EmployeeCompensationReviewStatus.approved;

  EmployeeCompensationReviewRequest copyWith({
    EmployeeCompensationReviewStatus? status,
  }) {
    return EmployeeCompensationReviewRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      currencyCode: currencyCode,
      reviewType: reviewType,
      currentBaseSalary: currentBaseSalary,
      proposedBaseSalary: proposedBaseSalary,
      bandMid: bandMid,
      effectiveDate: effectiveDate,
      justification: justification,
      status: status ?? this.status,
    );
  }

  EmployeeCompensationPackage applyTo(EmployeeCompensationPackage package) {
    return package.copyWith(
      baseSalary: proposedBaseSalary,
      lastReviewDate: effectiveDate,
      nextReviewDate: DateTime(
        effectiveDate.year + 1,
        effectiveDate.month,
        effectiveDate.day,
      ),
    );
  }
}

class EmployeeCompensationReviewSummary {
  final int submittedCount;
  final int approvedCount;
  final int appliedCount;
  final double pendingAnnualBudget;

  const EmployeeCompensationReviewSummary({
    required this.submittedCount,
    required this.approvedCount,
    required this.appliedCount,
    required this.pendingAnnualBudget,
  });

  factory EmployeeCompensationReviewSummary.fromRequests(
    List<EmployeeCompensationReviewRequest> requests,
  ) {
    return EmployeeCompensationReviewSummary(
      submittedCount:
          requests
              .where(
                (request) =>
                    request.status ==
                    EmployeeCompensationReviewStatus.submitted,
              )
              .length,
      approvedCount:
          requests
              .where(
                (request) =>
                    request.status == EmployeeCompensationReviewStatus.approved,
              )
              .length,
      appliedCount:
          requests
              .where(
                (request) =>
                    request.status == EmployeeCompensationReviewStatus.applied,
              )
              .length,
      pendingAnnualBudget: requests
          .where(
            (request) =>
                request.status != EmployeeCompensationReviewStatus.applied,
          )
          .fold<double>(
            0,
            (total, request) => total + request.impact.increaseAmount,
          ),
    );
  }

  String get nextAction {
    if (approvedCount > 0) {
      return 'Apply $approvedCount approved compensation review${approvedCount == 1 ? '' : 's'}.';
    }
    if (submittedCount > 0) {
      return 'Review $submittedCount submitted compensation change${submittedCount == 1 ? '' : 's'}.';
    }
    return 'No compensation reviews are waiting.';
  }
}

double _defaultProposedSalary(EmployeeCompensationPackage package) {
  final suggested = package.baseSalary * 1.05;
  if (suggested <= package.bandMax) return suggested.roundToDouble();
  return package.bandMax.roundToDouble();
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
