enum EmployeePerformanceCycleStatus {
  onTrack('On track'),
  attention('Attention'),
  readyForReview('Ready for review'),
  overdue('Overdue');

  final String label;

  const EmployeePerformanceCycleStatus(this.label);
}

enum EmployeePerformanceGoalStatus {
  active('Active'),
  atRisk('At risk'),
  complete('Complete'),
  paused('Paused');

  final String label;

  const EmployeePerformanceGoalStatus(this.label);
}

enum EmployeePerformanceCheckInSentiment {
  positive('Positive'),
  neutral('Neutral'),
  concern('Concern');

  final String label;

  const EmployeePerformanceCheckInSentiment(this.label);
}

class EmployeePerformanceGoal {
  final String id;
  final String employeeId;
  final String title;
  final String owner;
  final DateTime targetDate;
  final double progress;
  final int weight;
  final EmployeePerformanceGoalStatus status;

  const EmployeePerformanceGoal({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.owner,
    required this.targetDate,
    required this.progress,
    required this.weight,
    required this.status,
  });

  bool get isComplete => status == EmployeePerformanceGoalStatus.complete;

  bool get needsAttention => status == EmployeePerformanceGoalStatus.atRisk;

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && targetDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeePerformanceGoal copyWith({
    double? progress,
    EmployeePerformanceGoalStatus? status,
  }) {
    final resolvedProgress = progress?.clamp(0, 1).toDouble() ?? this.progress;
    final resolvedStatus =
        status ??
        (resolvedProgress >= 1
            ? EmployeePerformanceGoalStatus.complete
            : this.status);

    return EmployeePerformanceGoal(
      id: id,
      employeeId: employeeId,
      title: title,
      owner: owner,
      targetDate: targetDate,
      progress: resolvedProgress,
      weight: weight,
      status: resolvedStatus,
    );
  }
}

class EmployeePerformanceCheckIn {
  final String id;
  final String employeeId;
  final String author;
  final DateTime date;
  final EmployeePerformanceCheckInSentiment sentiment;
  final String summary;
  final String nextStep;

  const EmployeePerformanceCheckIn({
    required this.id,
    required this.employeeId,
    required this.author,
    required this.date,
    required this.sentiment,
    required this.summary,
    required this.nextStep,
  });
}

class EmployeePerformancePlan {
  final String employeeId;
  final String employeeName;
  final String manager;
  final DateTime asOfDate;
  final String cycleName;
  final DateTime reviewDueDate;
  final List<EmployeePerformanceGoal> goals;
  final List<EmployeePerformanceCheckIn> checkIns;

  const EmployeePerformancePlan({
    required this.employeeId,
    required this.employeeName,
    required this.manager,
    required this.asOfDate,
    required this.cycleName,
    required this.reviewDueDate,
    required this.goals,
    required this.checkIns,
  });

  EmployeePerformancePlan copyWith({
    List<EmployeePerformanceGoal>? goals,
    List<EmployeePerformanceCheckIn>? checkIns,
  }) {
    return EmployeePerformancePlan(
      employeeId: employeeId,
      employeeName: employeeName,
      manager: manager,
      asOfDate: asOfDate,
      cycleName: cycleName,
      reviewDueDate: reviewDueDate,
      goals: goals ?? this.goals,
      checkIns: checkIns ?? this.checkIns,
    );
  }

  int get activeGoalCount {
    return goals
        .where((goal) => goal.status == EmployeePerformanceGoalStatus.active)
        .length;
  }

  int get atRiskGoalCount {
    return goals.where((goal) => goal.needsAttention).length;
  }

  int get completeGoalCount {
    return goals.where((goal) => goal.isComplete).length;
  }

  int get overdueGoalCount {
    return goals.where((goal) => goal.isOverdue(asOfDate)).length;
  }

  double get weightedProgress {
    final totalWeight = goals.fold<int>(
      0,
      (total, goal) => total + goal.weight,
    );
    if (totalWeight == 0) return 0;

    final weightedTotal = goals.fold<double>(
      0,
      (total, goal) => total + (goal.progress * goal.weight),
    );
    return weightedTotal / totalWeight;
  }

  EmployeePerformanceCycleStatus get cycleStatus {
    if (reviewDueDate.isBefore(_dateOnly(asOfDate))) {
      return EmployeePerformanceCycleStatus.overdue;
    }
    if (atRiskGoalCount > 0 || overdueGoalCount > 0) {
      return EmployeePerformanceCycleStatus.attention;
    }
    if (weightedProgress >= 0.85) {
      return EmployeePerformanceCycleStatus.readyForReview;
    }
    return EmployeePerformanceCycleStatus.onTrack;
  }

  EmployeePerformanceCheckIn? get latestCheckIn {
    if (checkIns.isEmpty) return null;
    final sorted = [...checkIns]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  String get nextAction {
    if (cycleStatus == EmployeePerformanceCycleStatus.overdue) {
      return 'Complete the overdue performance review.';
    }
    if (atRiskGoalCount > 0) {
      return 'Coach $atRiskGoalCount at-risk goal${atRiskGoalCount == 1 ? '' : 's'}.';
    }
    if (weightedProgress >= 0.85) {
      return 'Prepare calibration notes for review.';
    }
    return 'Keep goals current with manager check-ins.';
  }
}

class EmployeePerformanceCheckInDraft {
  final String employeeId;
  final String employeeName;
  final String manager;
  final DateTime asOfDate;
  final EmployeePerformanceCheckInSentiment sentiment;
  final String summary;
  final String nextStep;

  const EmployeePerformanceCheckInDraft({
    required this.employeeId,
    required this.employeeName,
    required this.manager,
    required this.asOfDate,
    required this.sentiment,
    required this.summary,
    required this.nextStep,
  });

  EmployeePerformanceCheckInDraft copyWith({
    EmployeePerformanceCheckInSentiment? sentiment,
    String? summary,
    String? nextStep,
  }) {
    return EmployeePerformanceCheckInDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      manager: manager,
      asOfDate: asOfDate,
      sentiment: sentiment ?? this.sentiment,
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (summary.trim().length < 12) {
      errors.add('Check-in summary must be at least 12 characters');
    }
    if (nextStep.trim().length < 8) {
      errors.add('Next step must be at least 8 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (summary.trim().length >= 12) completed++;
    if (nextStep.trim().length >= 8) completed++;
    return completed / 2;
  }

  EmployeePerformanceCheckIn toCheckIn({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeePerformanceCheckIn(
      id: id,
      employeeId: employeeId,
      author: manager,
      date: asOfDate,
      sentiment: sentiment,
      summary: summary.trim(),
      nextStep: nextStep.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
