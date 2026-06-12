import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_council_decision.dart';

IncomingTalentSuccessionCoverageCouncilDecisionOutcome
defaultCoverageCouncilDecisionOutcome(
  IncomingTalentSuccessionCoverageCouncilAgendaItem item,
) {
  if (item.priority ==
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent) {
    return IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .assignExecutiveSponsor;
  }
  return switch (item.lane) {
    IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision =>
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .assignExecutiveSponsor,
    IncomingTalentSuccessionCoverageCouncilAgendaLane.coverageRecovery =>
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .approveRecoveryPlan,
    IncomingTalentSuccessionCoverageCouncilAgendaLane.actionFollowUp =>
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .approveRecoveryPlan,
    IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation =>
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure,
    IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring =>
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil,
  };
}

DateTime defaultCoverageCouncilDecisionFollowUpDate({
  required IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
  required DateTime asOfDate,
}) {
  final days = switch (outcome) {
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .approveRecoveryPlan =>
      14,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .assignExecutiveSponsor =>
      7,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure =>
      30,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil =>
      14,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .escalateToPeopleBoard =>
      7,
  };
  return asOfDate.add(Duration(days: days));
}

String defaultCoverageCouncilCommitmentSummary(
  IncomingTalentSuccessionCoverageCouncilAgendaItem item,
  IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .approveRecoveryPlan =>
      'Council approved the recovery path for ${item.scopeLabel} and confirmed owner follow-up.',
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .assignExecutiveSponsor =>
      'Council assigned executive sponsorship for ${item.scopeLabel} coverage risk.',
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure =>
      'Council validated coverage evidence and agreed closure criteria for ${item.scopeLabel}.',
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil =>
      'Council deferred ${item.scopeLabel} until additional evidence is ready.',
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .escalateToPeopleBoard =>
      'Council escalated ${item.scopeLabel} coverage risk to people leadership.',
  };
}

String? coverageCouncilDecisionLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateCoverageCouncilDecisionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateCoverageCouncilDecisionDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select decision date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Decision date cannot be in the past';
  }
  return null;
}

String? validateCoverageCouncilDecisionFollowUpDate(
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

String? validateCoverageCouncilDecisionOutcome(
  IncomingTalentSuccessionCoverageCouncilDecisionOutcome? value,
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
