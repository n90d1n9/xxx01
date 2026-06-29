import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_queue_item.dart';

/// Follow-up work type created after a talent risk council decision.
enum IncomingTalentRiskCouncilFollowUpType {
  ownerCommitment('Owner commitment'),
  actionCheckpoint('Action checkpoint'),
  monitoringReview('Monitoring review'),
  peopleBoardEscalation('People board escalation'),
  closureEvidence('Closure evidence');

  final String label;

  const IncomingTalentRiskCouncilFollowUpType(this.label);
}

/// Lifecycle state for tracking risk council follow-up execution.
enum IncomingTalentRiskCouncilFollowUpStatus {
  planned('Planned'),
  inProgress('In progress'),
  blocked('Blocked'),
  escalated('Escalated'),
  completed('Completed');

  final String label;

  const IncomingTalentRiskCouncilFollowUpStatus(this.label);
}

/// Operational follow-up record that turns council decisions into trackable work.
class IncomingTalentRiskCouncilFollowUp {
  final String id;
  final String decisionId;
  final String queueItemId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String decisionMakerName;
  final String followUpOwnerName;
  final IncomingTalentRiskCouncilDecisionOutcome outcome;
  final IncomingTalentRiskCouncilQueueCategory category;
  final IncomingTalentRiskCouncilQueueSeverity sourceSeverity;
  final IncomingTalentRiskCouncilQueueSource source;
  final IncomingTalentRiskCouncilFollowUpType followUpType;
  final IncomingTalentRiskCouncilFollowUpStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String successCriteria;
  final String blockerNote;
  final String escalationReason;
  final DateTime createdAt;
  final int signalCount;

  const IncomingTalentRiskCouncilFollowUp({
    required this.id,
    required this.decisionId,
    required this.queueItemId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.decisionMakerName,
    required this.followUpOwnerName,
    required this.outcome,
    required this.category,
    required this.sourceSeverity,
    this.source = IncomingTalentRiskCouncilQueueSource.general,
    required this.followUpType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.blockerNote,
    required this.escalationReason,
    required this.createdAt,
    required this.signalCount,
  });

  bool get isOpen {
    return status != IncomingTalentRiskCouncilFollowUpStatus.completed;
  }

  bool get needsAttention {
    return isOpen &&
        (status == IncomingTalentRiskCouncilFollowUpStatus.blocked ||
            status == IncomingTalentRiskCouncilFollowUpStatus.escalated ||
            sourceSeverity == IncomingTalentRiskCouncilQueueSeverity.critical ||
            outcome ==
                IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard);
  }

  /// Whether this follow-up was created from a promotion resolution review.
  bool get isPromotionResolutionReview {
    return source ==
        IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;
  }

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return isOpen && days >= 0 && days <= 7;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) < 0;
  }

  IncomingTalentRiskCouncilFollowUp copyWith({
    IncomingTalentRiskCouncilFollowUpStatus? status,
    String? blockerNote,
    String? escalationReason,
  }) {
    return IncomingTalentRiskCouncilFollowUp(
      id: id,
      decisionId: decisionId,
      queueItemId: queueItemId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      decisionMakerName: decisionMakerName,
      followUpOwnerName: followUpOwnerName,
      outcome: outcome,
      category: category,
      sourceSeverity: sourceSeverity,
      source: source,
      followUpType: followUpType,
      status: status ?? this.status,
      dueDate: dueDate,
      actionPlan: actionPlan,
      successCriteria: successCriteria,
      blockerNote: blockerNote ?? this.blockerNote,
      escalationReason: escalationReason ?? this.escalationReason,
      createdAt: createdAt,
      signalCount: signalCount,
    );
  }
}
