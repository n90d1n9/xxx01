import 'incoming_talent_succession_bench_replenishment.dart';
import 'incoming_talent_succession_transition_outcome_review.dart';

class IncomingTalentSuccessionBenchReplenishmentDraft {
  final String outcomeReviewId;
  final String interventionId;
  final String pulseId;
  final String closureId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionTransitionOutcomeDecision? outcomeDecision;
  final IncomingTalentSuccessionTransitionOutcomeResidualRisk? residualRisk;
  final IncomingTalentSuccessionBenchReplenishmentPriority? priority;
  final IncomingTalentSuccessionBenchReplenishmentStatus? status;
  final DateTime? targetReadyDate;
  final String benchGap;
  final String sourcingStrategy;
  final String developmentTrack;
  final String reviewCadence;
  final DateTime asOfDate;

  const IncomingTalentSuccessionBenchReplenishmentDraft({
    required this.outcomeReviewId,
    required this.interventionId,
    required this.pulseId,
    required this.closureId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.outcomeDecision,
    required this.residualRisk,
    required this.priority,
    required this.status,
    required this.targetReadyDate,
    required this.benchGap,
    required this.sourcingStrategy,
    required this.developmentTrack,
    required this.reviewCadence,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionBenchReplenishmentDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionBenchReplenishmentDraft(
      outcomeReviewId: '',
      interventionId: '',
      pulseId: '',
      closureId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      outcomeDecision: null,
      residualRisk: null,
      priority: null,
      status: null,
      targetReadyDate: null,
      benchGap: '',
      sourcingStrategy: '',
      developmentTrack: '',
      reviewCadence: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionBenchReplenishmentDraft.fromOutcomeReview({
    required IncomingTalentSuccessionTransitionOutcomeReview review,
    required DateTime asOfDate,
  }) {
    final priority = _defaultPriority(review);

    return IncomingTalentSuccessionBenchReplenishmentDraft(
      outcomeReviewId: review.id,
      interventionId: review.interventionId,
      pulseId: review.pulseId,
      closureId: review.closureId,
      activationPlanId: review.activationPlanId,
      decisionId: review.decisionId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      role: review.role,
      department: review.department,
      targetRole: review.targetRole,
      ownerName: review.reviewerName,
      outcomeDecision: review.decision,
      residualRisk: review.residualRisk,
      priority: priority,
      status: IncomingTalentSuccessionBenchReplenishmentStatus.planned,
      targetReadyDate: _targetReadyDate(priority, asOfDate),
      benchGap:
          'Rebuild bench coverage for ${review.role} after ${review.candidateName} moved into ${review.targetRole}.',
      sourcingStrategy: _defaultSourcingStrategy(priority, review),
      developmentTrack:
          'Assign successor candidates to a readiness track for ${review.role} coverage.',
      reviewCadence: _defaultReviewCadence(priority),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionBenchReplenishmentDraft copyWith({
    String? outcomeReviewId,
    String? interventionId,
    String? pulseId,
    String? closureId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionTransitionOutcomeDecision? outcomeDecision,
    IncomingTalentSuccessionTransitionOutcomeResidualRisk? residualRisk,
    IncomingTalentSuccessionBenchReplenishmentPriority? priority,
    IncomingTalentSuccessionBenchReplenishmentStatus? status,
    DateTime? targetReadyDate,
    String? benchGap,
    String? sourcingStrategy,
    String? developmentTrack,
    String? reviewCadence,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionBenchReplenishmentDraft(
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      interventionId: interventionId ?? this.interventionId,
      pulseId: pulseId ?? this.pulseId,
      closureId: closureId ?? this.closureId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      outcomeDecision: outcomeDecision ?? this.outcomeDecision,
      residualRisk: residualRisk ?? this.residualRisk,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetReadyDate: targetReadyDate ?? this.targetReadyDate,
      benchGap: benchGap ?? this.benchGap,
      sourcingStrategy: sourcingStrategy ?? this.sourcingStrategy,
      developmentTrack: developmentTrack ?? this.developmentTrack,
      reviewCadence: reviewCadence ?? this.reviewCadence,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          outcomeReviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          outcomeDecision != null,
          residualRisk != null,
          priority != null,
          status != null,
          targetReadyDate != null,
          benchGap.trim().length >= 12,
          sourcingStrategy.trim().length >= 12,
          developmentTrack.trim().length >= 12,
          reviewCadence.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(outcomeReviewId, 'a transition outcome')
          case final error?)
        error,
      if (validateRequired(ownerName, 'a replenishment owner')
          case final error?)
        error,
      if (validateOutcomeDecision(outcomeDecision) case final error?) error,
      if (validateResidualRisk(residualRisk) case final error?) error,
      if (validatePriority(priority) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateTargetReadyDate(targetReadyDate, asOfDate) case final error?)
        error,
      if (validateBenchGap(benchGap) case final error?) error,
      if (validateSourcingStrategy(sourcingStrategy) case final error?) error,
      if (validateDevelopmentTrack(developmentTrack) case final error?) error,
      if (validateReviewCadence(reviewCadence) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionBenchReplenishment toReplenishment({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionBenchReplenishment(
      id: id,
      outcomeReviewId: outcomeReviewId,
      interventionId: interventionId,
      pulseId: pulseId,
      closureId: closureId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      outcomeDecision: outcomeDecision!,
      residualRisk: residualRisk!,
      priority: priority!,
      status: status!,
      targetReadyDate: targetReadyDate!,
      benchGap: benchGap.trim(),
      sourcingStrategy: sourcingStrategy.trim(),
      developmentTrack: developmentTrack.trim(),
      reviewCadence: reviewCadence.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateOutcomeDecision(
    IncomingTalentSuccessionTransitionOutcomeDecision? value,
  ) {
    if (value == null) return 'Select outcome decision';
    return null;
  }

  static String? validateResidualRisk(
    IncomingTalentSuccessionTransitionOutcomeResidualRisk? value,
  ) {
    if (value == null) return 'Select residual risk';
    return null;
  }

  static String? validatePriority(
    IncomingTalentSuccessionBenchReplenishmentPriority? value,
  ) {
    if (value == null) return 'Select replenishment priority';
    return null;
  }

  static String? validateStatus(
    IncomingTalentSuccessionBenchReplenishmentStatus? value,
  ) {
    if (value == null) return 'Select replenishment status';
    return null;
  }

  static String? validateTargetReadyDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select target ready date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Target ready date cannot be in the past';
    }
    return null;
  }

  static String? validateBenchGap(String? value) {
    return _validateLongText(value, 'bench gap');
  }

  static String? validateSourcingStrategy(String? value) {
    return _validateLongText(value, 'sourcing strategy');
  }

  static String? validateDevelopmentTrack(String? value) {
    return _validateLongText(value, 'development track');
  }

  static String? validateReviewCadence(String? value) {
    return _validateLongText(value, 'review cadence');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionBenchReplenishmentPriority _defaultPriority(
  IncomingTalentSuccessionTransitionOutcomeReview review,
) {
  if (review.decision ==
          IncomingTalentSuccessionTransitionOutcomeDecision.successionRework ||
      review.decision ==
          IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview ||
      review.residualRisk ==
          IncomingTalentSuccessionTransitionOutcomeResidualRisk.high) {
    return IncomingTalentSuccessionBenchReplenishmentPriority.critical;
  }
  if (review.decision ==
          IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport ||
      review.stabilizationScore <= 3) {
    return IncomingTalentSuccessionBenchReplenishmentPriority.accelerated;
  }
  return IncomingTalentSuccessionBenchReplenishmentPriority.routine;
}

DateTime _targetReadyDate(
  IncomingTalentSuccessionBenchReplenishmentPriority priority,
  DateTime asOfDate,
) {
  final days = switch (priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical => 30,
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated => 60,
    IncomingTalentSuccessionBenchReplenishmentPriority.routine => 90,
  };
  return asOfDate.add(Duration(days: days));
}

String _defaultSourcingStrategy(
  IncomingTalentSuccessionBenchReplenishmentPriority priority,
  IncomingTalentSuccessionTransitionOutcomeReview review,
) {
  return switch (priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical =>
      'Blend internal successors with an external emergency slate for ${review.role}.',
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated =>
      'Build an internal ready-soon slate and confirm interim coverage for ${review.role}.',
    IncomingTalentSuccessionBenchReplenishmentPriority.routine =>
      'Maintain internal development slate and quarterly coverage review for ${review.role}.',
  };
}

String _defaultReviewCadence(
  IncomingTalentSuccessionBenchReplenishmentPriority priority,
) {
  return switch (priority) {
    IncomingTalentSuccessionBenchReplenishmentPriority.critical =>
      'Weekly bench review until coverage is restored.',
    IncomingTalentSuccessionBenchReplenishmentPriority.accelerated =>
      'Biweekly readiness review until successor slate is stable.',
    IncomingTalentSuccessionBenchReplenishmentPriority.routine =>
      'Monthly readiness review with quarterly succession refresh.',
  };
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionBenchReplenishmentDraft.validateRequired(
        value,
        label,
      );
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
