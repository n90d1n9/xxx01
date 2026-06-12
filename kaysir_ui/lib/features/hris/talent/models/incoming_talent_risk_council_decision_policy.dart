import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_queue_item.dart';

IncomingTalentRiskCouncilDecisionOutcome defaultRiskCouncilDecisionOutcome(
  IncomingTalentRiskCouncilQueueItem item,
) {
  if (item.isPromotionResolutionReview) {
    return item.isCritical
        ? IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard
        : IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil;
  }

  if (item.category ==
          IncomingTalentRiskCouncilQueueCategory.resolutionReview &&
      item.isCritical) {
    return IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard;
  }

  return switch (item.category) {
    IncomingTalentRiskCouncilQueueCategory.intervention =>
      IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan,
    IncomingTalentRiskCouncilQueueCategory.followUp =>
      IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan,
    IncomingTalentRiskCouncilQueueCategory.resolutionReview =>
      IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    IncomingTalentRiskCouncilQueueCategory.careerSupport =>
      IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan,
    IncomingTalentRiskCouncilQueueCategory.program =>
      item.isCritical
          ? IncomingTalentRiskCouncilDecisionOutcome.assignOwner
          : IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  };
}

String defaultRiskCouncilDecisionOwnerName(
  IncomingTalentRiskCouncilQueueItem item,
) {
  if (item.isPromotionResolutionReview) {
    return '${item.department} Promotion Stabilization Partner';
  }
  return '${item.department} Talent Partner';
}

DateTime defaultRiskCouncilDecisionFollowUpDate({
  required IncomingTalentRiskCouncilDecisionOutcome outcome,
  required DateTime asOfDate,
}) {
  final days = switch (outcome) {
    IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan => 14,
    IncomingTalentRiskCouncilDecisionOutcome.assignOwner => 14,
    IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil => 30,
    IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard => 7,
    IncomingTalentRiskCouncilDecisionOutcome.closeRisk => 45,
  };
  return asOfDate.add(Duration(days: days));
}

String defaultRiskCouncilCommitmentSummary(
  IncomingTalentRiskCouncilQueueItem item,
  IncomingTalentRiskCouncilDecisionOutcome outcome,
) {
  if (item.isPromotionResolutionReview) {
    return _promotionResolutionCommitmentSummary(item, outcome);
  }

  return switch (outcome) {
    IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan =>
      'Council approved an action plan for ${item.candidateName} and confirmed ${item.department} follow-up ownership.',
    IncomingTalentRiskCouncilDecisionOutcome.assignOwner =>
      'Council assigned accountable ownership for ${item.candidateName} to remove ${item.category.label.toLowerCase()} risk.',
    IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil =>
      'Council agreed to monitor ${item.candidateName} at the next talent risk council.',
    IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard =>
      'Council escalated ${item.candidateName} to people board for leadership decision.',
    IncomingTalentRiskCouncilDecisionOutcome.closeRisk =>
      'Council closed the current ${item.category.label.toLowerCase()} risk for ${item.candidateName}.',
  };
}

String _promotionResolutionCommitmentSummary(
  IncomingTalentRiskCouncilQueueItem item,
  IncomingTalentRiskCouncilDecisionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan =>
      'Council approved a promotion stabilization action plan for ${item.candidateName} and confirmed ${item.department} follow-up ownership.',
    IncomingTalentRiskCouncilDecisionOutcome.assignOwner =>
      'Council assigned accountable ownership for ${item.candidateName} to resolve promotion stabilization risk.',
    IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil =>
      'Council will monitor promotion stabilization risk for ${item.candidateName} at the next talent risk council.',
    IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard =>
      'Council escalated promotion stabilization risk for ${item.candidateName} to people board for role-risk decision.',
    IncomingTalentRiskCouncilDecisionOutcome.closeRisk =>
      'Council closed promotion stabilization risk for ${item.candidateName} after accepting resolution evidence.',
  };
}

String? riskCouncilDecisionLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateRiskCouncilDecisionRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateRiskCouncilDecisionDate(DateTime? value, DateTime asOfDate) {
  if (value == null) return 'Select decision date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Decision date cannot be in the past';
  }
  return null;
}

String? validateRiskCouncilDecisionFollowUpDate(
  DateTime? decisionDate,
  DateTime? followUpDate,
) {
  if (followUpDate == null) return 'Select follow-up date';
  if (decisionDate == null) return null;
  if (!_dateOnly(followUpDate).isAfter(_dateOnly(decisionDate))) {
    return 'Follow-up must be after decision date';
  }
  return null;
}

String? validateRiskCouncilDecisionOutcome(
  IncomingTalentRiskCouncilDecisionOutcome? value,
) {
  if (value == null) return 'Select council decision';
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
