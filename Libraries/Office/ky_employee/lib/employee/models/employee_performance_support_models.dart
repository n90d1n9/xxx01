import 'employee_directory_models.dart';

enum EmployeePerformanceSupportStatus {
  draft('Draft'),
  active('Active'),
  reviewDue('Review due'),
  completed('Completed'),
  escalated('Escalated');

  final String label;

  const EmployeePerformanceSupportStatus(this.label);
}

enum EmployeePerformanceMilestoneType {
  coaching('Coaching'),
  deliverable('Deliverable'),
  behavior('Behavior'),
  training('Training'),
  review('Review');

  final String label;

  const EmployeePerformanceMilestoneType(this.label);
}

enum EmployeePerformanceMilestoneStatus {
  open('Open'),
  inProgress('In progress'),
  blocked('Blocked'),
  completed('Completed'),
  waived('Waived');

  final String label;

  const EmployeePerformanceMilestoneStatus(this.label);
}

enum EmployeePerformanceSupportRisk {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeePerformanceSupportRisk(this.label);
}

class EmployeePerformanceSupportMilestone {
  final String id;
  final String employeeId;
  final EmployeePerformanceMilestoneType type;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeePerformanceMilestoneStatus status;
  final EmployeePerformanceSupportRisk risk;
  final String successMetric;
  final String notes;

  const EmployeePerformanceSupportMilestone({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.risk,
    required this.successMetric,
    required this.notes,
  });

  bool get isComplete {
    return status == EmployeePerformanceMilestoneStatus.completed ||
        status == EmployeePerformanceMilestoneStatus.waived;
  }

  bool get isBlocked => status == EmployeePerformanceMilestoneStatus.blocked;

  bool get isOpen {
    return status == EmployeePerformanceMilestoneStatus.open ||
        status == EmployeePerformanceMilestoneStatus.inProgress;
  }

  bool get isHighRisk {
    return risk == EmployeePerformanceSupportRisk.critical ||
        risk == EmployeePerformanceSupportRisk.high;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return isBlocked || isOverdue(asOfDate) || (isHighRisk && !isComplete);
  }

