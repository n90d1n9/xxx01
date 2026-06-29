import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';
import 'incoming_talent_risk_council_queue_item.dart';

enum IncomingTalentRiskCouncilSlaSource {
  councilDecision('Council decision'),
  councilFollowUp('Council follow-up'),
  followUpExecution('Follow-up execution');

  final String label;

  const IncomingTalentRiskCouncilSlaSource(this.label);
}

enum IncomingTalentRiskCouncilSlaStatus {
  blocked('Blocked'),
  escalated('Escalated'),
  overdue('Overdue'),
  dueSoon('Due soon'),
  waiting('Waiting'),
  onTrack('On track');

  final String label;

  const IncomingTalentRiskCouncilSlaStatus(this.label);
}

/// SLA item that tracks council decisions, follow-up creation, and execution.
class IncomingTalentRiskCouncilSlaItem {
  final String id;
  final IncomingTalentRiskCouncilSlaSource source;
  final IncomingTalentRiskCouncilQueueSource councilSource;
  final IncomingTalentRiskCouncilSlaStatus status;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String title;
  final String nextAction;
  final DateTime dueDate;
  final bool requiresAttention;

  const IncomingTalentRiskCouncilSlaItem({
    required this.id,
    required this.source,
    this.councilSource = IncomingTalentRiskCouncilQueueSource.general,
    required this.status,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.title,
    required this.nextAction,
    required this.dueDate,
    required this.requiresAttention,
  });

  factory IncomingTalentRiskCouncilSlaItem.fromQueueItem({
    required IncomingTalentRiskCouncilQueueItem item,
    required DateTime asOfDate,
  }) {
    final status = _statusFromDueDate(item.dueDate, asOfDate);

    return IncomingTalentRiskCouncilSlaItem(
      id: 'sla-risk-decision:${item.id}',
      source: IncomingTalentRiskCouncilSlaSource.councilDecision,
      councilSource: item.source,
      status: status,
      candidateName: item.candidateName,
      role: item.role,
      department: item.department,
      ownerName: '${item.department} Talent Partner',
      title: item.category.label,
      nextAction: item.recommendedAction,
      dueDate: item.dueDate,
      requiresAttention:
          item.isCritical ||
          status == IncomingTalentRiskCouncilSlaStatus.dueSoon ||
          status == IncomingTalentRiskCouncilSlaStatus.overdue,
    );
  }

  factory IncomingTalentRiskCouncilSlaItem.fromDecision({
    required IncomingTalentRiskCouncilDecision decision,
    required DateTime asOfDate,
  }) {
    final isEscalated =
        decision.outcome ==
        IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard;

    return IncomingTalentRiskCouncilSlaItem(
      id: 'sla-risk-follow-up-ready:${decision.id}',
      source: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
      councilSource: decision.source,
      status:
          isEscalated
              ? IncomingTalentRiskCouncilSlaStatus.escalated
              : _statusFromDueDate(decision.followUpDate, asOfDate),
      candidateName: decision.candidateName,
      role: decision.role,
      department: decision.department,
      ownerName: decision.ownerName,
      title: 'Create risk follow-up',
      nextAction: decision.commitmentSummary,
      dueDate: decision.followUpDate,
      requiresAttention: decision.needsAttention,
    );
  }

  factory IncomingTalentRiskCouncilSlaItem.fromFollowUp({
    required IncomingTalentRiskCouncilFollowUp followUp,
    required DateTime asOfDate,
  }) {
    final status = _statusFromFollowUp(followUp, asOfDate);

    return IncomingTalentRiskCouncilSlaItem(
      id: 'sla-risk-follow-up:${followUp.id}',
      source: IncomingTalentRiskCouncilSlaSource.followUpExecution,
      councilSource: followUp.source,
      status: status,
      candidateName: followUp.candidateName,
      role: followUp.role,
      department: followUp.department,
      ownerName: followUp.followUpOwnerName,
      title: followUp.followUpType.label,
      nextAction: followUp.actionPlan,
      dueDate: followUp.dueDate,
      requiresAttention:
          followUp.needsAttention ||
          status == IncomingTalentRiskCouncilSlaStatus.dueSoon ||
          status == IncomingTalentRiskCouncilSlaStatus.overdue,
    );
  }

  bool get needsAttention => requiresAttention;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  int get urgencyRank {
    return switch (status) {
      IncomingTalentRiskCouncilSlaStatus.blocked => 0,
      IncomingTalentRiskCouncilSlaStatus.escalated => 1,
      IncomingTalentRiskCouncilSlaStatus.overdue => 2,
      IncomingTalentRiskCouncilSlaStatus.dueSoon => 3,
      IncomingTalentRiskCouncilSlaStatus.waiting => 4,
      IncomingTalentRiskCouncilSlaStatus.onTrack => 5,
    };
  }
}

IncomingTalentRiskCouncilSlaStatus _statusFromFollowUp(
  IncomingTalentRiskCouncilFollowUp followUp,
  DateTime asOfDate,
) {
  return switch (followUp.status) {
    IncomingTalentRiskCouncilFollowUpStatus.blocked =>
      IncomingTalentRiskCouncilSlaStatus.blocked,
    IncomingTalentRiskCouncilFollowUpStatus.escalated =>
      IncomingTalentRiskCouncilSlaStatus.escalated,
    _ => _statusFromDueDate(followUp.dueDate, asOfDate),
  };
}

IncomingTalentRiskCouncilSlaStatus _statusFromDueDate(
  DateTime dueDate,
  DateTime asOfDate,
) {
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final days = due.difference(start).inDays;

  if (days < 0) return IncomingTalentRiskCouncilSlaStatus.overdue;
  if (days <= 7) return IncomingTalentRiskCouncilSlaStatus.dueSoon;
  if (days <= 14) return IncomingTalentRiskCouncilSlaStatus.waiting;
  return IncomingTalentRiskCouncilSlaStatus.onTrack;
}
