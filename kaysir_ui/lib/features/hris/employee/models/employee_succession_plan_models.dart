import 'employee_directory_models.dart';

enum EmployeeSuccessionCriticality {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeSuccessionCriticality(this.label);
}

enum EmployeeSuccessionReadiness {
  readyNow('Ready now'),
  readySoon('Ready soon'),
  developing('Developing'),
  hold('Hold');

  final String label;

  const EmployeeSuccessionReadiness(this.label);
}

enum EmployeeSuccessionRisk {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeSuccessionRisk(this.label);
}

enum EmployeeSuccessionActionType {
  talentReview('Talent review'),
  developmentPlan('Development plan'),
  retentionCheck('Retention check'),
  knowledgeTransfer('Knowledge transfer'),
  compensationReview('Compensation review');

  final String label;

  const EmployeeSuccessionActionType(this.label);
}

enum EmployeeSuccessionCoverageStatus {
  covered('Covered'),
  atRisk('At risk'),
  gap('Gap'),
  building('Building');

  final String label;

  const EmployeeSuccessionCoverageStatus(this.label);
}

class EmployeeSuccessionCandidate {
  final String id;
  final String employeeId;
  final String name;
  final String currentRole;
  final String targetRole;
  final EmployeeSuccessionReadiness readiness;
  final EmployeeSuccessionRisk risk;
  final EmployeeSuccessionActionType actionType;
  final String owner;
  final DateTime reviewDate;
  final int benchScore;
  final String notes;

  const EmployeeSuccessionCandidate({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.currentRole,
    required this.targetRole,
    required this.readiness,
    required this.risk,
    required this.actionType,
    required this.owner,
    required this.reviewDate,
    required this.benchScore,
    required this.notes,
  });

  bool get isReadyNow => readiness == EmployeeSuccessionReadiness.readyNow;

  bool get isReadySoon => readiness == EmployeeSuccessionReadiness.readySoon;

  bool get isDeveloping => readiness == EmployeeSuccessionReadiness.developing;

  bool get isOnHold => readiness == EmployeeSuccessionReadiness.hold;

  bool get isHighRisk {
    return risk == EmployeeSuccessionRisk.critical ||
        risk == EmployeeSuccessionRisk.high;
  }

  bool isOverdue(DateTime asOfDate) {
    return reviewDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return isHighRisk || isOnHold || isDeveloping || isOverdue(asOfDate);
  }

  EmployeeSuccessionCandidate copyWith({
    EmployeeSuccessionReadiness? readiness,
    EmployeeSuccessionRisk? risk,
    EmployeeSuccessionActionType? actionType,
    String? owner,
    DateTime? reviewDate,
    int? benchScore,
    String? notes,
  }) {
    return EmployeeSuccessionCandidate(
      id: id,
      employeeId: employeeId,
      name: name,
      currentRole: currentRole,
      targetRole: targetRole,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      actionType: actionType ?? this.actionType,
      owner: owner ?? this.owner,
      reviewDate: reviewDate ?? this.reviewDate,
      benchScore: benchScore ?? this.benchScore,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeSuccessionProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String incumbentRole;
  final String department;
  final String manager;
  final EmployeeSuccessionCriticality criticality;
  final String coverageOwner;
  final DateTime reviewDate;
  final List<EmployeeSuccessionCandidate> candidates;

  const EmployeeSuccessionProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.incumbentRole,
    required this.department,
    required this.manager,
    required this.criticality,
    required this.coverageOwner,
    required this.reviewDate,
    required this.candidates,
  });

