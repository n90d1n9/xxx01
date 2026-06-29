import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_council_decision.dart';
import 'incoming_talent_succession_coverage_governance_record.dart';

enum IncomingTalentSuccessionCoverageCouncilFollowUpType {
  sponsorCommitment('Sponsor commitment'),
  recoveryCheckpoint('Recovery checkpoint'),
  closureEvidence('Closure evidence'),
  councilRefresh('Council refresh'),
  peopleBoardEscalation('People board escalation');

  final String label;

  const IncomingTalentSuccessionCoverageCouncilFollowUpType(this.label);
}

enum IncomingTalentSuccessionCoverageCouncilFollowUpStatus {
  planned('Planned'),
  inProgress('In progress'),
  blocked('Blocked'),
  escalated('Escalated'),
  completed('Completed');

  final String label;

  const IncomingTalentSuccessionCoverageCouncilFollowUpStatus(this.label);
}

class IncomingTalentSuccessionCoverageCouncilFollowUp {
  final String id;
  final String decisionId;
  final String agendaItemId;
  final String governanceRecordId;
  final String scopeLabel;
  final String departmentScope;
  final String councilOwnerName;
  final String followUpOwnerName;
  final String executiveSponsorName;
  final IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome;
  final IncomingTalentSuccessionCoverageCouncilAgendaPriority priority;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel;
  final IncomingTalentSuccessionCoverageCouncilFollowUpType followUpType;
  final IncomingTalentSuccessionCoverageCouncilFollowUpStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String successCriteria;
  final String blockerNote;
  final String escalationReason;
  final DateTime createdAt;

  const IncomingTalentSuccessionCoverageCouncilFollowUp({
    required this.id,
    required this.decisionId,
    required this.agendaItemId,
    required this.governanceRecordId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.councilOwnerName,
    required this.followUpOwnerName,
    required this.executiveSponsorName,
    required this.outcome,
    required this.priority,
    required this.riskLevel,
    required this.followUpType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.blockerNote,
    required this.escalationReason,
    required this.createdAt,
  });

  bool get isOpen {
    return status !=
        IncomingTalentSuccessionCoverageCouncilFollowUpStatus.completed;
  }

  bool get needsAttention {
    return isOpen &&
        (status ==
                IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked ||
            status ==
                IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                    .escalated ||
            priority ==
                IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent ||
            riskLevel ==
                IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical);
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

  IncomingTalentSuccessionCoverageCouncilFollowUp copyWith({
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus? status,
    String? blockerNote,
    String? escalationReason,
  }) {
    return IncomingTalentSuccessionCoverageCouncilFollowUp(
      id: id,
      decisionId: decisionId,
      agendaItemId: agendaItemId,
      governanceRecordId: governanceRecordId,
      scopeLabel: scopeLabel,
      departmentScope: departmentScope,
      councilOwnerName: councilOwnerName,
      followUpOwnerName: followUpOwnerName,
      executiveSponsorName: executiveSponsorName,
      outcome: outcome,
      priority: priority,
      riskLevel: riskLevel,
      followUpType: followUpType,
      status: status ?? this.status,
      dueDate: dueDate,
      actionPlan: actionPlan,
      successCriteria: successCriteria,
      blockerNote: blockerNote ?? this.blockerNote,
      escalationReason: escalationReason ?? this.escalationReason,
      createdAt: createdAt,
    );
  }
}
