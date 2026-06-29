import 'incoming_talent_activation_checkpoint_models.dart';
import 'incoming_talent_activation_follow_up_models.dart';
import 'incoming_talent_activation_models.dart';
import 'incoming_talent_activation_outcome.dart';
import 'incoming_talent_activation_outcome_defaults.dart';

class IncomingTalentActivationOutcomeDraft {
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentActivationOutcomeDecision? decision;
  final IncomingTalentActivationRetentionRisk? retentionRisk;
  final int readinessScore;
  final String nextDevelopmentTrack;
  final String evidenceNote;
  final String decisionNote;
  final DateTime asOfDate;

  const IncomingTalentActivationOutcomeDraft({
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.retentionRisk,
    required this.readinessScore,
    required this.nextDevelopmentTrack,
    required this.evidenceNote,
    required this.decisionNote,
    required this.asOfDate,
  });

  factory IncomingTalentActivationOutcomeDraft.empty(DateTime asOfDate) {
    return IncomingTalentActivationOutcomeDraft(
      activationPlanId: '',
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      reviewerName: '',
      reviewDate: null,
      decision: null,
      retentionRisk: null,
      readinessScore: 0,
      nextDevelopmentTrack: '',
      evidenceNote: '',
      decisionNote: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentActivationOutcomeDraft.fromPlan({
    required IncomingTalentActivationPlan plan,
    required List<IncomingTalentActivationCheckpoint> checkpoints,
    required List<IncomingTalentActivationFollowUpAction> followUps,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentActivationOutcomeDefaults.fromEvidence(
      plan: plan,
      checkpoints: checkpoints,
      followUps: followUps,
    );

    return IncomingTalentActivationOutcomeDraft(
      activationPlanId: plan.id,
      handoffId: plan.handoffId,
      candidateId: plan.candidateId,
      candidateName: plan.candidateName,
      role: plan.role,
      department: plan.department,
      reviewerName: plan.managerName,
      reviewDate: asOfDate,
      decision: defaults.decision,
      retentionRisk: defaults.retentionRisk,
      readinessScore: defaults.readinessScore,
      nextDevelopmentTrack: defaults.nextDevelopmentTrack,
      evidenceNote: defaults.evidenceNote,
      decisionNote: defaults.decisionNote,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentActivationOutcomeDraft copyWith({
    String? activationPlanId,
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentActivationOutcomeDecision? decision,
    IncomingTalentActivationRetentionRisk? retentionRisk,
    int? readinessScore,
    String? nextDevelopmentTrack,
    String? evidenceNote,
    String? decisionNote,
    DateTime? asOfDate,
  }) {
    return IncomingTalentActivationOutcomeDraft(
      activationPlanId: activationPlanId ?? this.activationPlanId,
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      readinessScore: readinessScore ?? this.readinessScore,
      nextDevelopmentTrack: nextDevelopmentTrack ?? this.nextDevelopmentTrack,
      evidenceNote: evidenceNote ?? this.evidenceNote,
      decisionNote: decisionNote ?? this.decisionNote,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          activationPlanId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          decision != null,
          retentionRisk != null,
          readinessScore >= 1 && readinessScore <= 100,
          nextDevelopmentTrack.trim().length >= 8,
          evidenceNote.trim().length >= 12,
          decisionNote.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(activationPlanId, 'an activation plan')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validateRetentionRisk(retentionRisk) case final error?) error,
      if (validateReadinessScore(readinessScore) case final error?) error,
      if (validateNextDevelopmentTrack(nextDevelopmentTrack) case final error?)
        error,
      if (validateEvidenceNote(evidenceNote) case final error?) error,
      if (validateDecisionNote(decisionNote) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentActivationOutcomeReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentActivationOutcomeReview(
      id: id,
      activationPlanId: activationPlanId,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      retentionRisk: retentionRisk!,
      readinessScore: readinessScore,
      nextDevelopmentTrack: nextDevelopmentTrack.trim(),
      evidenceNote: evidenceNote.trim(),
      decisionNote: decisionNote.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateDecision(
    IncomingTalentActivationOutcomeDecision? value,
  ) {
    if (value == null) return 'Select an outcome decision';
    return null;
  }

  static String? validateRetentionRisk(
    IncomingTalentActivationRetentionRisk? value,
  ) {
    if (value == null) return 'Select retention risk';
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateReadinessScore(int value) {
    if (value < 1 || value > 100) {
      return 'Readiness score must be between 1 and 100';
    }
    return null;
  }

  static String? validateNextDevelopmentTrack(String? value) {
    final requiredError = validateRequired(value, 'a development track');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 8) {
      return 'Development track must be at least 8 characters';
    }
    return null;
  }

  static String? validateEvidenceNote(String? value) {
    final requiredError = validateRequired(value, 'evidence notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Evidence notes must be at least 12 characters';
    }
    return null;
  }

  static String? validateDecisionNote(String? value) {
    final requiredError = validateRequired(value, 'decision notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Decision notes must be at least 12 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
