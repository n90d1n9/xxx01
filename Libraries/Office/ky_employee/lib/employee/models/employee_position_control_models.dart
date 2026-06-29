enum EmployeePositionStatus {
  filled('Filled'),
  vacant('Vacant'),
  backfillPending('Backfill pending'),
  frozen('Frozen'),
  overAllocated('Over-allocated');

  final String label;

  const EmployeePositionStatus(this.label);
}

enum EmployeePositionBudgetStatus {
  inBudget('In budget'),
  watch('Watch'),
  overBudget('Over budget');

  final String label;

  const EmployeePositionBudgetStatus(this.label);
}

enum EmployeePositionCriticality {
  critical('Critical'),
  high('High'),
  standard('Standard'),
  low('Low');

  final String label;

  const EmployeePositionCriticality(this.label);
}

enum EmployeePositionRequisitionType {
  newHeadcount('New headcount'),
  backfill('Backfill'),
  conversion('Conversion'),
  temporaryCover('Temporary cover');

  final String label;

  const EmployeePositionRequisitionType(this.label);
}

enum EmployeePositionRequisitionStatus {
  draft('Draft'),
  submitted('Submitted'),
  approved('Approved'),
  open('Open'),
  filled('Filled'),
  cancelled('Cancelled');

  final String label;

  const EmployeePositionRequisitionStatus(this.label);
}

class EmployeePositionControlRecord {
  final String id;
  final String employeeId;
  final String positionCode;
  final String title;
  final String department;
  final String costCenter;
  final String grade;
  final String hiringManager;
  final double approvedFte;
  final double filledFte;
  final double budgetedMonthlyCost;
  final double actualMonthlyCost;
  final EmployeePositionStatus status;
  final EmployeePositionBudgetStatus budgetStatus;
  final EmployeePositionCriticality criticality;
  final DateTime? vacancySince;
  final DateTime nextReviewDate;

  const EmployeePositionControlRecord({
    required this.id,
    required this.employeeId,
    required this.positionCode,
    required this.title,
    required this.department,
    required this.costCenter,
    required this.grade,
    required this.hiringManager,
    required this.approvedFte,
    required this.filledFte,
    required this.budgetedMonthlyCost,
    required this.actualMonthlyCost,
    required this.status,
    required this.budgetStatus,
    required this.criticality,
    required this.vacancySince,
    required this.nextReviewDate,
  });

  double get vacantFte => (approvedFte - filledFte).clamp(0, 99).toDouble();

  double get fillRatio {
    if (approvedFte <= 0) return 0;
    return (filledFte / approvedFte).clamp(0, 1).toDouble();
  }

  double get budgetVariance => actualMonthlyCost - budgetedMonthlyCost;

  bool get isVacant => status == EmployeePositionStatus.vacant || vacantFte > 0;

  bool get isFrozen => status == EmployeePositionStatus.frozen;

  bool get isOverBudget {
    return budgetStatus == EmployeePositionBudgetStatus.overBudget ||
        budgetVariance > 0;
  }

  bool isReviewDue(DateTime asOfDate) {
    return !nextReviewDate.isAfter(_dateOnly(asOfDate));
  }

  int vacancyAgeDays(DateTime asOfDate) {
    final vacancyDate = vacancySince;
    if (vacancyDate == null) return 0;
    return _dateOnly(asOfDate).difference(_dateOnly(vacancyDate)).inDays;
  }

  bool needsAttention(DateTime asOfDate) {
    return isOverBudget ||
        isFrozen ||
        isVacant ||
        status == EmployeePositionStatus.backfillPending ||
        status == EmployeePositionStatus.overAllocated ||
        isReviewDue(asOfDate);
  }

  EmployeePositionControlRecord copyWith({
    double? filledFte,
    double? actualMonthlyCost,
    EmployeePositionStatus? status,
    EmployeePositionBudgetStatus? budgetStatus,
    DateTime? vacancySince,
    DateTime? nextReviewDate,
  }) {
    return EmployeePositionControlRecord(
      id: id,
      employeeId: employeeId,
      positionCode: positionCode,
      title: title,
      department: department,
      costCenter: costCenter,
      grade: grade,
      hiringManager: hiringManager,
      approvedFte: approvedFte,
      filledFte: (filledFte ?? this.filledFte).clamp(0, approvedFte).toDouble(),
      budgetedMonthlyCost: budgetedMonthlyCost,
      actualMonthlyCost: actualMonthlyCost ?? this.actualMonthlyCost,
      status: status ?? this.status,
      budgetStatus: budgetStatus ?? this.budgetStatus,
      vacancySince: vacancySince ?? this.vacancySince,
      nextReviewDate: _dateOnly(nextReviewDate ?? this.nextReviewDate),
      criticality: criticality,
    );
  }
}

class EmployeePositionRequisition {
  final String id;
  final String employeeId;
  final EmployeePositionRequisitionType type;
  final String title;
  final String owner;
  final double requestedFte;
  final DateTime targetStartDate;
  final EmployeePositionRequisitionStatus status;
  final String businessCase;

