import 'incoming_talent_succession_activation_check_in.dart';
import 'incoming_talent_succession_activation_plan.dart';

class IncomingTalentSuccessionActivationCheckInDraft {
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final DateTime? checkInDate;
  final IncomingTalentSuccessionActivationCheckInTrend? trend;
  final int confidenceScore;
  final String milestoneHealth;
  final String blockerNote;
  final String sponsorAction;
  final String nextStep;
  final DateTime? nextCheckInDate;
  final IncomingTalentSuccessionActivationStatus? activationStatus;
  final DateTime asOfDate;

  const IncomingTalentSuccessionActivationCheckInDraft({
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.checkInDate,
    required this.trend,
    required this.confidenceScore,
    required this.milestoneHealth,
    required this.blockerNote,
    required this.sponsorAction,
    required this.nextStep,
    required this.nextCheckInDate,
    required this.activationStatus,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionActivationCheckInDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionActivationCheckInDraft(
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      reviewerName: '',
      checkInDate: null,
      trend: null,
      confidenceScore: 0,
      milestoneHealth: '',
      blockerNote: '',
      sponsorAction: '',
      nextStep: '',
      nextCheckInDate: null,
      activationStatus: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionActivationCheckInDraft.fromPlan({
    required IncomingTalentSuccessionActivationPlan plan,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionActivationCheckInDraft(
      activationPlanId: plan.id,
      decisionId: plan.decisionId,
      candidateId: plan.candidateId,
      candidateName: plan.candidateName,
      role: plan.role,
      department: plan.department,
      targetRole: plan.targetRole,
      reviewerName: plan.activationOwner,
      checkInDate: asOfDate,
      trend: _trendFromPlan(plan),
      confidenceScore: _confidenceFromPlan(plan),
      milestoneHealth: plan.milestone,
      blockerNote:
          plan.needsAttention
              ? 'Activation risk requires sponsor follow-up and milestone review.'
              : '',
      sponsorAction: plan.supportPlan,
      nextStep:
          'Confirm ${plan.successMetric.toLowerCase()} before the next review.',
      nextCheckInDate: asOfDate.add(const Duration(days: 30)),
      activationStatus: plan.status,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionActivationCheckInDraft copyWith({
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? reviewerName,
    DateTime? checkInDate,
    IncomingTalentSuccessionActivationCheckInTrend? trend,
    int? confidenceScore,
    String? milestoneHealth,
    String? blockerNote,
    String? sponsorAction,
    String? nextStep,
    DateTime? nextCheckInDate,
    IncomingTalentSuccessionActivationStatus? activationStatus,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionActivationCheckInDraft(
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      reviewerName: reviewerName ?? this.reviewerName,
      checkInDate: checkInDate ?? this.checkInDate,
      trend: trend ?? this.trend,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      milestoneHealth: milestoneHealth ?? this.milestoneHealth,
      blockerNote: blockerNote ?? this.blockerNote,
      sponsorAction: sponsorAction ?? this.sponsorAction,
      nextStep: nextStep ?? this.nextStep,
      nextCheckInDate: nextCheckInDate ?? this.nextCheckInDate,
      activationStatus: activationStatus ?? this.activationStatus,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          activationPlanId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          checkInDate != null,
          trend != null,
          validateConfidenceScore(confidenceScore) == null,
          milestoneHealth.trim().length >= 12,
          validateBlockerNote(blockerNote, trend) == null,
          sponsorAction.trim().length >= 12,
          nextStep.trim().length >= 12,
          nextCheckInDate != null,
          activationStatus != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(activationPlanId, 'an activation plan')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateCheckInDate(checkInDate, asOfDate) case final error?) error,
      if (validateTrend(trend) case final error?) error,
      if (validateConfidenceScore(confidenceScore) case final error?) error,
      if (validateMilestoneHealth(milestoneHealth) case final error?) error,
      if (validateBlockerNote(blockerNote, trend) case final error?) error,
      if (validateSponsorAction(sponsorAction) case final error?) error,
      if (validateNextStep(nextStep) case final error?) error,
      if (validateNextCheckInDate(checkInDate, nextCheckInDate)
          case final error?)
        error,
      if (validateActivationStatus(activationStatus) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionActivationCheckIn toCheckIn({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionActivationCheckIn(
      id: id,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      reviewerName: reviewerName.trim(),
      checkInDate: checkInDate!,
      trend: trend!,
      confidenceScore: confidenceScore,
      milestoneHealth: milestoneHealth.trim(),
      blockerNote: blockerNote.trim(),
      sponsorAction: sponsorAction.trim(),
      nextStep: nextStep.trim(),
      nextCheckInDate: nextCheckInDate!,
      activationStatus: activationStatus!,
      createdAt: createdAt,
    );
  }

  static String? validateTrend(
    IncomingTalentSuccessionActivationCheckInTrend? value,
  ) {
    if (value == null) return 'Select check-in trend';
    return null;
  }

  static String? validateActivationStatus(
    IncomingTalentSuccessionActivationStatus? value,
  ) {
    if (value == null) return 'Select activation status';
    return null;
  }

  static String? validateConfidenceScore(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validateCheckInDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select check-in date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Check-in date cannot be in the past';
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

  static String? validateMilestoneHealth(String? value) {
    return _validateLongText(value, 'milestone health');
  }

  static String? validateBlockerNote(
    String? value,
    IncomingTalentSuccessionActivationCheckInTrend? trend,
  ) {
    if (trend != IncomingTalentSuccessionActivationCheckInTrend.watch &&
        trend != IncomingTalentSuccessionActivationCheckInTrend.blocked) {
      return null;
    }
    return _validateLongText(value, 'blocker note');
  }

  static String? validateSponsorAction(String? value) {
    return _validateLongText(value, 'sponsor action');
  }

  static String? validateNextStep(String? value) {
    return _validateLongText(value, 'next step');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionActivationCheckInTrend _trendFromPlan(
  IncomingTalentSuccessionActivationPlan plan,
) {
  if (plan.status == IncomingTalentSuccessionActivationStatus.atRisk) {
    return IncomingTalentSuccessionActivationCheckInTrend.watch;
  }
  if (plan.status == IncomingTalentSuccessionActivationStatus.completed) {
    return IncomingTalentSuccessionActivationCheckInTrend.accelerating;
  }
  return IncomingTalentSuccessionActivationCheckInTrend.onTrack;
}

int _confidenceFromPlan(IncomingTalentSuccessionActivationPlan plan) {
  if (plan.status == IncomingTalentSuccessionActivationStatus.atRisk) return 3;
  if (plan.status == IncomingTalentSuccessionActivationStatus.completed) {
    return 5;
  }
  return 4;
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionActivationCheckInDraft.validateRequired(
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
