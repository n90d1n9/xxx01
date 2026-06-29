enum EmployeeTalentPerformanceBand {
  exceptional('Exceptional'),
  strong('Strong'),
  solid('Solid'),
  inconsistent('Inconsistent'),
  atRisk('At risk');

  final String label;

  const EmployeeTalentPerformanceBand(this.label);
}

enum EmployeeTalentPotentialBand {
  breakthrough('Breakthrough'),
  high('High'),
  growth('Growth'),
  steady('Steady'),
  limited('Limited');

  final String label;

  const EmployeeTalentPotentialBand(this.label);
}

enum EmployeeTalentRiskLevel {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeTalentRiskLevel(this.label);
}

enum EmployeeTalentCalibrationDecision {
  advance('Advance'),
  invest('Invest'),
  retain('Retain'),
  stabilize('Stabilize'),
  monitor('Monitor');

  final String label;

  const EmployeeTalentCalibrationDecision(this.label);
}

enum EmployeeTalentCalibrationStatus {
  draft('Draft'),
  calibrated('Calibrated'),
  actionDue('Action due'),
  disputed('Disputed'),
  archived('Archived');

  final String label;

  const EmployeeTalentCalibrationStatus(this.label);
}

enum EmployeeTalentFollowUpType {
  compensationReview('Compensation review'),
  developmentPlan('Development plan'),
  retentionCheck('Retention check'),
  managerCoaching('Manager coaching'),
  successionReview('Succession review');

  final String label;

  const EmployeeTalentFollowUpType(this.label);
}

enum EmployeeTalentFollowUpStatus {
  open('Open'),
  inProgress('In progress'),
  completed('Completed'),
  waived('Waived');

  final String label;

  const EmployeeTalentFollowUpStatus(this.label);
}

class EmployeeTalentFollowUp {
  final String id;
  final String employeeId;
  final EmployeeTalentFollowUpType type;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeeTalentFollowUpStatus status;
  final String notes;

  const EmployeeTalentFollowUp({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.notes,
  });

  bool get isComplete {
    return status == EmployeeTalentFollowUpStatus.completed ||
        status == EmployeeTalentFollowUpStatus.waived;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return !isComplete &&
        (isOverdue(asOfDate) || status == EmployeeTalentFollowUpStatus.open);
  }

  EmployeeTalentFollowUp copyWith({
    DateTime? dueDate,
    EmployeeTalentFollowUpStatus? status,
    String? notes,
  }) {
    return EmployeeTalentFollowUp(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      owner: owner,
      dueDate: _dateOnly(dueDate ?? this.dueDate),
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeTalentCalibrationProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String cycle;
  final String role;
  final String calibrator;
  final EmployeeTalentPerformanceBand performanceBand;
  final EmployeeTalentPotentialBand potentialBand;
  final EmployeeTalentRiskLevel riskLevel;
  final EmployeeTalentCalibrationDecision decision;
  final EmployeeTalentCalibrationStatus status;
  final DateTime lastCalibratedDate;
  final DateTime nextReviewDate;
  final List<EmployeeTalentFollowUp> followUps;

  const EmployeeTalentCalibrationProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.cycle,
    required this.role,
    required this.calibrator,
    required this.performanceBand,
    required this.potentialBand,
    required this.riskLevel,
    required this.decision,
    required this.status,
    required this.lastCalibratedDate,
    required this.nextReviewDate,
    required this.followUps,
  });