  EmployeeSuccessionProfile copyWith({
    EmployeeSuccessionCriticality? criticality,
    String? coverageOwner,
    DateTime? reviewDate,
    List<EmployeeSuccessionCandidate>? candidates,
  }) {
    return EmployeeSuccessionProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      incumbentRole: incumbentRole,
      department: department,
      manager: manager,
      criticality: criticality ?? this.criticality,
      coverageOwner: coverageOwner ?? this.coverageOwner,
      reviewDate: reviewDate ?? this.reviewDate,
      candidates: candidates ?? this.candidates,
    );
  }

  List<EmployeeSuccessionCandidate> get sortedCandidates {
    final sorted = [...candidates]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      final readinessCompare = _readinessRank(
        a.readiness,
      ).compareTo(_readinessRank(b.readiness));
      if (readinessCompare != 0) return readinessCompare;

      return a.reviewDate.compareTo(b.reviewDate);
    });
    return sorted;
  }

  bool get isCriticalRole {
    return criticality == EmployeeSuccessionCriticality.critical ||
        criticality == EmployeeSuccessionCriticality.high;
  }

  bool get isReviewDue => !reviewDate.isAfter(_dateOnly(asOfDate));

  int get readyNowCount {
    return candidates.where((candidate) => candidate.isReadyNow).length;
  }

  int get readySoonCount {
    return candidates.where((candidate) => candidate.isReadySoon).length;
  }

  int get developingCount {
    return candidates.where((candidate) => candidate.isDeveloping).length;
  }

  int get holdCount {
    return candidates.where((candidate) => candidate.isOnHold).length;
  }

  int get overdueCount {
    return candidates
        .where((candidate) => candidate.isOverdue(asOfDate))
        .length;
  }

  int get highRiskCount {
    return candidates.where((candidate) => candidate.isHighRisk).length;
  }

  int get coverageGapCount => isCriticalRole && readyNowCount == 0 ? 1 : 0;

  int get attentionCount {
    return coverageGapCount +
        (isReviewDue ? 1 : 0) +
        candidates
            .where((candidate) => candidate.needsAttention(asOfDate))
            .length;
  }

  double get benchStrength {
    if (candidates.isEmpty) return 0;
    final weighted = candidates.fold<double>(0, (total, candidate) {
      final readinessWeight = switch (candidate.readiness) {
        EmployeeSuccessionReadiness.readyNow => 1,
        EmployeeSuccessionReadiness.readySoon => 0.76,
        EmployeeSuccessionReadiness.developing => 0.42,
        EmployeeSuccessionReadiness.hold => 0.12,
      };
      return total + ((candidate.benchScore / 100) * readinessWeight);
    });
    return (weighted / candidates.length).clamp(0, 1);
  }

  EmployeeSuccessionCoverageStatus get coverageStatus {
    if (candidates.isEmpty || coverageGapCount > 0) {
      return EmployeeSuccessionCoverageStatus.gap;
    }
    if (highRiskCount > 0 || overdueCount > 0 || isReviewDue) {
      return EmployeeSuccessionCoverageStatus.atRisk;
    }
    if (readyNowCount > 0) {
      return EmployeeSuccessionCoverageStatus.covered;
    }
    return EmployeeSuccessionCoverageStatus.building;
  }

  EmployeeSuccessionCandidate? get nextCandidate {
    if (sortedCandidates.isEmpty) return null;
    return sortedCandidates.first;
  }

  String get nextAction {
    if (candidates.isEmpty) {
      return 'Nominate successor candidates for $incumbentRole.';
    }
    if (coverageGapCount > 0) {
      return 'Nominate a ready-now successor for $incumbentRole.';
    }
    if (overdueCount > 0) {
      return 'Review $overdueCount overdue successor candidate${overdueCount == 1 ? '' : 's'}.';
    }
    if (highRiskCount > 0) {
      return 'Reduce $highRiskCount high-risk successor plan${highRiskCount == 1 ? '' : 's'}.';
    }
    if (isReviewDue) {
      return 'Run succession coverage review for $incumbentRole.';
    }
    return 'Succession coverage is healthy for $incumbentRole.';
  }
}

class EmployeeSuccessionCandidateDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String name;
  final String currentRole;
  final String targetRole;
  final EmployeeSuccessionReadiness readiness;
  final EmployeeSuccessionRisk risk;
  final EmployeeSuccessionActionType actionType;
  final String owner;
  final DateTime? reviewDate;
  final int benchScore;
  final String notes;

  const EmployeeSuccessionCandidateDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.name,
    required this.currentRole,
    required this.targetRole,
    required this.readiness,
    required this.risk,
    required this.actionType,
    required this.owner,
    required this.reviewDate,
    required this.benchScore,
    required this.notes,
  });

  factory EmployeeSuccessionCandidateDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeSuccessionCandidateDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      name: '',
      currentRole: '',
      targetRole: member.position,
      readiness: EmployeeSuccessionReadiness.readySoon,
      risk: EmployeeSuccessionRisk.medium,
      actionType: EmployeeSuccessionActionType.developmentPlan,
      owner: member.manager,
      reviewDate: today.add(const Duration(days: 30)),
      benchScore: 60,
      notes: '',
    );
  }

  EmployeeSuccessionCandidateDraft copyWith({
    String? name,
    String? currentRole,
    String? targetRole,
    EmployeeSuccessionReadiness? readiness,
    EmployeeSuccessionRisk? risk,
    EmployeeSuccessionActionType? actionType,
    String? owner,
    DateTime? reviewDate,
    int? benchScore,
    String? notes,
  }) {
    return EmployeeSuccessionCandidateDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      name: name ?? this.name,
      currentRole: currentRole ?? this.currentRole,
      targetRole: targetRole ?? this.targetRole,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      actionType: actionType ?? this.actionType,
      owner: owner ?? this.owner,
      reviewDate: reviewDate ?? this.reviewDate,
      benchScore: benchScore ?? this.benchScore,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().length < 3) {
      errors.add('Candidate name must be at least 3 characters');
    }
    if (currentRole.trim().length < 4) {
      errors.add('Current role must be at least 4 characters');
    }
    if (targetRole.trim().length < 4) {
      errors.add('Target role must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Coverage owner is required');
    }
    final review = reviewDate;
    if (review == null) {
      errors.add('Review date is required');
    } else if (review.isBefore(asOfDate)) {
      errors.add('Review date cannot be before today');
    }
    if (benchScore < 0 || benchScore > 100) {
      errors.add('Bench score must be between 0 and 100');
    }
    if (notes.trim().length < 10) {
      errors.add('Notes must be at least 10 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (name.trim().length >= 3) completed++;
    if (currentRole.trim().length >= 4) completed++;
    if (targetRole.trim().length >= 4) completed++;
    if (owner.trim().length >= 3) completed++;
    final review = reviewDate;
    if (review != null && !review.isBefore(asOfDate)) completed++;
    if (notes.trim().length >= 10) completed++;
    return completed / 6;
  }

  EmployeeSuccessionCandidate toCandidate({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeSuccessionCandidate(
      id: id,
      employeeId: employeeId,
      name: name.trim(),
      currentRole: currentRole.trim(),
      targetRole: targetRole.trim(),
      readiness: readiness,
      risk: risk,
      actionType: actionType,
      owner: owner.trim(),
      reviewDate: _dateOnly(reviewDate!),
      benchScore: benchScore,
      notes: notes.trim(),
    );
  }
}

int _attentionRank(EmployeeSuccessionCandidate candidate, DateTime asOfDate) {
  if (candidate.isOverdue(asOfDate)) return 0;
  if (candidate.isHighRisk) return 1;
  if (candidate.isOnHold) return 2;
  if (candidate.isDeveloping) return 3;
  return 4;
}

int _readinessRank(EmployeeSuccessionReadiness readiness) {
  return switch (readiness) {
    EmployeeSuccessionReadiness.readyNow => 0,
    EmployeeSuccessionReadiness.readySoon => 1,
    EmployeeSuccessionReadiness.developing => 2,
    EmployeeSuccessionReadiness.hold => 3,
  };
}

int _riskRank(EmployeeSuccessionRisk risk) {
  return switch (risk) {
    EmployeeSuccessionRisk.critical => 0,
    EmployeeSuccessionRisk.high => 1,
    EmployeeSuccessionRisk.medium => 2,
    EmployeeSuccessionRisk.low => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
