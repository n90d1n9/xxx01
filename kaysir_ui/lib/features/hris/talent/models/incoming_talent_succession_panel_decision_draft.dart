import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';
import 'incoming_talent_succession_panel_decision.dart';

class IncomingTalentSuccessionPanelDecisionDraft {
  final String nominationId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String panelLeadName;
  final String followUpOwner;
  final IncomingTalentSuccessionNominationType? nominationType;
  final IncomingTalentSuccessionReadiness? readiness;
  final IncomingTalentSuccessionRisk? risk;
  final IncomingTalentSuccessionPanelOutcome? outcome;
  final DateTime? decisionDate;
  final DateTime? activationDate;
  final DateTime? nextReviewDate;
  final String decisionSummary;
  final String conditions;
  final String sponsorCommitment;
  final DateTime asOfDate;

  const IncomingTalentSuccessionPanelDecisionDraft({
    required this.nominationId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.panelLeadName,
    required this.followUpOwner,
    required this.nominationType,
    required this.readiness,
    required this.risk,
    required this.outcome,
    required this.decisionDate,
    required this.activationDate,
    required this.nextReviewDate,
    required this.decisionSummary,
    required this.conditions,
    required this.sponsorCommitment,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionPanelDecisionDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionPanelDecisionDraft(
      nominationId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      panelLeadName: '',
      followUpOwner: '',
      nominationType: null,
      readiness: null,
      risk: null,
      outcome: null,
      decisionDate: null,
      activationDate: null,
      nextReviewDate: null,
      decisionSummary: '',
      conditions: '',
      sponsorCommitment: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionPanelDecisionDraft.fromNomination({
    required IncomingTalentSuccessionNomination nomination,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionPanelDecisionDraft(
      nominationId: nomination.id,
      candidateId: nomination.candidateId,
      candidateName: nomination.candidateName,
      role: nomination.role,
      department: nomination.department,
      targetRole: nomination.targetRole,
      panelLeadName: nomination.panelName,
      followUpOwner: nomination.sponsorName,
      nominationType: nomination.nominationType,
      readiness: nomination.readiness,
      risk: nomination.risk,
      outcome: _defaultOutcome(nomination),
      decisionDate: asOfDate,
      activationDate: asOfDate.add(const Duration(days: 30)),
      nextReviewDate: asOfDate.add(const Duration(days: 90)),
      decisionSummary:
          'Panel reviewed ${nomination.candidateName} for ${nomination.targetRole.toLowerCase()} and aligned the outcome to current succession evidence.',
      conditions: _defaultConditions(nomination),
      sponsorCommitment: nomination.successPlan,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionPanelDecisionDraft copyWith({
    String? nominationId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? panelLeadName,
    String? followUpOwner,
    IncomingTalentSuccessionNominationType? nominationType,
    IncomingTalentSuccessionReadiness? readiness,
    IncomingTalentSuccessionRisk? risk,
    IncomingTalentSuccessionPanelOutcome? outcome,
    DateTime? decisionDate,
    DateTime? activationDate,
    DateTime? nextReviewDate,
    String? decisionSummary,
    String? conditions,
    String? sponsorCommitment,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionPanelDecisionDraft(
      nominationId: nominationId ?? this.nominationId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      panelLeadName: panelLeadName ?? this.panelLeadName,
      followUpOwner: followUpOwner ?? this.followUpOwner,
      nominationType: nominationType ?? this.nominationType,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      outcome: outcome ?? this.outcome,
      decisionDate: decisionDate ?? this.decisionDate,
      activationDate: activationDate ?? this.activationDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      decisionSummary: decisionSummary ?? this.decisionSummary,
      conditions: conditions ?? this.conditions,
      sponsorCommitment: sponsorCommitment ?? this.sponsorCommitment,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          nominationId.trim().isNotEmpty,
          panelLeadName.trim().isNotEmpty,
          followUpOwner.trim().isNotEmpty,
          nominationType != null,
          readiness != null,
          risk != null,
          outcome != null,
          decisionDate != null,
          activationDate != null,
          nextReviewDate != null,
          decisionSummary.trim().length >= 12,
          validateConditions(conditions, outcome) == null,
          sponsorCommitment.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 13;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(nominationId, 'a succession nomination')
          case final error?)
        error,
      if (validateRequired(panelLeadName, 'a panel lead') case final error?)
        error,
      if (validateRequired(followUpOwner, 'a follow-up owner')
          case final error?)
        error,
      if (validateNominationType(nominationType) case final error?) error,
      if (validateReadiness(readiness) case final error?) error,
      if (validateRisk(risk) case final error?) error,
      if (validateOutcome(outcome) case final error?) error,
      if (validateDecisionDate(decisionDate, asOfDate) case final error?) error,
      if (validateActivationDate(decisionDate, activationDate)
          case final error?)
        error,
      if (validateNextReviewDate(decisionDate, nextReviewDate)
          case final error?)
        error,
      if (validateDecisionSummary(decisionSummary) case final error?) error,
      if (validateConditions(conditions, outcome) case final error?) error,
      if (validateSponsorCommitment(sponsorCommitment) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionPanelDecision toDecision({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionPanelDecision(
      id: id,
      nominationId: nominationId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      panelLeadName: panelLeadName.trim(),
      followUpOwner: followUpOwner.trim(),
      nominationType: nominationType!,
      readiness: readiness!,
      risk: risk!,
      outcome: outcome!,
      decisionDate: decisionDate!,
      activationDate: activationDate!,
      nextReviewDate: nextReviewDate!,
      decisionSummary: decisionSummary.trim(),
      conditions: conditions.trim(),
      sponsorCommitment: sponsorCommitment.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateNominationType(
    IncomingTalentSuccessionNominationType? value,
  ) {
    if (value == null) return 'Select nomination type';
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

  static String? validateOutcome(IncomingTalentSuccessionPanelOutcome? value) {
    if (value == null) return 'Select panel outcome';
    return null;
  }

  static String? validateDecisionDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select decision date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Decision date cannot be in the past';
    }
    return null;
  }

  static String? validateActivationDate(
    DateTime? decisionDate,
    DateTime? activationDate,
  ) {
    if (activationDate == null) return 'Select activation date';
    if (decisionDate == null) return null;
    if (_dateOnly(activationDate).isBefore(_dateOnly(decisionDate))) {
      return 'Activation date cannot be before decision date';
    }
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? decisionDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select next review date';
    if (decisionDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(decisionDate))) {
      return 'Next review must be after decision date';
    }
    return null;
  }

  static String? validateDecisionSummary(String? value) {
    return _validateLongText(value, 'decision summary');
  }

  static String? validateConditions(
    String? value,
    IncomingTalentSuccessionPanelOutcome? outcome,
  ) {
    if (outcome != IncomingTalentSuccessionPanelOutcome.conditionalApproval &&
        outcome != IncomingTalentSuccessionPanelOutcome.defer) {
      return null;
    }
    return _validateLongText(value, 'conditions');
  }

  static String? validateSponsorCommitment(String? value) {
    return _validateLongText(value, 'sponsor commitment');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionPanelOutcome _defaultOutcome(
  IncomingTalentSuccessionNomination nomination,
) {
  if (nomination.risk == IncomingTalentSuccessionRisk.high ||
      nomination.status == IncomingTalentSuccessionNominationStatus.deferred) {
    return IncomingTalentSuccessionPanelOutcome.defer;
  }
  if (nomination.nominationType ==
      IncomingTalentSuccessionNominationType.promotion) {
    return IncomingTalentSuccessionPanelOutcome.approvePromotion;
  }
  return IncomingTalentSuccessionPanelOutcome.approveSuccessionBench;
}

String _defaultConditions(IncomingTalentSuccessionNomination nomination) {
  if (nomination.risk != IncomingTalentSuccessionRisk.low) {
    return 'Confirm sponsor follow-up before activating ${nomination.targetRole.toLowerCase()}.';
  }
  return 'No blocking conditions; confirm sponsor and activation readiness.';
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionPanelDecisionDraft.validateRequired(value, label);
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