  const EmployeePositionRequisition({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.requestedFte,
    required this.targetStartDate,
    required this.status,
    required this.businessCase,
  });

  bool get isClosed {
    return status == EmployeePositionRequisitionStatus.filled ||
        status == EmployeePositionRequisitionStatus.cancelled;
  }

  bool get canSubmit => status == EmployeePositionRequisitionStatus.draft;

  bool get canApprove {
    return status == EmployeePositionRequisitionStatus.submitted;
  }

  bool get canOpen => status == EmployeePositionRequisitionStatus.approved;

  bool get canFill {
    return status == EmployeePositionRequisitionStatus.open ||
        status == EmployeePositionRequisitionStatus.approved;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isClosed && targetStartDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return !isClosed &&
        (isOverdue(asOfDate) ||
            status == EmployeePositionRequisitionStatus.submitted ||
            status == EmployeePositionRequisitionStatus.approved ||
            status == EmployeePositionRequisitionStatus.open);
  }

  EmployeePositionRequisition copyWith({
    DateTime? targetStartDate,
    EmployeePositionRequisitionStatus? status,
  }) {
    return EmployeePositionRequisition(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      owner: owner,
      requestedFte: requestedFte,
      targetStartDate: _dateOnly(targetStartDate ?? this.targetStartDate),
      status: status ?? this.status,
      businessCase: businessCase,
    );
  }
}

class EmployeePositionControlProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeePositionControlRecord position;
  final List<EmployeePositionRequisition> requisitions;

  const EmployeePositionControlProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.position,
    required this.requisitions,
  });

  EmployeePositionControlProfile copyWith({
    EmployeePositionControlRecord? position,
    List<EmployeePositionRequisition>? requisitions,
  }) {
    return EmployeePositionControlProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      position: position ?? this.position,
      requisitions: requisitions ?? this.requisitions,
    );
  }

  List<EmployeePositionRequisition> get sortedRequisitions {
    final sorted = [...requisitions];
    sorted.sort((a, b) {
      final aAttention = a.needsAttention(asOfDate);
      final bAttention = b.needsAttention(asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.targetStartDate.compareTo(b.targetStartDate);
    });
    return sorted;
  }

  int get openRequisitionCount {
    return requisitions.where((item) => !item.isClosed).length;
  }

  int get overdueRequisitionCount {
    return requisitions.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get pendingApprovalCount {
    return requisitions
        .where(
          (item) =>
              item.status == EmployeePositionRequisitionStatus.submitted ||
              item.status == EmployeePositionRequisitionStatus.approved,
        )
        .length;
  }

  int get attentionCount {
    return (position.needsAttention(asOfDate) ? 1 : 0) +
        requisitions.where((item) => item.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (position.isOverBudget) {
      return 'Resolve position budget variance.';
    }
    if (position.isFrozen) {
      return 'Review frozen position before staffing changes.';
    }
    if (position.isVacant) {
      return 'Close ${position.vacantFte.toStringAsFixed(1)} vacant FTE.';
    }
    if (overdueRequisitionCount > 0) {
      return 'Resolve $overdueRequisitionCount overdue requisition${overdueRequisitionCount == 1 ? '' : 's'}.';
    }
    if (pendingApprovalCount > 0) {
      return 'Approve $pendingApprovalCount position requisition${pendingApprovalCount == 1 ? '' : 's'}.';
    }
    if (position.isReviewDue(asOfDate)) {
      return 'Review position control and budget alignment.';
    }
    return 'Position control is aligned.';
  }
}

class EmployeePositionRequisitionDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeePositionRequisitionType type;
  final String title;
  final String owner;
  final double requestedFte;
  final DateTime? targetStartDate;
  final String businessCase;

  const EmployeePositionRequisitionDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.requestedFte,
    required this.targetStartDate,
    required this.businessCase,
  });

  EmployeePositionRequisitionDraft copyWith({
    EmployeePositionRequisitionType? type,
    String? title,
    String? owner,
    double? requestedFte,
    DateTime? targetStartDate,
    String? businessCase,
  }) {
    return EmployeePositionRequisitionDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      requestedFte:
          (requestedFte ?? this.requestedFte).clamp(0.25, 5).toDouble(),
      targetStartDate: targetStartDate ?? this.targetStartDate,
      businessCase: businessCase ?? this.businessCase,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Requisition title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (businessCase.trim().length < 10) {
      errors.add('Business case must be at least 10 characters');
    }
    if (targetStartDate == null) {
      errors.add('Target start date is required');
    } else if (targetStartDate!.isBefore(asOfDate)) {
      errors.add('Target start date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 4) complete++;
    if (owner.trim().length >= 3) complete++;
    if (businessCase.trim().length >= 10) complete++;
    if (targetStartDate != null && !targetStartDate!.isBefore(asOfDate)) {
      complete++;
    }
    return complete / 4;
  }

  EmployeePositionRequisition toRequisition({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeePositionRequisition(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      requestedFte: requestedFte,
      targetStartDate: _dateOnly(targetStartDate!),
      status: EmployeePositionRequisitionStatus.submitted,
      businessCase: businessCase.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