  EmployeePerformanceSupportMilestone copyWith({
    EmployeePerformanceMilestoneStatus? status,
    EmployeePerformanceSupportRisk? risk,
    DateTime? dueDate,
    String? notes,
  }) {
    return EmployeePerformanceSupportMilestone(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      owner: owner,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      successMetric: successMetric,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeePerformanceSupportPlan {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String manager;
  final String hrPartner;
  final String title;
  final EmployeePerformanceSupportStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<EmployeePerformanceSupportMilestone> milestones;

  const EmployeePerformanceSupportPlan({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.manager,
    required this.hrPartner,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.milestones,
  });

  EmployeePerformanceSupportPlan copyWith({
    String? hrPartner,
    String? title,
    EmployeePerformanceSupportStatus? status,
    DateTime? endDate,
    List<EmployeePerformanceSupportMilestone>? milestones,
  }) {
    return EmployeePerformanceSupportPlan(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      manager: manager,
      hrPartner: hrPartner ?? this.hrPartner,
      title: title ?? this.title,
      status: status ?? this.status,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      milestones: milestones ?? this.milestones,
    );
  }

  bool get isClosed => status == EmployeePerformanceSupportStatus.completed;

  bool get isEscalated => status == EmployeePerformanceSupportStatus.escalated;

  bool get isReviewDue {
    if (isClosed) return false;
    return status == EmployeePerformanceSupportStatus.reviewDue ||
        !endDate.isAfter(_dateOnly(asOfDate));
  }

  List<EmployeePerformanceSupportMilestone> get sortedMilestones {
    final sorted = [...milestones]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  int get blockedCount => milestones.where((item) => item.isBlocked).length;

  int get overdueCount {
    return milestones.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get openCount => milestones.where((item) => item.isOpen).length;

  int get completedCount {
    return milestones.where((item) => item.isComplete).length;
  }

  int get highRiskOpenCount {
    return milestones
        .where((item) => item.isHighRisk && !item.isComplete)
        .length;
  }

  int get attentionCount {
    return (isEscalated ? 1 : 0) +
        (isReviewDue ? 1 : 0) +
        milestones.where((item) => item.needsAttention(asOfDate)).length;
  }

  int get daysRemaining {
    return endDate.difference(_dateOnly(asOfDate)).inDays;
  }

  double get progressRatio {
    if (milestones.isEmpty) return isClosed ? 1 : 0;
    return completedCount / milestones.length;
  }

  EmployeePerformanceSupportMilestone? get nextMilestone {
    final active = sortedMilestones.where((item) => !item.isComplete).toList();
    if (active.isEmpty) return null;
    return active.first;
  }

  String get nextAction {
    if (isEscalated) {
      return 'Resolve escalated performance support plan.';
    }
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked support milestone${blockedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Complete $overdueCount overdue support milestone${overdueCount == 1 ? '' : 's'}.';
    }
    if (isReviewDue) {
      return 'Run performance support review.';
    }
    if (highRiskOpenCount > 0) {
      return 'De-risk $highRiskOpenCount support milestone${highRiskOpenCount == 1 ? '' : 's'}.';
    }
    final milestone = nextMilestone;
    if (milestone != null) {
      return 'Next: ${milestone.title}.';
    }
    if (isClosed) return 'Performance support plan is completed.';
    return 'Create performance support milestones.';
  }
}

class EmployeePerformanceSupportMilestoneDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeePerformanceMilestoneType type;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final EmployeePerformanceSupportRisk risk;
  final String successMetric;
  final String notes;

  const EmployeePerformanceSupportMilestoneDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.risk,
    required this.successMetric,
    required this.notes,
  });

  factory EmployeePerformanceSupportMilestoneDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeePerformanceSupportMilestoneDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      type: EmployeePerformanceMilestoneType.coaching,
      title: '',
      owner: member.manager,
      dueDate: today.add(const Duration(days: 7)),
      risk: EmployeePerformanceSupportRisk.medium,
      successMetric: '',
      notes: '',
    );
  }

  EmployeePerformanceSupportMilestoneDraft copyWith({
    EmployeePerformanceMilestoneType? type,
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeePerformanceSupportRisk? risk,
    String? successMetric,
    String? notes,
  }) {
    return EmployeePerformanceSupportMilestoneDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      risk: risk ?? this.risk,
      successMetric: successMetric ?? this.successMetric,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Milestone title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Milestone owner is required');
    }
    final due = dueDate;
    if (due == null) {
      errors.add('Due date is required');
    } else if (due.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    if (successMetric.trim().length < 8) {
      errors.add('Success metric must be at least 8 characters');
    }
    if (notes.trim().length < 8) {
      errors.add('Notes must be at least 8 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (title.trim().length >= 4) completed++;
    if (owner.trim().length >= 3) completed++;
    final due = dueDate;
    if (due != null && !due.isBefore(asOfDate)) completed++;
    if (successMetric.trim().length >= 8) completed++;
    if (notes.trim().length >= 8) completed++;
    return completed / 5;
  }

  EmployeePerformanceSupportMilestone toMilestone({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeePerformanceSupportMilestone(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      dueDate: _dateOnly(dueDate!),
      status: EmployeePerformanceMilestoneStatus.open,
      risk: risk,
      successMetric: successMetric.trim(),
      notes: notes.trim(),
    );
  }
}

int _attentionRank(
  EmployeePerformanceSupportMilestone milestone,
  DateTime asOfDate,
) {
  if (milestone.isBlocked) return 0;
  if (milestone.isOverdue(asOfDate)) return 1;
  if (milestone.isHighRisk && !milestone.isComplete) return 2;
  if (milestone.isComplete) return 4;
  return 3;
}

int _riskRank(EmployeePerformanceSupportRisk risk) {
  return switch (risk) {
    EmployeePerformanceSupportRisk.critical => 0,
    EmployeePerformanceSupportRisk.high => 1,
    EmployeePerformanceSupportRisk.medium => 2,
    EmployeePerformanceSupportRisk.low => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