  EmployeeTalentCalibrationProfile copyWith({
    EmployeeTalentPerformanceBand? performanceBand,
    EmployeeTalentPotentialBand? potentialBand,
    EmployeeTalentRiskLevel? riskLevel,
    EmployeeTalentCalibrationDecision? decision,
    EmployeeTalentCalibrationStatus? status,
    DateTime? lastCalibratedDate,
    DateTime? nextReviewDate,
    List<EmployeeTalentFollowUp>? followUps,
  }) {
    return EmployeeTalentCalibrationProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      cycle: cycle,
      role: role,
      calibrator: calibrator,
      performanceBand: performanceBand ?? this.performanceBand,
      potentialBand: potentialBand ?? this.potentialBand,
      riskLevel: riskLevel ?? this.riskLevel,
      decision: decision ?? this.decision,
      status: status ?? this.status,
      lastCalibratedDate: _dateOnly(
        lastCalibratedDate ?? this.lastCalibratedDate,
      ),
      nextReviewDate: _dateOnly(nextReviewDate ?? this.nextReviewDate),
      followUps: followUps ?? this.followUps,
    );
  }

  List<EmployeeTalentFollowUp> get sortedFollowUps {
    final sorted = [...followUps];
    sorted.sort((a, b) {
      final aAttention = a.needsAttention(asOfDate);
      final bAttention = b.needsAttention(asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;

      final statusCompare = _followUpStatusRank(
        a.status,
      ).compareTo(_followUpStatusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  bool get isHighRisk {
    return riskLevel == EmployeeTalentRiskLevel.critical ||
        riskLevel == EmployeeTalentRiskLevel.high;
  }

  bool get isDisputed => status == EmployeeTalentCalibrationStatus.disputed;

  bool get isActionDue => status == EmployeeTalentCalibrationStatus.actionDue;

  bool get isReviewDue => !nextReviewDate.isAfter(_dateOnly(asOfDate));

  int get openFollowUpCount {
    return followUps.where((item) => !item.isComplete).length;
  }

  int get overdueFollowUpCount {
    return followUps.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return (isDisputed ? 1 : 0) +
        (isActionDue ? 1 : 0) +
        (isReviewDue ? 1 : 0) +
        (isHighRisk ? 1 : 0) +
        followUps.where((item) => item.needsAttention(asOfDate)).length;
  }

  int get talentScore {
    final performance = switch (performanceBand) {
      EmployeeTalentPerformanceBand.exceptional => 5,
      EmployeeTalentPerformanceBand.strong => 4,
      EmployeeTalentPerformanceBand.solid => 3,
      EmployeeTalentPerformanceBand.inconsistent => 2,
      EmployeeTalentPerformanceBand.atRisk => 1,
    };
    final potential = switch (potentialBand) {
      EmployeeTalentPotentialBand.breakthrough => 5,
      EmployeeTalentPotentialBand.high => 4,
      EmployeeTalentPotentialBand.growth => 3,
      EmployeeTalentPotentialBand.steady => 2,
      EmployeeTalentPotentialBand.limited => 1,
    };
    final riskPenalty = switch (riskLevel) {
      EmployeeTalentRiskLevel.critical => 18,
      EmployeeTalentRiskLevel.high => 12,
      EmployeeTalentRiskLevel.medium => 6,
      EmployeeTalentRiskLevel.low => 0,
    };
    return (((performance * 10) + (potential * 10) - riskPenalty).clamp(
      10,
      100,
    )).toInt();
  }

  String get gridPlacement {
    return '${performanceBand.label} / ${potentialBand.label}';
  }

  String get nextAction {
    if (isDisputed) {
      return 'Resolve disputed calibration decision.';
    }
    if (overdueFollowUpCount > 0) {
      return 'Complete $overdueFollowUpCount overdue calibration follow-up${overdueFollowUpCount == 1 ? '' : 's'}.';
    }
    if (isHighRisk) {
      return 'Align retention and manager action for ${riskLevel.label.toLowerCase()} risk.';
    }
    if (isReviewDue) {
      return 'Run ${cycle.toLowerCase()} talent calibration review.';
    }
    if (openFollowUpCount > 0) {
      return 'Track $openFollowUpCount open calibration follow-up${openFollowUpCount == 1 ? '' : 's'}.';
    }
    return 'Talent calibration is current.';
  }
}

class EmployeeTalentFollowUpDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeTalentFollowUpType type;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final String notes;

  const EmployeeTalentFollowUpDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.notes,
  });

  EmployeeTalentFollowUpDraft copyWith({
    EmployeeTalentFollowUpType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    String? notes,
  }) {
    return EmployeeTalentFollowUpDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Follow-up title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (notes.trim().length < 8) {
      errors.add('Notes must be at least 8 characters');
    }
    if (dueDate == null) {
      errors.add('Due date is required');
    } else if (dueDate!.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 4) complete++;
    if (owner.trim().length >= 3) complete++;
    if (notes.trim().length >= 8) complete++;
    if (dueDate != null && !dueDate!.isBefore(asOfDate)) complete++;
    return complete / 4;
  }

  EmployeeTalentFollowUp toFollowUp({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeTalentFollowUp(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      dueDate: _dateOnly(dueDate!),
      status: EmployeeTalentFollowUpStatus.open,
      notes: notes.trim(),
    );
  }
}

int _followUpStatusRank(EmployeeTalentFollowUpStatus status) {
  return switch (status) {
    EmployeeTalentFollowUpStatus.open => 0,
    EmployeeTalentFollowUpStatus.inProgress => 1,
    EmployeeTalentFollowUpStatus.completed => 2,
    EmployeeTalentFollowUpStatus.waived => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
