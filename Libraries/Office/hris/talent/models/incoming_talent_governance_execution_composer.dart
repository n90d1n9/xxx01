import 'incoming_talent_governance_decision_ledger_item.dart';
import 'incoming_talent_governance_execution_track.dart';

/// Builds execution follow-through tracks from the talent governance ledger.
List<IncomingTalentGovernanceExecutionTrack>
buildIncomingTalentGovernanceExecutionTracks({
  required List<IncomingTalentGovernanceDecisionLedgerItem> ledgerItems,
  required DateTime asOfDate,
}) {
  final tracks =
      ledgerItems
          .map((item) => _trackFromLedgerItem(item: item, asOfDate: asOfDate))
          .toList()
        ..sort(_compareTracks);

  return tracks;
}

IncomingTalentGovernanceExecutionTrack _trackFromLedgerItem({
  required IncomingTalentGovernanceDecisionLedgerItem item,
  required DateTime asOfDate,
}) {
  final status = _executionStatusFor(item.status);
  final overdue = _isOverdue(
    status: status,
    dueDate: item.dueDate,
    asOfDate: asOfDate,
  );

  return IncomingTalentGovernanceExecutionTrack(
    id: 'talent-governance-execution:${item.id}',
    ledgerItemId: item.id,
    status: status,
    title: _executionTitle(item),
    actionPlan: _actionPlanFor(item: item, status: status),
    evidenceExpectation: item.evidenceExpectation,
    blockerNote: _blockerNoteFor(status),
    ownerName: item.ownerName,
    dueDate: item.dueDate,
    progressRatio: _progressRatioFor(status),
    signalCount: item.signalCount,
    decisionCount: item.decisionCount,
    readinessTaskCount: item.readinessTaskIds.length,
    overdue: overdue,
  );
}

IncomingTalentGovernanceExecutionStatus _executionStatusFor(
  IncomingTalentGovernanceDecisionLedgerStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceDecisionLedgerStatus.clear =>
      IncomingTalentGovernanceExecutionStatus.completed,
    IncomingTalentGovernanceDecisionLedgerStatus.blocked =>
      IncomingTalentGovernanceExecutionStatus.blocked,
    IncomingTalentGovernanceDecisionLedgerStatus.needsDecision =>
      IncomingTalentGovernanceExecutionStatus.awaitingDecision,
    IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence =>
      IncomingTalentGovernanceExecutionStatus.evidenceRecovery,
    IncomingTalentGovernanceDecisionLedgerStatus.needsOwner =>
      IncomingTalentGovernanceExecutionStatus.ownerConfirmation,
    IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish =>
      IncomingTalentGovernanceExecutionStatus.inProgress,
  };
}

String _executionTitle(IncomingTalentGovernanceDecisionLedgerItem item) {
  if (item.title.startsWith('Publish ')) {
    return item.title.replaceFirst('Publish ', 'Execute ');
  }
  return 'Execute ${item.title.toLowerCase()}';
}

String _actionPlanFor({
  required IncomingTalentGovernanceDecisionLedgerItem item,
  required IncomingTalentGovernanceExecutionStatus status,
}) {
  final title = item.title.toLowerCase();

  return switch (status) {
    IncomingTalentGovernanceExecutionStatus.blocked =>
      'Unblock $title before assigning follow-through.',
    IncomingTalentGovernanceExecutionStatus.awaitingDecision =>
      'Record the leadership decision and confirm the first follow-up owner.',
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery =>
      'Attach execution evidence for $title and refresh recovery notes.',
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation =>
      'Confirm accountable owner and cadence for $title.',
    IncomingTalentGovernanceExecutionStatus.inProgress =>
      'Publish $title and start owner follow-through.',
    IncomingTalentGovernanceExecutionStatus.completed =>
      'Archive $title with the next review date visible.',
  };
}

String _blockerNoteFor(IncomingTalentGovernanceExecutionStatus status) {
  return switch (status) {
    IncomingTalentGovernanceExecutionStatus.blocked =>
      'Readiness blockers must be resolved before execution can move.',
    IncomingTalentGovernanceExecutionStatus.awaitingDecision =>
      'Leadership decision is still required before follow-through starts.',
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery =>
      'Execution evidence is missing or not current.',
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation =>
      'Accountable owner must be confirmed before publish.',
    IncomingTalentGovernanceExecutionStatus.inProgress ||
    IncomingTalentGovernanceExecutionStatus.completed => '',
  };
}

double _progressRatioFor(IncomingTalentGovernanceExecutionStatus status) {
  return switch (status) {
    IncomingTalentGovernanceExecutionStatus.blocked => 0.1,
    IncomingTalentGovernanceExecutionStatus.awaitingDecision => 0.25,
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation => 0.35,
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery => 0.45,
    IncomingTalentGovernanceExecutionStatus.inProgress => 0.75,
    IncomingTalentGovernanceExecutionStatus.completed => 1,
  };
}

bool _isOverdue({
  required IncomingTalentGovernanceExecutionStatus status,
  required DateTime dueDate,
  required DateTime asOfDate,
}) {
  if (status == IncomingTalentGovernanceExecutionStatus.completed) {
    return false;
  }
  return _dateOnly(dueDate).isBefore(_dateOnly(asOfDate));
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _compareTracks(
  IncomingTalentGovernanceExecutionTrack left,
  IncomingTalentGovernanceExecutionTrack right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}
