import 'incoming_talent_development_intervention_outcome_follow_up.dart';
import 'incoming_talent_development_intervention_outcome_models.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft {
  final String outcomeId;
  final String interventionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime? outcomeReviewDate;
  final DateTime? dueDate;
  final IncomingTalentDevelopmentInterventionOutcomeDecision? sourceDecision;
  final int confidenceAfter;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus status;
  final String action;
  final String successCriteria;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft({
    required this.outcomeId,
    required this.interventionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.outcomeReviewDate,
    required this.dueDate,
    required this.sourceDecision,
    required this.confidenceAfter,
    required this.remainingReleaseRiskCount,
    required this.status,
    required this.action,
    required this.successCriteria,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft(
      outcomeId: '',
      interventionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      reviewerName: '',
      outcomeReviewDate: null,
      dueDate: null,
      sourceDecision: null,
      confidenceAfter: 0,
      remainingReleaseRiskCount: 0,
      status: IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
      action: '',
      successCriteria: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.fromOutcome({
    required IncomingTalentDevelopmentInterventionOutcome outcome,
    required DateTime asOfDate,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft(
      outcomeId: outcome.id,
      interventionId: outcome.interventionId,
      candidateId: outcome.candidateId,
      candidateName: outcome.candidateName,
      role: outcome.role,
      department: outcome.department,
      ownerName:
          outcome.ownerName.isEmpty ? outcome.reviewerName : outcome.ownerName,
      reviewerName: outcome.reviewerName,
      outcomeReviewDate: outcome.reviewDate,
      dueDate: outcome.nextReviewDate,
      sourceDecision: outcome.decision,
      confidenceAfter: outcome.confidenceAfter,
      remainingReleaseRiskCount: outcome.remainingReleaseRiskCount,
      status: IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
      action: outcome.nextAction,
      successCriteria: _defaultSuccessCriteria(outcome),
      asOfDate: asOfDate,
    );
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final checks = <bool>[
      outcomeId.isNotEmpty,
      ownerName.trim().isNotEmpty,
      dueDate != null,
      sourceDecision != null,
      action.trim().length >= 10,
      successCriteria.trim().length >= 10,
    ];
    return checks.where((item) => item).length / checks.length;
  }

  List<String> get validationErrors {
    return [
      validateRequired(outcomeId, 'an intervention outcome'),
      validateRequired(ownerName, 'a follow-up owner'),
      validateDueDate(outcomeReviewDate, dueDate),
      validateSourceDecision(sourceDecision),
      validateAction(action),
      validateSuccessCriteria(successCriteria),
    ].whereType<String>().toList();
  }

  IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft copyWith({
    String? ownerName,
    DateTime? dueDate,
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus? status,
    String? action,
    String? successCriteria,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft(
      outcomeId: outcomeId,
      interventionId: interventionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName ?? this.ownerName,
      reviewerName: reviewerName,
      outcomeReviewDate: outcomeReviewDate,
      dueDate: dueDate ?? this.dueDate,
      sourceDecision: sourceDecision,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      status: status ?? this.status,
      action: action ?? this.action,
      successCriteria: successCriteria ?? this.successCriteria,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentDevelopmentInterventionOutcomeFollowUp toFollowUp({
    required String id,
    required DateTime createdAt,
  }) {
    final reviewDate = outcomeReviewDate;
    final followUpDueDate = dueDate;
    final decision = sourceDecision;
    if (reviewDate == null || followUpDueDate == null || decision == null) {
      throw StateError('Follow-up draft is incomplete');
    }
    return IncomingTalentDevelopmentInterventionOutcomeFollowUp(
      id: id,
      outcomeId: outcomeId,
      interventionId: interventionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      outcomeReviewDate: reviewDate,
      dueDate: followUpDueDate,
      sourceDecision: decision,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      status: status,
      action: action.trim(),
      successCriteria: successCriteria.trim(),
      resolutionNote: '',
      completedAt: null,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Choose $label.';
    return null;
  }

  static String? validateSourceDecision(
    IncomingTalentDevelopmentInterventionOutcomeDecision? value,
  ) {
    if (value == null) return 'Choose an outcome decision.';
    return null;
  }

  static String? validateDueDate(
    DateTime? outcomeReviewDate,
    DateTime? dueDate,
  ) {
    if (dueDate == null) return 'Choose a follow-up due date.';
    if (outcomeReviewDate != null && dueDate.isBefore(outcomeReviewDate)) {
      return 'Follow-up due date cannot be before the outcome review.';
    }
    return null;
  }

  static String? validateAction(String? value) {
    if (value == null || value.trim().length < 10) {
      return 'Enter a clear follow-up action.';
    }
    return null;
  }

  static String? validateSuccessCriteria(String? value) {
    if (value == null || value.trim().length < 10) {
      return 'Enter measurable success criteria.';
    }
    return null;
  }
}

String _defaultSuccessCriteria(
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  return switch (outcome.decision) {
    IncomingTalentDevelopmentInterventionOutcomeDecision.improved =>
      'Outcome evidence is archived and normal development cadence continues.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized =>
      'Manager confirms confidence remains at ${outcome.confidenceAfter}/5 or better.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.monitor =>
      'Remaining development risk is reviewed with an owner and next decision.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.escalate =>
      'HR and manager council agree on escalation owner and recovery action.',
  };
}
