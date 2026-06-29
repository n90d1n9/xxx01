import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';

IncomingTalentRiskCouncilFollowUpType defaultRiskCouncilFollowUpType(
  IncomingTalentRiskCouncilDecision decision,
) {
  return switch (decision.outcome) {
    IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan =>
      IncomingTalentRiskCouncilFollowUpType.actionCheckpoint,
    IncomingTalentRiskCouncilDecisionOutcome.assignOwner =>
      IncomingTalentRiskCouncilFollowUpType.ownerCommitment,
    IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil =>
      IncomingTalentRiskCouncilFollowUpType.monitoringReview,
    IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard =>
      IncomingTalentRiskCouncilFollowUpType.peopleBoardEscalation,
    IncomingTalentRiskCouncilDecisionOutcome.closeRisk =>
      IncomingTalentRiskCouncilFollowUpType.closureEvidence,
  };
}

DateTime defaultRiskCouncilFollowUpDueDate({
  required IncomingTalentRiskCouncilDecision decision,
  required DateTime asOfDate,
}) {
  if (_dateOnly(decision.followUpDate).isBefore(_dateOnly(asOfDate))) {
    return asOfDate;
  }
  return decision.followUpDate;
}

String defaultRiskCouncilFollowUpActionPlan(
  IncomingTalentRiskCouncilDecision decision,
  IncomingTalentRiskCouncilFollowUpType followUpType,
) {
  if (decision.isPromotionResolutionReview) {
    return _promotionResolutionActionPlan(decision, followUpType);
  }

  return switch (followUpType) {
    IncomingTalentRiskCouncilFollowUpType.ownerCommitment =>
      'Confirm ${decision.ownerName} has capacity, first action, and reporting cadence for ${decision.candidateName}.',
    IncomingTalentRiskCouncilFollowUpType.actionCheckpoint =>
      'Review action progress for ${decision.candidateName} and remove execution blockers before the due date.',
    IncomingTalentRiskCouncilFollowUpType.monitoringReview =>
      'Prepare refreshed talent risk evidence for ${decision.candidateName} before the next council.',
    IncomingTalentRiskCouncilFollowUpType.peopleBoardEscalation =>
      'Package ${decision.candidateName} escalation with decision notes, risk evidence, and leadership asks.',
    IncomingTalentRiskCouncilFollowUpType.closureEvidence =>
      'Collect closure evidence for ${decision.candidateName} and record the final talent risk signal.',
  };
}

String defaultRiskCouncilFollowUpSuccessCriteria(
  IncomingTalentRiskCouncilDecision decision,
) {
  if (decision.isPromotionResolutionReview) {
    return 'Promotion resolution follow-up is closed with role-risk evidence, manager checkpoint, and council disposition recorded.';
  }

  return 'Risk follow-up is closed with owner evidence, candidate signal, and next council disposition recorded.';
}

String _promotionResolutionActionPlan(
  IncomingTalentRiskCouncilDecision decision,
  IncomingTalentRiskCouncilFollowUpType followUpType,
) {
  return switch (followUpType) {
    IncomingTalentRiskCouncilFollowUpType.ownerCommitment =>
      'Confirm ${decision.ownerName} owns promotion stabilization actions, evidence cadence, and next council checkpoint for ${decision.candidateName}.',
    IncomingTalentRiskCouncilFollowUpType.actionCheckpoint =>
      'Review promotion stabilization action progress for ${decision.candidateName} and remove role-risk blockers before the due date.',
    IncomingTalentRiskCouncilFollowUpType.monitoringReview =>
      'Review promotion stabilization evidence for ${decision.candidateName}, confirm residual role risk, and decide whether to reopen follow-up or close monitoring.',
    IncomingTalentRiskCouncilFollowUpType.peopleBoardEscalation =>
      'Package promotion stabilization escalation for ${decision.candidateName} with role-risk evidence, manager checkpoint, and people-board decision ask.',
    IncomingTalentRiskCouncilFollowUpType.closureEvidence =>
      'Collect final promotion resolution evidence for ${decision.candidateName} and record stabilized role outcome.',
  };
}

String? validateRiskCouncilFollowUpRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateRiskCouncilFollowUpType(
  IncomingTalentRiskCouncilFollowUpType? value,
) {
  if (value == null) return 'Select follow-up type';
  return null;
}

String? validateRiskCouncilFollowUpDueDate({
  required DateTime? dueDate,
  required DateTime decisionDate,
  required DateTime asOfDate,
}) {
  if (dueDate == null) return 'Select due date';
  if (_dateOnly(dueDate).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
  }
  if (_dateOnly(dueDate).isBefore(_dateOnly(decisionDate))) {
    return 'Due date cannot be before decision date';
  }
  return null;
}

String? riskCouncilFollowUpLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
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
