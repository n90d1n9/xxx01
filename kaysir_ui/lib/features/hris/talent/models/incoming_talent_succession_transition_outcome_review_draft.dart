import 'incoming_talent_succession_transition_intervention.dart';
import 'incoming_talent_succession_transition_outcome_review.dart';
import 'incoming_talent_succession_transition_pulse.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewDraft {
  final String interventionId;
  final String pulseId;
  final String closureId;
  final String resolutionReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final IncomingTalentSuccessionTransitionInterventionType? interventionType;
  final IncomingTalentSuccessionTransitionInterventionStatus?
  interventionStatus;
  final IncomingTalentSuccessionTransitionPulseHealth? pulseHealth;
  final IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk;
  final DateTime? reviewDate;
  final IncomingTalentSuccessionTransitionOutcomeDecision? decision;
  final IncomingTalentSuccessionTransitionOutcomeResidualRisk? residualRisk;
  final int stabilizationScore;
  final String evidenceSummary;
  final String lessonsLearned;
  final String nextTalentAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionTransitionOutcomeReviewDraft({
    required this.interventionId,
    required this.pulseId,
    required this.closureId,
    required this.resolutionReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.interventionType,
    required this.interventionStatus,
    required this.pulseHealth,
    required this.retentionRisk,
    required this.reviewDate,
    required this.decision,
    required this.residualRisk,
    required this.stabilizationScore,
    required this.evidenceSummary,
    required this.lessonsLearned,
    required this.nextTalentAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionTransitionOutcomeReviewDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionTransitionOutcomeReviewDraft(
      interventionId: '',
      pulseId: '',
      closureId: '',
      resolutionReviewId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      reviewerName: '',
      interventionType: null,
      interventionStatus: null,
      pulseHealth: null,
      retentionRisk: null,
      reviewDate: null,
      decision: null,
      residualRisk: null,
      stabilizationScore: 0,
      evidenceSummary: '',
      lessonsLearned: '',
      nextTalentAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionTransitionOutcomeReviewDraft.fromIntervention({
    required IncomingTalentSuccessionTransitionIntervention intervention,
    required DateTime asOfDate,
  }) {
    final decision = _defaultDecision(intervention);
    final residualRisk = _defaultResidualRisk(intervention);

    return IncomingTalentSuccessionTransitionOutcomeReviewDraft(
      interventionId: intervention.id,
      pulseId: intervention.pulseId,
      closureId: intervention.closureId,
      resolutionReviewId: intervention.resolutionReviewId,
      activationPlanId: intervention.activationPlanId,
      decisionId: intervention.decisionId,
      candidateId: intervention.candidateId,
      candidateName: intervention.candidateName,
      role: intervention.role,
      department: intervention.department,
      targetRole: intervention.targetRole,
      reviewerName: intervention.ownerName,
      interventionType: intervention.interventionType,
      interventionStatus: intervention.status,
      pulseHealth: intervention.pulseHealth,
      retentionRisk: intervention.retentionRisk,
      reviewDate: asOfDate,
      decision: decision,
      residualRisk: residualRisk,
      stabilizationScore: _defaultStabilizationScore(intervention),
      evidenceSummary:
          'Completed ${intervention.interventionType.label.toLowerCase()} intervention against ${intervention.successMetric.toLowerCase()}',
      lessonsLearned:
          'Sponsor support and manager feedback confirm what stabilized the transition.',
      nextTalentAction: _defaultNextTalentAction(decision),
      nextReviewDate: _nextReviewDateForDecision(decision, asOfDate),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionTransitionOutcomeReviewDraft copyWith({
    String? interventionId,
    String? pulseId,
    String? closureId,
    String? resolutionReviewId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? reviewerName,
    IncomingTalentSuccessionTransitionInterventionType? interventionType,
    IncomingTalentSuccessionTransitionInterventionStatus? interventionStatus,
    IncomingTalentSuccessionTransitionPulseHealth? pulseHealth,
    IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk,
    DateTime? reviewDate,
    IncomingTalentSuccessionTransitionOutcomeDecision? decision,
    IncomingTalentSuccessionTransitionOutcomeResidualRisk? residualRisk,
    int? stabilizationScore,
    String? evidenceSummary,
    String? lessonsLearned,
    String? nextTalentAction,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionTransitionOutcomeReviewDraft(
      interventionId: interventionId ?? this.interventionId,
      pulseId: pulseId ?? this.pulseId,
      closureId: closureId ?? this.closureId,
      resolutionReviewId: resolutionReviewId ?? this.resolutionReviewId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      reviewerName: reviewerName ?? this.reviewerName,
      interventionType: interventionType ?? this.interventionType,
      interventionStatus: interventionStatus ?? this.interventionStatus,
      pulseHealth: pulseHealth ?? this.pulseHealth,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      residualRisk: residualRisk ?? this.residualRisk,
      stabilizationScore: stabilizationScore ?? this.stabilizationScore,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      nextTalentAction: nextTalentAction ?? this.nextTalentAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          interventionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          interventionStatus ==
              IncomingTalentSuccessionTransitionInterventionStatus.completed,
          reviewDate != null,
          decision != null,
          residualRisk != null,
          validateStabilizationScore(stabilizationScore) == null,
          evidenceSummary.trim().length >= 12,
          lessonsLearned.trim().length >= 12,
          nextTalentAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(interventionId, 'a completed intervention')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'an outcome reviewer')
          case final error?)
        error,
      if (validateInterventionStatus(interventionStatus) case final error?)
        error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validateResidualRisk(residualRisk) case final error?) error,
      if (validateStabilizationScore(stabilizationScore) case final error?)
        error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateLessonsLearned(lessonsLearned) case final error?) error,
      if (validateNextTalentAction(nextTalentAction) case final error?) error,
      if (validateNextReviewDate(reviewDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionTransitionOutcomeReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionTransitionOutcomeReview(
      id: id,
      interventionId: interventionId,
      pulseId: pulseId,
      closureId: closureId,
      resolutionReviewId: resolutionReviewId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      reviewerName: reviewerName.trim(),
      interventionType: interventionType!,
      pulseHealth: pulseHealth!,
      retentionRisk: retentionRisk!,
      reviewDate: reviewDate!,
      decision: decision!,
      residualRisk: residualRisk!,
      stabilizationScore: stabilizationScore,
      evidenceSummary: evidenceSummary.trim(),
      lessonsLearned: lessonsLearned.trim(),
      nextTalentAction: nextTalentAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateInterventionStatus(
    IncomingTalentSuccessionTransitionInterventionStatus? value,
  ) {
    if (value == null) return 'Select a completed intervention';
    if (value !=
        IncomingTalentSuccessionTransitionInterventionStatus.completed) {
      return 'Intervention must be completed before outcome review';
    }
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateDecision(
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

  static String? validateStabilizationScore(int value) {
    if (value < 1 || value > 5) {
      return 'Stabilization score must be between 1 and 5';
    }
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select next review date';
    if (reviewDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
      return 'Next review must be after review date';
    }
    return null;
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateLessonsLearned(String? value) {
    return _validateLongText(value, 'lessons learned');
  }

  static String? validateNextTalentAction(String? value) {
    return _validateLongText(value, 'next talent action');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionTransitionOutcomeDecision _defaultDecision(
  IncomingTalentSuccessionTransitionIntervention intervention,
) {
  if (intervention.retentionRisk ==
      IncomingTalentSuccessionTransitionRetentionRisk.high) {
    return IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport;
  }
  if (intervention.pulseHealth ==
      IncomingTalentSuccessionTransitionPulseHealth.intervention) {
    return IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview;
  }
  if (intervention.pulseHealth ==
      IncomingTalentSuccessionTransitionPulseHealth.watch) {
    return IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport;
  }
  return IncomingTalentSuccessionTransitionOutcomeDecision.stabilized;
}

IncomingTalentSuccessionTransitionOutcomeResidualRisk _defaultResidualRisk(
  IncomingTalentSuccessionTransitionIntervention intervention,
) {
  if (intervention.retentionRisk ==
      IncomingTalentSuccessionTransitionRetentionRisk.high) {
    return IncomingTalentSuccessionTransitionOutcomeResidualRisk.high;
  }
  if (intervention.pulseHealth ==
          IncomingTalentSuccessionTransitionPulseHealth.intervention ||
      intervention.pulseHealth ==
          IncomingTalentSuccessionTransitionPulseHealth.watch) {
    return IncomingTalentSuccessionTransitionOutcomeResidualRisk.medium;
  }
  return IncomingTalentSuccessionTransitionOutcomeResidualRisk.low;
}

int _defaultStabilizationScore(
  IncomingTalentSuccessionTransitionIntervention intervention,
) {
  if (intervention.retentionRisk ==
          IncomingTalentSuccessionTransitionRetentionRisk.high ||
      intervention.pulseHealth ==
          IncomingTalentSuccessionTransitionPulseHealth.intervention) {
    return 3;
  }
  if (intervention.pulseHealth ==
      IncomingTalentSuccessionTransitionPulseHealth.watch) {
    return 4;
  }
  return 5;
}

DateTime _nextReviewDateForDecision(
  IncomingTalentSuccessionTransitionOutcomeDecision decision,
  DateTime asOfDate,
) {
  final days = switch (decision) {
    IncomingTalentSuccessionTransitionOutcomeDecision.stabilized => 60,
    IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport => 30,
    IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview => 14,
    IncomingTalentSuccessionTransitionOutcomeDecision.successionRework => 14,
  };
  return asOfDate.add(Duration(days: days));
}

String _defaultNextTalentAction(
  IncomingTalentSuccessionTransitionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentSuccessionTransitionOutcomeDecision.stabilized =>
      'Archive transition learnings and update the successor readiness profile.',
    IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport =>
      'Continue sponsor check-ins and keep the successor on transition watch.',
    IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview =>
      'Route transition evidence to leadership for operating model support.',
    IncomingTalentSuccessionTransitionOutcomeDecision.successionRework =>
      'Reopen succession coverage and assign interim support for the role.',
  };
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionTransitionOutcomeReviewDraft.validateRequired(
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
