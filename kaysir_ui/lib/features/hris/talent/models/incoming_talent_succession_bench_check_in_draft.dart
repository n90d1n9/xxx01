import 'incoming_talent_succession_bench_check_in.dart';
import 'incoming_talent_succession_bench_replenishment.dart';

class IncomingTalentSuccessionBenchCheckInDraft {
  final String benchReplenishmentId;
  final String outcomeReviewId;
  final String interventionId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionBenchReplenishmentPriority? priority;
  final IncomingTalentSuccessionBenchReplenishmentStatus? planStatus;
  final DateTime? checkInDate;
  final IncomingTalentSuccessionBenchCheckInHealth? health;
  final int successorSlateCount;
  final int readyNowCount;
  final int readinessScore;
  final String blockerSummary;
  final String leadershipSupport;
  final String nextAction;
  final DateTime? nextCheckInDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionBenchCheckInDraft({
    required this.benchReplenishmentId,
    required this.outcomeReviewId,
    required this.interventionId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.priority,
    required this.planStatus,
    required this.checkInDate,
    required this.health,
    required this.successorSlateCount,
    required this.readyNowCount,
    required this.readinessScore,
    required this.blockerSummary,
    required this.leadershipSupport,
    required this.nextAction,
    required this.nextCheckInDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionBenchCheckInDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionBenchCheckInDraft(
      benchReplenishmentId: '',
      outcomeReviewId: '',
      interventionId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      priority: null,
      planStatus: null,
      checkInDate: null,
      health: null,
      successorSlateCount: 0,
      readyNowCount: 0,
      readinessScore: 0,
      blockerSummary: '',
      leadershipSupport: '',
      nextAction: '',
      nextCheckInDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionBenchCheckInDraft.fromReplenishment({
    required IncomingTalentSuccessionBenchReplenishment plan,
    required DateTime asOfDate,
  }) {
    final health = _defaultHealth(plan);
    final slateCount = _defaultSlateCount(plan);
    final readyNowCount = _defaultReadyNowCount(plan);

    return IncomingTalentSuccessionBenchCheckInDraft(
      benchReplenishmentId: plan.id,
      outcomeReviewId: plan.outcomeReviewId,
      interventionId: plan.interventionId,
      activationPlanId: plan.activationPlanId,
      decisionId: plan.decisionId,
      candidateId: plan.candidateId,
      candidateName: plan.candidateName,
      role: plan.role,
      department: plan.department,
      targetRole: plan.targetRole,
      ownerName: plan.ownerName,
      priority: plan.priority,
      planStatus: plan.status,
      checkInDate: asOfDate,
      health: health,
      successorSlateCount: slateCount,
      readyNowCount: readyNowCount,
      readinessScore: _defaultReadinessScore(plan),
      blockerSummary: _defaultBlockerSummary(plan, health),
      leadershipSupport:
          'Leadership confirms sponsorship for ${plan.role} coverage and decision speed.',
      nextAction: _defaultNextAction(plan, health),
      nextCheckInDate: _nextCheckInDate(plan.priority, asOfDate),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionBenchCheckInDraft copyWith({
    String? benchReplenishmentId,
    String? outcomeReviewId,
    String? interventionId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionBenchReplenishmentPriority? priority,
    IncomingTalentSuccessionBenchReplenishmentStatus? planStatus,
    DateTime? checkInDate,
    IncomingTalentSuccessionBenchCheckInHealth? health,
    int? successorSlateCount,
    int? readyNowCount,
    int? readinessScore,
    String? blockerSummary,
    String? leadershipSupport,
    String? nextAction,
    DateTime? nextCheckInDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionBenchCheckInDraft(
      benchReplenishmentId: benchReplenishmentId ?? this.benchReplenishmentId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      interventionId: interventionId ?? this.interventionId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      priority: priority ?? this.priority,
      planStatus: planStatus ?? this.planStatus,
      checkInDate: checkInDate ?? this.checkInDate,
      health: health ?? this.health,
      successorSlateCount: successorSlateCount ?? this.successorSlateCount,
      readyNowCount: readyNowCount ?? this.readyNowCount,
      readinessScore: readinessScore ?? this.readinessScore,
      blockerSummary: blockerSummary ?? this.blockerSummary,
      leadershipSupport: leadershipSupport ?? this.leadershipSupport,
      nextAction: nextAction ?? this.nextAction,
      nextCheckInDate: nextCheckInDate ?? this.nextCheckInDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          benchReplenishmentId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          priority != null,
          validatePlanStatus(planStatus) == null,
          checkInDate != null,
          health != null,
          validateSuccessorSlateCount(successorSlateCount) == null,
          validateReadyNowCount(readyNowCount, successorSlateCount) == null,
          validateReadinessScore(readinessScore) == null,
          blockerSummary.trim().length >= 12,
          leadershipSupport.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextCheckInDate != null,
        ].where((item) => item).length;

    return completed / 13;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(benchReplenishmentId, 'an open bench plan')
          case final error?)
        error,
      if (validateRequired(ownerName, 'a check-in owner') case final error?)
        error,
      if (validatePriority(priority) case final error?) error,
      if (validatePlanStatus(planStatus) case final error?) error,
      if (validateCheckInDate(checkInDate, asOfDate) case final error?) error,
      if (validateHealth(health) case final error?) error,
      if (validateSuccessorSlateCount(successorSlateCount) case final error?)
        error,
      if (validateReadyNowCount(readyNowCount, successorSlateCount)
          case final error?)
        error,
      if (validateReadinessScore(readinessScore) case final error?) error,
      if (validateBlockerSummary(blockerSummary) case final error?) error,
      if (validateLeadershipSupport(leadershipSupport) case final error?) error,
      if (validateNextAction(nextAction) case final error?) error,
      if (validateNextCheckInDate(checkInDate, nextCheckInDate)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionBenchCheckIn toCheckIn({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionBenchCheckIn(
      id: id,
      benchReplenishmentId: benchReplenishmentId,
      outcomeReviewId: outcomeReviewId,
      interventionId: interventionId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      priority: priority!,
      planStatus: planStatus!,
      checkInDate: checkInDate!,
      health: health!,
      successorSlateCount: successorSlateCount,
      readyNowCount: readyNowCount,
      readinessScore: readinessScore,
      blockerSummary: blockerSummary.trim(),
      leadershipSupport: leadershipSupport.trim(),
      nextAction: nextAction.trim(),
      nextCheckInDate: nextCheckInDate!,
      createdAt: createdAt,
    );
  }

  static String? validatePriority(
    IncomingTalentSuccessionBenchReplenishmentPriority? value,
  ) {
    if (value == null) return 'Select bench priority';
    return null;
  }

  static String? validatePlanStatus(
    IncomingTalentSuccessionBenchReplenishmentStatus? value,
  ) {
    if (value == null) return 'Select bench plan status';
    if (value == IncomingTalentSuccessionBenchReplenishmentStatus.completed) {
      return 'Bench plan must be open for check-in';
    }
    return null;
  }

  static String? validateCheckInDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select check-in date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Check-in date cannot be in the past';
    }
    return null;
  }

  static String? validateHealth(
    IncomingTalentSuccessionBenchCheckInHealth? value,
  ) {
    if (value == null) return 'Select bench health';
    return null;
  }

  static String? validateSuccessorSlateCount(int value) {
    if (value < 1 || value > 20) {
      return 'Successor slate must be between 1 and 20';
    }
    return null;
  }

  static String? validateReadyNowCount(int value, int successorSlateCount) {
    if (value < 0) return 'Ready-now count cannot be negative';
    if (successorSlateCount > 0 && value > successorSlateCount) {
      return 'Ready-now count cannot exceed successor slate';
    }
    return null;
  }

  static String? validateReadinessScore(int value) {
    if (value < 1 || value > 5) {
      return 'Readiness score must be between 1 and 5';
    }
    return null;
  }

  static String? validateNextCheckInDate(
    DateTime? checkInDate,
    DateTime? nextCheckInDate,
  ) {
    if (nextCheckInDate == null) return 'Select next check-in date';
    if (checkInDate == null) return null;
    if (!_dateOnly(nextCheckInDate).isAfter(_dateOnly(checkInDate))) {
      return 'Next check-in must be after check-in date';
    }
    return null;
  }

  static String? validateBlockerSummary(String? value) {
    return _validateLongText(value, 'blocker summary');
  }

  static String? validateLeadershipSupport(String? value) {
    return _validateLongText(value, 'leadership support');
  }

  static String? validateNextAction(String? value) {
    return _validateLongText(value, 'next action');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionBenchCheckInHealth _defaultHealth(
  IncomingTalentSuccessionBenchReplenishment plan,
) {
  if (plan.status == IncomingTalentSuccessionBenchReplenishmentStatus.blocked) {
    return IncomingTalentSuccessionBenchCheckInHealth.blocked;
  }
  if (plan.priority ==
      IncomingTalentSuccessionBenchReplenishmentPriority.critical) {
    return IncomingTalentSuccessionBenchCheckInHealth.atRisk;
  }
  if (plan.priority ==
      IncomingTalentSuccessionBenchReplenishmentPriority.accelerated) {
    return IncomingTalentSuccessionBenchCheckInHealth.watch;
  }
  return IncomingTalentSuccessionBenchCheckInHealth.onTrack;
}

int _defaultSlateCount(IncomingTalentSuccessionBenchReplenishment plan) {
  return switch (plan.priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical => 2,
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated => 3,
    IncomingTalentSuccessionBenchReplenishmentPriority.routine => 4,
  };
}

int _defaultReadyNowCount(IncomingTalentSuccessionBenchReplenishment plan) {
  return switch (plan.priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical => 0,
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated => 1,
    IncomingTalentSuccessionBenchReplenishmentPriority.routine => 2,
  };
}

int _defaultReadinessScore(IncomingTalentSuccessionBenchReplenishment plan) {
  return switch (plan.priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical => 3,
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated => 3,
    IncomingTalentSuccessionBenchReplenishmentPriority.routine => 4,
  };
}

DateTime _nextCheckInDate(
  IncomingTalentSuccessionBenchReplenishmentPriority priority,
  DateTime asOfDate,
) {
  final days = switch (priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical => 7,
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated => 14,
    IncomingTalentSuccessionBenchReplenishmentPriority.routine => 30,
  };
  return asOfDate.add(Duration(days: days));
}

String _defaultBlockerSummary(
  IncomingTalentSuccessionBenchReplenishment plan,
  IncomingTalentSuccessionBenchCheckInHealth health,
) {
  if (health == IncomingTalentSuccessionBenchCheckInHealth.onTrack) {
    return 'No material bench blockers; slate development is progressing.';
  }
  return '${plan.priority.label} bench coverage still needs sourcing and readiness acceleration.';
}

String _defaultNextAction(
  IncomingTalentSuccessionBenchReplenishment plan,
  IncomingTalentSuccessionBenchCheckInHealth health,
) {
  if (health == IncomingTalentSuccessionBenchCheckInHealth.onTrack) {
    return 'Continue slate development and confirm ready-now coverage.';
  }
  return 'Escalate bench blockers and confirm additional successor options for ${plan.role}.';
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionBenchCheckInDraft.validateRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
