import 'incoming_talent_risk_council_commitment_log_item.dart';

enum IncomingTalentRiskCouncilCommitmentActionStatus {
  planned('Planned'),
  inProgress('In progress'),
  waitingEvidence('Waiting evidence'),
  blocked('Blocked'),
  escalated('Escalated'),
  completed('Completed');

  final String label;

  const IncomingTalentRiskCouncilCommitmentActionStatus(this.label);
}

class IncomingTalentRiskCouncilCommitmentAction {
  final String id;
  final String commitmentId;
  final String agendaItemId;
  final IncomingTalentRiskCouncilCommitmentLogType type;
  final IncomingTalentRiskCouncilCommitmentLogStatus sourceStatus;
  final IncomingTalentRiskCouncilCommitmentActionStatus status;
  final String ownerName;
  final DateTime dueDate;
  final String actionPlan;
  final String evidenceExpectation;
  final String evidenceNote;
  final String followUpCadence;
  final String blockerNote;
  final DateTime createdAt;
  final int sourceCount;

  const IncomingTalentRiskCouncilCommitmentAction({
    required this.id,
    required this.commitmentId,
    required this.agendaItemId,
    required this.type,
    required this.sourceStatus,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.actionPlan,
    required this.evidenceExpectation,
    required this.evidenceNote,
    required this.followUpCadence,
    required this.blockerNote,
    required this.createdAt,
    required this.sourceCount,
  });

  bool get isOpen {
    return status != IncomingTalentRiskCouncilCommitmentActionStatus.completed;
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

  bool needsAttention(DateTime asOfDate) {
    return isOpen &&
        (status == IncomingTalentRiskCouncilCommitmentActionStatus.blocked ||
            status ==
                IncomingTalentRiskCouncilCommitmentActionStatus.escalated ||
            status ==
                IncomingTalentRiskCouncilCommitmentActionStatus
                    .waitingEvidence ||
            isOverdue(asOfDate));
  }

  IncomingTalentRiskCouncilCommitmentAction copyWith({
    IncomingTalentRiskCouncilCommitmentActionStatus? status,
    String? evidenceNote,
    String? blockerNote,
  }) {
    return IncomingTalentRiskCouncilCommitmentAction(
      id: id,
      commitmentId: commitmentId,
      agendaItemId: agendaItemId,
      type: type,
      sourceStatus: sourceStatus,
      status: status ?? this.status,
      ownerName: ownerName,
      dueDate: dueDate,
      actionPlan: actionPlan,
      evidenceExpectation: evidenceExpectation,
      evidenceNote: evidenceNote ?? this.evidenceNote,
      followUpCadence: followUpCadence,
      blockerNote: blockerNote ?? this.blockerNote,
      createdAt: createdAt,
      sourceCount: sourceCount,
    );
  }
}
