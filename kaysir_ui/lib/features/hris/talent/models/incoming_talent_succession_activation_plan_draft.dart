import 'incoming_talent_succession_activation_plan.dart';
import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_panel_decision.dart';

class IncomingTalentSuccessionActivationPlanDraft {
  final String decisionId;
  final String nominationId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String activationOwner;
  final String mentorName;
  final IncomingTalentSuccessionActivationStatus? status;
  final IncomingTalentSuccessionPanelOutcome? outcome;
  final IncomingTalentSuccessionReadiness? readiness;
  final IncomingTalentSuccessionRisk? risk;
  final DateTime? startDate;
  final DateTime? milestoneDate;
  final DateTime? firstReviewDate;
  final String transitionGoal;
  final String milestone;
  final String successMetric;
  final String supportPlan;
  final DateTime asOfDate;

  const IncomingTalentSuccessionActivationPlanDraft({
    required this.decisionId,
    required this.nominationId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.activationOwner,
    required this.mentorName,
    required this.status,
    required this.outcome,
    required this.readiness,
    required this.risk,
    required this.startDate,
    required this.milestoneDate,
    required this.firstReviewDate,
    required this.transitionGoal,
    required this.milestone,
    required this.successMetric,
    required this.supportPlan,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionActivationPlanDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionActivationPlanDraft(
      decisionId: '',
      nominationId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      activationOwner: '',
      mentorName: '',
      status: null,
      outcome: null,
      readiness: null,
      risk: null,
      startDate: null,
      milestoneDate: null,
      firstReviewDate: null,
      transitionGoal: '',
      milestone: '',
      successMetric: '',
      supportPlan: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionActivationPlanDraft.fromDecision({
    required IncomingTalentSuccessionPanelDecision decision,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionActivationPlanDraft(
      decisionId: decision.id,
      nominationId: decision.nominationId,
      candidateId: decision.candidateId,
      candidateName: decision.candidateName,
      role: decision.role,
      department: decision.department,
      targetRole: decision.targetRole,
      activationOwner: decision.followUpOwner,
      mentorName: '${decision.department} transition mentor',
      status: _statusFromDecision(decision),
      outcome: decision.outcome,
      readiness: decision.readiness,
      risk: decision.risk,
      startDate: decision.activationDate,
      milestoneDate: decision.activationDate.add(const Duration(days: 30)),
      firstReviewDate: decision.nextReviewDate,
      transitionGoal:
          'Activate ${decision.candidateName} into ${decision.targetRole.toLowerCase()} with sponsor-backed transition support.',
      milestone:
          'Confirm role scope, stakeholder handoff, and first delivery milestone.',
      successMetric:
          'Complete first ${decision.targetRole.toLowerCase()} success review with panel evidence.',
      supportPlan: decision.sponsorCommitment,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionActivationPlanDraft copyWith({
    String? decisionId,
    String? nominationId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? activationOwner,
    String? mentorName,
    IncomingTalentSuccessionActivationStatus? status,
    IncomingTalentSuccessionPanelOutcome? outcome,
    IncomingTalentSuccessionReadiness? readiness,
    IncomingTalentSuccessionRisk? risk,
    DateTime? startDate,
    DateTime? milestoneDate,
    DateTime? firstReviewDate,
    String? transitionGoal,
    String? milestone,
    String? successMetric,
    String? supportPlan,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionActivationPlanDraft(
      decisionId: decisionId ?? this.decisionId,
      nominationId: nominationId ?? this.nominationId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      activationOwner: activationOwner ?? this.activationOwner,
      mentorName: mentorName ?? this.mentorName,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      startDate: startDate ?? this.startDate,
      milestoneDate: milestoneDate ?? this.milestoneDate,
      firstReviewDate: firstReviewDate ?? this.firstReviewDate,
      transitionGoal: transitionGoal ?? this.transitionGoal,
      milestone: milestone ?? this.milestone,
      successMetric: successMetric ?? this.successMetric,
      supportPlan: supportPlan ?? this.supportPlan,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          decisionId.trim().isNotEmpty,
          activationOwner.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          status != null,
          outcome != null,
          readiness != null,
          risk != null,
          startDate != null,
          milestoneDate != null,
          firstReviewDate != null,
          transitionGoal.trim().length >= 12,
          milestone.trim().length >= 12,
          successMetric.trim().length >= 12,
          supportPlan.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 14;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(decisionId, 'an approved panel decision')
          case final error?)
        error,
      if (validateRequired(activationOwner, 'an activation owner')
          case final error?)
        error,
      if (validateRequired(mentorName, 'a transition mentor') case final error?)
        error,
      if (validateStatus(status) case final error?) error,
      if (validateOutcome(outcome) case final error?) error,
      if (validateReadiness(readiness) case final error?) error,
      if (validateRisk(risk) case final error?) error,
      if (validateStartDate(startDate, asOfDate) case final error?) error,
      if (validateMilestoneDate(startDate, milestoneDate) case final error?)
        error,
      if (validateFirstReviewDate(startDate, firstReviewDate) case final error?)
        error,
      if (validateTransitionGoal(transitionGoal) case final error?) error,
      if (validateMilestone(milestone) case final error?) error,
      if (validateSuccessMetric(successMetric) case final error?) error,
      if (validateSupportPlan(supportPlan) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionActivationPlan toPlan({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionActivationPlan(
      id: id,
      decisionId: decisionId,
      nominationId: nominationId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      activationOwner: activationOwner.trim(),
      mentorName: mentorName.trim(),
      status: status!,
      outcome: outcome!,
      readiness: readiness!,
      risk: risk!,
      startDate: startDate!,
      milestoneDate: milestoneDate!,
      firstReviewDate: firstReviewDate!,
      transitionGoal: transitionGoal.trim(),
      milestone: milestone.trim(),
      successMetric: successMetric.trim(),
      supportPlan: supportPlan.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateStatus(
    IncomingTalentSuccessionActivationStatus? value,
  ) {
    if (value == null) return 'Select activation status';
    return null;
  }

  static String? validateOutcome(IncomingTalentSuccessionPanelOutcome? value) {
    if (value == null) return 'Select panel outcome';
    return null;
  }

  static String? validateReadiness(IncomingTalentSuccessionReadiness? value) {
    if (value == null) return 'Select readiness';
    return null;
  }

  static String? validateRisk(IncomingTalentSuccessionRisk? value) {
    if (value == null) return 'Select risk';
    return null;
  }

  static String? validateStartDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select start date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Start date cannot be in the past';
    }
    return null;
  }

  static String? validateMilestoneDate(
    DateTime? startDate,
    DateTime? milestoneDate,
  ) {
    if (milestoneDate == null) return 'Select milestone date';
    if (startDate == null) return null;
    if (!_dateOnly(milestoneDate).isAfter(_dateOnly(startDate))) {
      return 'Milestone date must be after start date';
    }
    return null;
  }

  static String? validateFirstReviewDate(
    DateTime? startDate,
    DateTime? firstReviewDate,
  ) {
    if (firstReviewDate == null) return 'Select first review date';
    if (startDate == null) return null;
    if (!_dateOnly(firstReviewDate).isAfter(_dateOnly(startDate))) {
      return 'First review must be after start date';
    }
    return null;
  }

  static String? validateTransitionGoal(String? value) {
    return _validateLongText(value, 'transition goal');
  }

  static String? validateMilestone(String? value) {
    return _validateLongText(value, 'milestone');
  }

  static String? validateSuccessMetric(String? value) {
    return _validateLongText(value, 'success metric');
  }

  static String? validateSupportPlan(String? value) {
    return _validateLongText(value, 'support plan');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionActivationStatus _statusFromDecision(
  IncomingTalentSuccessionPanelDecision decision,
) {
  if (decision.outcome ==
          IncomingTalentSuccessionPanelOutcome.conditionalApproval ||
      decision.risk != IncomingTalentSuccessionRisk.low) {
    return IncomingTalentSuccessionActivationStatus.atRisk;
  }
  return IncomingTalentSuccessionActivationStatus.planned;
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionActivationPlanDraft.validateRequired(
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
