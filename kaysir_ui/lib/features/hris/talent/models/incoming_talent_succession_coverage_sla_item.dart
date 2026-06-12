import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_council_decision.dart';
import 'incoming_talent_succession_coverage_council_follow_up.dart';
import 'incoming_talent_succession_coverage_review.dart';

enum IncomingTalentSuccessionCoverageSlaSource {
  coverageReview('Review action'),
  coverageAction('Recovery action'),
  actionOutcome('Outcome review'),
  councilDecision('Council decision'),
  councilFollowUp('Council follow-up');

  final String label;

  const IncomingTalentSuccessionCoverageSlaSource(this.label);
}

enum IncomingTalentSuccessionCoverageSlaStatus {
  blocked('Blocked'),
  escalated('Escalated'),
  overdue('Overdue'),
  dueSoon('Due soon'),
  waiting('Waiting'),
  onTrack('On track');

  final String label;

  const IncomingTalentSuccessionCoverageSlaStatus(this.label);
}

class IncomingTalentSuccessionCoverageSlaItem {
  final String id;
  final IncomingTalentSuccessionCoverageSlaSource source;
  final IncomingTalentSuccessionCoverageSlaStatus status;
  final String scopeLabel;
  final String departmentScope;
  final String ownerName;
  final String title;
  final String nextAction;
  final DateTime dueDate;
  final bool requiresAttention;

  const IncomingTalentSuccessionCoverageSlaItem({
    required this.id,
    required this.source,
    required this.status,
    required this.scopeLabel,
    required this.departmentScope,
    required this.ownerName,
    required this.title,
    required this.nextAction,
    required this.dueDate,
    required this.requiresAttention,
  });

  factory IncomingTalentSuccessionCoverageSlaItem.fromReviewActionGap({
    required IncomingTalentSuccessionCoverageReview review,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-review:${review.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.coverageReview,
      status: _statusFromDueDate(review.nextReviewDate, asOfDate),
      scopeLabel: review.scopeLabel,
      departmentScope: review.departmentScope,
      ownerName: review.reviewerName,
      title: 'Create recovery action',
      nextAction: review.executiveCommitment,
      dueDate: review.nextReviewDate,
      requiresAttention: review.needsAttention,
    );
  }

  factory IncomingTalentSuccessionCoverageSlaItem.fromCoverageAction({
    required IncomingTalentSuccessionCoverageAction action,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-action:${action.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.coverageAction,
      status:
          action.status == IncomingTalentSuccessionCoverageActionStatus.blocked
              ? IncomingTalentSuccessionCoverageSlaStatus.blocked
              : _statusFromDueDate(action.dueDate, asOfDate),
      scopeLabel: action.scopeLabel,
      departmentScope: action.departmentScope,
      ownerName: action.ownerName,
      title: action.actionType.label,
      nextAction: action.actionPlan,
      dueDate: action.dueDate,
      requiresAttention: action.needsAttention || action.isDueSoon(asOfDate),
    );
  }

  factory IncomingTalentSuccessionCoverageSlaItem.fromOutcomeAction({
    required IncomingTalentSuccessionCoverageAction action,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-outcome:${action.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.actionOutcome,
      status: _statusFromDueDate(action.dueDate, asOfDate),
      scopeLabel: action.scopeLabel,
      departmentScope: action.departmentScope,
      ownerName: action.ownerName,
      title: 'Validate resolved action',
      nextAction: action.resolutionEvidence,
      dueDate: action.dueDate,
      requiresAttention: true,
    );
  }

  factory IncomingTalentSuccessionCoverageSlaItem.fromCouncilAgendaItem({
    required IncomingTalentSuccessionCoverageCouncilAgendaItem item,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-council-decision:${item.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.councilDecision,
      status: _statusFromDueDate(item.councilDate, asOfDate),
      scopeLabel: item.scopeLabel,
      departmentScope: item.departmentScope,
      ownerName: item.ownerName,
      title: item.lane.label,
      nextAction: item.decisionQuestion,
      dueDate: item.councilDate,
      requiresAttention:
          item.priority ==
              IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent ||
          item.priority ==
              IncomingTalentSuccessionCoverageCouncilAgendaPriority.high,
    );
  }

  factory IncomingTalentSuccessionCoverageSlaItem.fromCouncilDecision({
    required IncomingTalentSuccessionCoverageCouncilDecision decision,
    required DateTime asOfDate,
  }) {
    final isEscalated =
        decision.outcome ==
        IncomingTalentSuccessionCoverageCouncilDecisionOutcome
            .escalateToPeopleBoard;

    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-council-follow-up-ready:${decision.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.councilFollowUp,
      status:
          isEscalated
              ? IncomingTalentSuccessionCoverageSlaStatus.escalated
              : _statusFromDueDate(decision.followUpDate, asOfDate),
      scopeLabel: decision.scopeLabel,
      departmentScope: decision.departmentScope,
      ownerName: decision.executiveSponsorName,
      title: 'Create council follow-up',
      nextAction: decision.commitmentSummary,
      dueDate: decision.followUpDate,
      requiresAttention: decision.needsAttention,
    );
  }

  factory IncomingTalentSuccessionCoverageSlaItem.fromCouncilFollowUp({
    required IncomingTalentSuccessionCoverageCouncilFollowUp followUp,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageSlaItem(
      id: 'sla-council-follow-up:${followUp.id}',
      source: IncomingTalentSuccessionCoverageSlaSource.councilFollowUp,
      status: _statusFromCouncilFollowUp(followUp, asOfDate),
      scopeLabel: followUp.scopeLabel,
      departmentScope: followUp.departmentScope,
      ownerName: followUp.followUpOwnerName,
      title: followUp.followUpType.label,
      nextAction: followUp.actionPlan,
      dueDate: followUp.dueDate,
      requiresAttention:
          followUp.needsAttention || followUp.isDueSoon(asOfDate),
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
      IncomingTalentSuccessionCoverageSlaStatus.blocked => 0,
      IncomingTalentSuccessionCoverageSlaStatus.escalated => 1,
      IncomingTalentSuccessionCoverageSlaStatus.overdue => 2,
      IncomingTalentSuccessionCoverageSlaStatus.dueSoon => 3,
      IncomingTalentSuccessionCoverageSlaStatus.waiting => 4,
      IncomingTalentSuccessionCoverageSlaStatus.onTrack => 5,
    };
  }
}

IncomingTalentSuccessionCoverageSlaStatus _statusFromCouncilFollowUp(
  IncomingTalentSuccessionCoverageCouncilFollowUp followUp,
  DateTime asOfDate,
) {
  return switch (followUp.status) {
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked =>
      IncomingTalentSuccessionCoverageSlaStatus.blocked,
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.escalated =>
      IncomingTalentSuccessionCoverageSlaStatus.escalated,
    _ => _statusFromDueDate(followUp.dueDate, asOfDate),
  };
}

IncomingTalentSuccessionCoverageSlaStatus _statusFromDueDate(
  DateTime dueDate,
  DateTime asOfDate,
) {
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final days = due.difference(start).inDays;

  if (days < 0) return IncomingTalentSuccessionCoverageSlaStatus.overdue;
  if (days <= 7) return IncomingTalentSuccessionCoverageSlaStatus.dueSoon;
  if (days <= 14) return IncomingTalentSuccessionCoverageSlaStatus.waiting;
  return IncomingTalentSuccessionCoverageSlaStatus.onTrack;
}
