import 'incoming_talent_succession_coverage_council_decision.dart';
import 'incoming_talent_succession_coverage_council_follow_up.dart';

IncomingTalentSuccessionCoverageCouncilFollowUpType
defaultCoverageCouncilFollowUpType(
  IncomingTalentSuccessionCoverageCouncilDecision decision,
) {
  return switch (decision.outcome) {
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .approveRecoveryPlan =>
      IncomingTalentSuccessionCoverageCouncilFollowUpType.recoveryCheckpoint,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .assignExecutiveSponsor =>
      IncomingTalentSuccessionCoverageCouncilFollowUpType.sponsorCommitment,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure =>
      IncomingTalentSuccessionCoverageCouncilFollowUpType.closureEvidence,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil =>
      IncomingTalentSuccessionCoverageCouncilFollowUpType.councilRefresh,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .escalateToPeopleBoard =>
      IncomingTalentSuccessionCoverageCouncilFollowUpType.peopleBoardEscalation,
  };
}

DateTime defaultCoverageCouncilFollowUpDueDate({
  required IncomingTalentSuccessionCoverageCouncilDecision decision,
  required DateTime asOfDate,
}) {
  if (_dateOnly(decision.followUpDate).isBefore(_dateOnly(asOfDate))) {
    return asOfDate;
  }
  return decision.followUpDate;
}

String defaultCoverageCouncilFollowUpActionPlan(
  IncomingTalentSuccessionCoverageCouncilDecision decision,
  IncomingTalentSuccessionCoverageCouncilFollowUpType followUpType,
) {
  return switch (followUpType) {
    IncomingTalentSuccessionCoverageCouncilFollowUpType.sponsorCommitment =>
      'Secure sponsor commitment for ${decision.scopeLabel} and confirm owner capacity.',
    IncomingTalentSuccessionCoverageCouncilFollowUpType.recoveryCheckpoint =>
      'Review recovery milestones for ${decision.scopeLabel} and remove execution blockers.',
    IncomingTalentSuccessionCoverageCouncilFollowUpType.closureEvidence =>
      'Collect closure evidence for ${decision.scopeLabel} and prepare validation notes.',
    IncomingTalentSuccessionCoverageCouncilFollowUpType.councilRefresh =>
      'Prepare refreshed council evidence for ${decision.scopeLabel} before the next session.',
    IncomingTalentSuccessionCoverageCouncilFollowUpType.peopleBoardEscalation =>
      'Package ${decision.scopeLabel} escalation with decision notes and leadership asks.',
  };
}

String defaultCoverageCouncilFollowUpSuccessCriteria(
  IncomingTalentSuccessionCoverageCouncilDecision decision,
) {
  return 'Decision follow-up is closed with accountable owner, evidence, and next council signal confirmed.';
}

String? validateCoverageCouncilFollowUpRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateCoverageCouncilFollowUpType(
  IncomingTalentSuccessionCoverageCouncilFollowUpType? value,
) {
  if (value == null) return 'Select follow-up type';
  return null;
}

String? validateCoverageCouncilFollowUpDueDate({
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

String? coverageCouncilFollowUpLongTextError(String? value, String label) {
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
