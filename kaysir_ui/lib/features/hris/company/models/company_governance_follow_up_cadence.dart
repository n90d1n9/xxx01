import 'company_document_audit_event.dart';
import 'company_governance_follow_up_policy.dart';
import 'company_governance_owner_handoff_record.dart';
import 'company_governance_owner_load.dart';

/// Follow-up status for a governance owner after handoff routing.
enum CompanyGovernanceFollowUpState {
  needsHandoff('Needs handoff'),
  overdue('Overdue'),
  dueToday('Due today'),
  scheduled('Scheduled');

  final String label;

  const CompanyGovernanceFollowUpState(this.label);

  int get sortRank {
    switch (this) {
      case CompanyGovernanceFollowUpState.needsHandoff:
        return 0;
      case CompanyGovernanceFollowUpState.overdue:
        return 1;
      case CompanyGovernanceFollowUpState.dueToday:
        return 2;
      case CompanyGovernanceFollowUpState.scheduled:
        return 3;
    }
  }
}

/// SLA-backed follow-up lane for one governance owner workload.
class CompanyGovernanceFollowUpLane {
  final String ownerName;
  final CompanyGovernanceOwnerLoadRisk risk;
  final int actionCount;
  final int criticalCount;
  final int highCount;
  final String sourceSummary;
  final String primaryActionLabel;
  final String queueDueLabel;
  final String handoffRecordId;
  final String handoffAuditEventId;
  final String lastFollowUpAuditEventId;
  final DateTime? lastHandoffAt;
  final DateTime? lastFollowedUpAt;
  final int followUpCount;
  final DateTime nextTouchDate;
  final CompanyGovernanceFollowUpState state;
  final String rationale;

  const CompanyGovernanceFollowUpLane({
    required this.ownerName,
    required this.risk,
    required this.actionCount,
    required this.criticalCount,
    required this.highCount,
    required this.sourceSummary,
    required this.primaryActionLabel,
    required this.queueDueLabel,
    this.handoffRecordId = '',
    this.handoffAuditEventId = '',
    this.lastFollowUpAuditEventId = '',
    this.lastHandoffAt,
    this.lastFollowedUpAt,
    this.followUpCount = 0,
    required this.nextTouchDate,
    required this.state,
    required this.rationale,
  });

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'Unassigned owner' : ownerName;
  }

  bool get hasHandoff => handoffRecordId.trim().isNotEmpty;

  bool get canRecordFollowUp => hasHandoff;

  String get auditEventId {
    if (lastFollowUpAuditEventId.trim().isNotEmpty) {
      return lastFollowUpAuditEventId;
    }
    return handoffAuditEventId;
  }

  bool get hasAuditEvent => auditEventId.trim().isNotEmpty;

  String nextTouchLabel(DateTime asOfDate) {
    if (!hasHandoff) {
      return 'Record handoff';
    }

    final days =
        _dateOnly(nextTouchDate).difference(_dateOnly(asOfDate)).inDays;
    if (days < 0) return '${days.abs()}d overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in ${days}d';
  }

  String lastTouchLabel(DateTime asOfDate) {
    final followedUpAt = lastFollowedUpAt;
    if (followedUpAt != null) {
      return _agoLabel(followedUpAt, asOfDate, 'Followed up');
    }

    final handoffAt = lastHandoffAt;
    if (handoffAt != null) {
      return _agoLabel(handoffAt, asOfDate, 'Handed off');
    }

    return 'No handoff';
  }
}

/// Builds governance follow-up lanes from owner load, handoff, and audit state.
List<CompanyGovernanceFollowUpLane> buildCompanyGovernanceFollowUpCadence({
  required List<CompanyGovernanceOwnerLoad> loads,
  required List<CompanyGovernanceOwnerHandoffRecord> handoffRecords,
  required List<CompanyDocumentAuditEvent> auditEvents,
  required DateTime asOfDate,
  CompanyGovernanceFollowUpPolicy policy =
      CompanyGovernanceFollowUpPolicy.defaultPolicy,
  int limit = 6,
}) {
  if (limit <= 0) return const [];

  final lanes = [
    for (final load in loads)
      _laneForLoad(
        load: load,
        handoffRecords: handoffRecords,
        auditEvents: auditEvents,
        asOfDate: asOfDate,
        policy: policy,
      ),
  ]..sort(_compareLanes);

  return lanes.take(limit).toList(growable: false);
}

