import 'incoming_talent_development_intervention_models.dart';
import 'incoming_talent_development_intervention_outcome.dart';
import 'incoming_talent_development_intervention_outcome_defaults.dart';

class IncomingTalentDevelopmentInterventionOutcomeDraft {
  final String interventionId;
  final String checkInId;
  final String activationFollowUpId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentDevelopmentInterventionSource? source;
  final IncomingTalentDevelopmentInterventionType? interventionType;
  final IncomingTalentDevelopmentInterventionPriority? priority;
  final int confidenceBefore;
  final int confidenceAfter;
  final int releaseEvidenceCount;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeDecision? decision;
  final String evidenceSummary;
  final String learningSummary;
  final String nextAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentInterventionOutcomeDraft({
    required this.interventionId,
    required this.checkInId,
    required this.activationFollowUpId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.reviewDate,
    required this.source,
    required this.interventionType,
    required this.priority,
    required this.confidenceBefore,
    required this.confidenceAfter,
    required this.releaseEvidenceCount,
    required this.remainingReleaseRiskCount,
    required this.decision,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentInterventionOutcomeDraft(
      interventionId: '',
      checkInId: '',
      activationFollowUpId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      reviewerName: '',
      reviewDate: null,
      source: null,
      interventionType: null,
      priority: null,
      confidenceBefore: 0,
      confidenceAfter: 0,
      releaseEvidenceCount: 0,
      remainingReleaseRiskCount: 0,
      decision: null,
      evidenceSummary: '',
      learningSummary: '',
      nextAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentInterventionOutcomeDraft.fromIntervention({
    required IncomingTalentDevelopmentInterventionAction action,
    required DateTime asOfDate,
  }) {
    final decision =
        defaultIncomingTalentDevelopmentInterventionOutcomeDecision(action);
    final reviewDate = asOfDate;

    return IncomingTalentDevelopmentInterventionOutcomeDraft(
      interventionId: action.id,
      checkInId: action.checkInId,
      activationFollowUpId: action.activationFollowUpId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      role: action.role,
      department: action.department,
      ownerName: action.ownerName,
      reviewerName: action.ownerName,
      reviewDate: reviewDate,
      source: action.source,
      interventionType: action.actionType,
      priority: action.priority,
      confidenceBefore: action.confidenceScore,
      confidenceAfter:
          defaultIncomingTalentDevelopmentInterventionConfidenceAfter(action),
      releaseEvidenceCount: action.releaseEvidenceCount,
      remainingReleaseRiskCount:
          defaultIncomingTalentDevelopmentInterventionRemainingReleaseRisk(
            action,
          ),
      decision: decision,
      evidenceSummary: defaultIncomingTalentDevelopmentInterventionEvidence(
        action,
      ),
      learningSummary: defaultIncomingTalentDevelopmentInterventionLearning(
        action,
      ),
      nextAction: defaultIncomingTalentDevelopmentInterventionNextAction(
        decision,
      ),
      nextReviewDate:
          defaultIncomingTalentDevelopmentInterventionNextReviewDate(
            decision: decision,
            reviewDate: reviewDate,
          ),
      asOfDate: asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          interventionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          decision != null,
          confidenceAfter >= 1 && confidenceAfter <= 5,
          evidenceSummary.trim().length >= 12,
          learningSummary.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(interventionId, 'a resolved intervention')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'an outcome reviewer')
          case final error?)
        error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validateConfidence(confidenceAfter) case final error?) error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateLearningSummary(learningSummary) case final error?) error,
      if (validateNextAction(nextAction) case final error?) error,
      if (validateNextReviewDate(reviewDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentInterventionOutcome toOutcome({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentInterventionOutcome(
      id: id,
      interventionId: interventionId,
      checkInId: checkInId,
      activationFollowUpId: activationFollowUpId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      source: source!,
      interventionType: interventionType!,
      priority: priority!,
      confidenceBefore: confidenceBefore,
      confidenceAfter: confidenceAfter,
      releaseEvidenceCount: releaseEvidenceCount,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      decision: decision!,
      evidenceSummary: evidenceSummary.trim(),
      learningSummary: learningSummary.trim(),
      nextAction: nextAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateDecision(
    IncomingTalentDevelopmentInterventionOutcomeDecision? value,
  ) {
    if (value == null) return 'Select an outcome decision';
    return null;
  }

  static String? validateConfidence(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateLearningSummary(String? value) {
    return _validateLongText(value, 'learning summary');
  }

  static String? validateNextAction(String? value) {
    return _validateLongText(value, 'next action');
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select a next review date';
    if (reviewDate != null &&
        !_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
      return 'Next review must be after review date';
    }
    return null;
  }
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentDevelopmentInterventionOutcomeDraft.validateRequired(
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
