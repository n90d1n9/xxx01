import 'incoming_talent_risk_council_commitment_action.dart';
import 'incoming_talent_risk_council_commitment_log_item.dart';

IncomingTalentRiskCouncilCommitmentActionStatus
defaultRiskCouncilCommitmentActionStatus(
  IncomingTalentRiskCouncilCommitmentLogItem commitment,
) {
  return switch (commitment.status) {
    IncomingTalentRiskCouncilCommitmentLogStatus.blocked =>
      IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
    IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence =>
      IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
    _ => IncomingTalentRiskCouncilCommitmentActionStatus.planned,
  };
}

DateTime defaultRiskCouncilCommitmentActionDueDate({
  required IncomingTalentRiskCouncilCommitmentLogItem commitment,
  required DateTime asOfDate,
}) {
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(
    commitment.dueDate.year,
    commitment.dueDate.month,
    commitment.dueDate.day,
  );
  if (due.isBefore(start)) return start;
  return commitment.dueDate;
}

String defaultRiskCouncilCommitmentActionCadence(
  IncomingTalentRiskCouncilCommitmentLogType type,
) {
  return switch (type) {
    IncomingTalentRiskCouncilCommitmentLogType.leadershipDecision =>
      'Daily until unblock decision is confirmed',
    IncomingTalentRiskCouncilCommitmentLogType.recoveryAction =>
      'Daily until recovery evidence is accepted',
    IncomingTalentRiskCouncilCommitmentLogType.decisionRecord =>
      'Within 48 hours of council decision',
    IncomingTalentRiskCouncilCommitmentLogType.followUpPlan =>
      'Weekly until follow-up plan is active',
    IncomingTalentRiskCouncilCommitmentLogType.ownerUpdate =>
      'Every two business days until due date',
    IncomingTalentRiskCouncilCommitmentLogType.executionEvidence =>
      'Weekly until execution evidence is accepted',
    IncomingTalentRiskCouncilCommitmentLogType.publishCloseout =>
      'Before the next council closeout',
    IncomingTalentRiskCouncilCommitmentLogType.clear =>
      'Confirm during next scheduled council review',
  };
}

String? validateRiskCouncilCommitmentActionRequired(
  String? value,
  String label,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Select $label';
  }
  return null;
}

String? validateRiskCouncilCommitmentActionDueDate({
  required DateTime? dueDate,
  required DateTime asOfDate,
}) {
  if (dueDate == null) return 'Select due date';
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  if (due.isBefore(start)) return 'Due date cannot be before today';
  return null;
}

String? riskCouncilCommitmentActionLongTextError(String? value, String label) {
  final text = value?.trim() ?? '';
  if (text.length < 12) {
    return 'Enter $label with at least 12 characters';
  }
  return null;
}
