import 'incoming_talent_succession_activation_escalation.dart';
import 'incoming_talent_succession_activation_resolution_review.dart';

class IncomingTalentSuccessionActivationResolutionReviewDraft {
  final String escalationId;
  final String checkInId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final IncomingTalentSuccessionActivationEscalationPriority?
  escalationPriority;
  final IncomingTalentSuccessionActivationEscalationStatus? escalationStatus;
  final DateTime? resolutionDate;
  final IncomingTalentSuccessionActivationResolutionOutcome? outcome;
  final IncomingTalentSuccessionActivationResidualRisk? residualRisk;
  final int finalConfidenceScore;
  final String evidenceSummary;
  final String sponsorConfirmation;
  final String nextGovernanceStep;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionActivationResolutionReviewDraft({
    required this.escalationId,
    required this.checkInId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.escalationPriority,
    required this.escalationStatus,
    required this.resolutionDate,
    required this.outcome,
    required this.residualRisk,
    required this.finalConfidenceScore,
    required this.evidenceSummary,
    required this.sponsorConfirmation,
    required this.nextGovernanceStep,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionActivationResolutionReviewDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionActivationResolutionReviewDraft(
      escalationId: '',
      checkInId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      reviewerName: '',
      escalationPriority: null,
      escalationStatus: null,
      resolutionDate: null,
      outcome: null,
      residualRisk: null,
      finalConfidenceScore: 0,
      evidenceSummary: '',
      sponsorConfirmation: '',
      nextGovernanceStep: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionActivationResolutionReviewDraft.fromEscalation({
    required IncomingTalentSuccessionActivationEscalation escalation,
    required DateTime asOfDate,
  }) {
    final outcome = _defaultOutcome(escalation);
    final residualRisk = _defaultResidualRisk(escalation);

    return IncomingTalentSuccessionActivationResolutionReviewDraft(
      escalationId: escalation.id,
      checkInId: escalation.checkInId,
      activationPlanId: escalation.activationPlanId,
      decisionId: escalation.decisionId,
      candidateId: escalation.candidateId,
      candidateName: escalation.candidateName,
      role: escalation.role,
      department: escalation.department,
      targetRole: escalation.targetRole,
      reviewerName: escalation.ownerName,
      escalationPriority: escalation.priority,
      escalationStatus: escalation.status,
      resolutionDate: asOfDate,
      outcome: outcome,
      residualRisk: residualRisk,
      finalConfidenceScore: _defaultConfidence(escalation, outcome),
      evidenceSummary:
          'Resolution evidence confirms ${escalation.successCriteria.toLowerCase()}',
      sponsorConfirmation: escalation.sponsorCommitment,
      nextGovernanceStep: _defaultNextStep(outcome, escalation),
      nextReviewDate: asOfDate.add(const Duration(days: 30)),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionActivationResolutionReviewDraft copyWith({
    String? escalationId,
    String? checkInId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? reviewerName,
    IncomingTalentSuccessionActivationEscalationPriority? escalationPriority,
    IncomingTalentSuccessionActivationEscalationStatus? escalationStatus,
    DateTime? resolutionDate,
    IncomingTalentSuccessionActivationResolutionOutcome? outcome,
    IncomingTalentSuccessionActivationResidualRisk? residualRisk,
    int? finalConfidenceScore,
    String? evidenceSummary,
    String? sponsorConfirmation,
    String? nextGovernanceStep,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionActivationResolutionReviewDraft(
      escalationId: escalationId ?? this.escalationId,
      checkInId: checkInId ?? this.checkInId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      reviewerName: reviewerName ?? this.reviewerName,
      escalationPriority: escalationPriority ?? this.escalationPriority,
      escalationStatus: escalationStatus ?? this.escalationStatus,
      resolutionDate: resolutionDate ?? this.resolutionDate,
      outcome: outcome ?? this.outcome,
      residualRisk: residualRisk ?? this.residualRisk,
      finalConfidenceScore: finalConfidenceScore ?? this.finalConfidenceScore,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      sponsorConfirmation: sponsorConfirmation ?? this.sponsorConfirmation,
      nextGovernanceStep: nextGovernanceStep ?? this.nextGovernanceStep,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          escalationId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          escalationStatus ==
              IncomingTalentSuccessionActivationEscalationStatus.resolved,
          resolutionDate != null,
          outcome != null,
          residualRisk != null,
          validateFinalConfidenceScore(finalConfidenceScore) == null,
          evidenceSummary.trim().length >= 12,
          sponsorConfirmation.trim().length >= 12,
          nextGovernanceStep.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(escalationId, 'a resolved escalation')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateEscalationStatus(escalationStatus) case final error?) error,
      if (validateResolutionDate(resolutionDate, asOfDate) case final error?)
        error,
      if (validateOutcome(outcome) case final error?) error,
      if (validateResidualRisk(residualRisk) case final error?) error,
      if (validateFinalConfidenceScore(finalConfidenceScore) case final error?)
        error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateSponsorConfirmation(sponsorConfirmation) case final error?)
        error,
      if (validateNextGovernanceStep(nextGovernanceStep) case final error?)
        error,
      if (validateNextReviewDate(resolutionDate, nextReviewDate)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionActivationResolutionReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionActivationResolutionReview(
      id: id,
      escalationId: escalationId,
      checkInId: checkInId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      reviewerName: reviewerName.trim(),
      escalationPriority: escalationPriority!,
      resolutionDate: resolutionDate!,
      outcome: outcome!,
      residualRisk: residualRisk!,
      finalConfidenceScore: finalConfidenceScore,
      evidenceSummary: evidenceSummary.trim(),
      sponsorConfirmation: sponsorConfirmation.trim(),
      nextGovernanceStep: nextGovernanceStep.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateEscalationStatus(
    IncomingTalentSuccessionActivationEscalationStatus? value,
  ) {
    if (value == null) return 'Select a resolved escalation';
    if (value != IncomingTalentSuccessionActivationEscalationStatus.resolved) {
      return 'Escalation must be resolved before review';
    }
    return null;
  }

  static String? validateResolutionDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select resolution date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Resolution date cannot be in the past';
    }
    return null;
  }

  static String? validateOutcome(
    IncomingTalentSuccessionActivationResolutionOutcome? value,
  ) {
    if (value == null) return 'Select resolution outcome';
    return null;
  }

  static String? validateResidualRisk(
    IncomingTalentSuccessionActivationResidualRisk? value,
  ) {
    if (value == null) return 'Select residual risk';
    return null;
  }

  static String? validateFinalConfidenceScore(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? resolutionDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select next review date';
    if (resolutionDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(resolutionDate))) {
      return 'Next review must be after resolution date';
    }
    return null;
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateSponsorConfirmation(String? value) {
    return _validateLongText(value, 'sponsor confirmation');
  }

  static String? validateNextGovernanceStep(String? value) {
    return _validateLongText(value, 'next governance step');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionActivationResolutionOutcome _defaultOutcome(
  IncomingTalentSuccessionActivationEscalation escalation,
) {
  if (escalation.priority ==
          IncomingTalentSuccessionActivationEscalationPriority.executive ||
      escalation.confidenceScore <= 2) {
    return IncomingTalentSuccessionActivationResolutionOutcome.monitor;
  }
  return IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared;
}

IncomingTalentSuccessionActivationResidualRisk _defaultResidualRisk(
  IncomingTalentSuccessionActivationEscalation escalation,
) {
  if (escalation.priority ==
      IncomingTalentSuccessionActivationEscalationPriority.executive) {
    return IncomingTalentSuccessionActivationResidualRisk.medium;
  }
  if (escalation.confidenceScore <= 2) {
    return IncomingTalentSuccessionActivationResidualRisk.high;
  }
  return IncomingTalentSuccessionActivationResidualRisk.low;
}

int _defaultConfidence(
  IncomingTalentSuccessionActivationEscalation escalation,
  IncomingTalentSuccessionActivationResolutionOutcome outcome,
) {
  if (outcome ==
      IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared) {
    return 4;
  }
  return escalation.confidenceScore < 3 ? 3 : escalation.confidenceScore;
}

String _defaultNextStep(
  IncomingTalentSuccessionActivationResolutionOutcome outcome,
  IncomingTalentSuccessionActivationEscalation escalation,
) {
  return switch (outcome) {
    IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared =>
      'Continue transition governance through the next activation check-in.',
    IncomingTalentSuccessionActivationResolutionOutcome.monitor =>
      'Monitor ${escalation.targetRole.toLowerCase()} transition evidence with sponsor.',
    IncomingTalentSuccessionActivationResolutionOutcome.reopenEscalation =>
      'Reopen escalation and assign sponsor decision follow-up.',
    IncomingTalentSuccessionActivationResolutionOutcome.panelReview =>
      'Route residual transition risk to succession panel review.',
  };
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionActivationResolutionReviewDraft.validateRequired(
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