CompanyGovernanceFollowUpLane _laneForLoad({
  required CompanyGovernanceOwnerLoad load,
  required List<CompanyGovernanceOwnerHandoffRecord> handoffRecords,
  required List<CompanyDocumentAuditEvent> auditEvents,
  required DateTime asOfDate,
  required CompanyGovernanceFollowUpPolicy policy,
}) {
  final handoff = latestCompanyGovernanceOwnerHandoffRecord(
    records: handoffRecords,
    ownerName: load.ownerLabel,
  );
  if (handoff == null) {
    return CompanyGovernanceFollowUpLane(
      ownerName: load.ownerLabel,
      risk: load.risk,
      actionCount: load.actionCount,
      criticalCount: load.criticalCount,
      highCount: load.highCount,
      sourceSummary: load.sourceSummary,
      primaryActionLabel: load.primaryActionLabel,
      queueDueLabel: load.nextDueLabel,
      nextTouchDate: _dateOnly(asOfDate),
      state: CompanyGovernanceFollowUpState.needsHandoff,
      rationale:
          '${load.ownerLabel} has ${load.actionCount} active governance actions and no recorded handoff.',
    );
  }

  final followUpEvents = _followUpEventsForHandoff(
    handoff: handoff,
    auditEvents: auditEvents,
  );
  final latestFollowUp = followUpEvents.firstOrNull;
  final baseDate =
      latestFollowUp != null &&
              !latestFollowUp.happenedAt.isBefore(handoff.recordedAt)
          ? latestFollowUp.happenedAt
          : handoff.recordedAt;
  final nextTouchDate = _dateOnly(
    baseDate,
  ).add(Duration(days: policy.cadenceDaysFor(load.risk)));
  final state = _stateFor(nextTouchDate: nextTouchDate, asOfDate: asOfDate);

  return CompanyGovernanceFollowUpLane(
    ownerName: load.ownerLabel,
    risk: load.risk,
    actionCount: load.actionCount,
    criticalCount: load.criticalCount,
    highCount: load.highCount,
    sourceSummary: load.sourceSummary,
    primaryActionLabel: load.primaryActionLabel,
    queueDueLabel: load.nextDueLabel,
    handoffRecordId: handoff.id,
    handoffAuditEventId: handoff.auditEventId,
    lastFollowUpAuditEventId: latestFollowUp?.id ?? '',
    lastHandoffAt: handoff.recordedAt,
    lastFollowedUpAt: latestFollowUp?.happenedAt,
    followUpCount: followUpEvents.length,
    nextTouchDate: nextTouchDate,
    state: state,
    rationale: _rationaleFor(load: load, state: state),
  );
}

List<CompanyDocumentAuditEvent> _followUpEventsForHandoff({
  required CompanyGovernanceOwnerHandoffRecord handoff,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  return auditEvents
      .where(
        (event) =>
            event.type ==
                CompanyDocumentAuditEventType.governanceOwnerFollowedUp &&
            (event.correlationId == handoff.id ||
                event.documentId == handoff.id),
      )
      .toList()
    ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
}

CompanyGovernanceFollowUpState _stateFor({
  required DateTime nextTouchDate,
  required DateTime asOfDate,
}) {
  final days = _dateOnly(nextTouchDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return CompanyGovernanceFollowUpState.overdue;
  if (days == 0) return CompanyGovernanceFollowUpState.dueToday;
  return CompanyGovernanceFollowUpState.scheduled;
}

int _compareLanes(
  CompanyGovernanceFollowUpLane a,
  CompanyGovernanceFollowUpLane b,
) {
  final stateComparison = a.state.sortRank.compareTo(b.state.sortRank);
  if (stateComparison != 0) return stateComparison;

  final dateComparison = a.nextTouchDate.compareTo(b.nextTouchDate);
  if (dateComparison != 0) return dateComparison;

  final riskComparison = a.risk.sortRank.compareTo(b.risk.sortRank);
  if (riskComparison != 0) return riskComparison;

  final actionComparison = b.actionCount.compareTo(a.actionCount);
  if (actionComparison != 0) return actionComparison;

  return a.ownerLabel.compareTo(b.ownerLabel);
}

String _rationaleFor({
  required CompanyGovernanceOwnerLoad load,
  required CompanyGovernanceFollowUpState state,
}) {
  final base =
      '${load.risk.label} with ${load.actionCount} active action'
      '${load.actionCount == 1 ? '' : 's'} across ${load.sourceSummary}.';
  switch (state) {
    case CompanyGovernanceFollowUpState.needsHandoff:
      return '$base Record a handoff before follow-up cadence starts.';
    case CompanyGovernanceFollowUpState.overdue:
      return '$base Follow-up is overdue.';
    case CompanyGovernanceFollowUpState.dueToday:
      return '$base Follow-up is due today.';
    case CompanyGovernanceFollowUpState.scheduled:
      return '$base Follow-up is scheduled.';
  }
}

String _agoLabel(DateTime date, DateTime asOfDate, String prefix) {
  final days = _dateOnly(asOfDate).difference(_dateOnly(date)).inDays;
  if (days <= 0) return '$prefix today';
  if (days == 1) return '$prefix yesterday';
  return '$prefix ${days}d ago';
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
