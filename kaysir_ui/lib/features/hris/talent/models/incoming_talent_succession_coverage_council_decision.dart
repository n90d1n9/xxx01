import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_governance_record.dart';

enum IncomingTalentSuccessionCoverageCouncilDecisionOutcome {
  approveRecoveryPlan('Approve recovery plan'),
  assignExecutiveSponsor('Assign executive sponsor'),
  validateClosure('Validate closure'),
  deferToNextCouncil('Defer to next council'),
  escalateToPeopleBoard('Escalate to people board');

  final String label;

  const IncomingTalentSuccessionCoverageCouncilDecisionOutcome(this.label);
}

class IncomingTalentSuccessionCoverageCouncilDecision {
  final String id;
  final String agendaItemId;
  final String governanceRecordId;
  final String scopeLabel;
  final String departmentScope;
  final String ownerName;
  final String decisionMakerName;
  final String executiveSponsorName;
  final IncomingTalentSuccessionCoverageCouncilAgendaLane lane;
  final IncomingTalentSuccessionCoverageCouncilAgendaPriority priority;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel;
  final int coverageScore;
  final DateTime decisionDate;
  final IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome;
  final String commitmentSummary;
  final String minutesNote;
  final DateTime followUpDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionCoverageCouncilDecision({
    required this.id,
    required this.agendaItemId,
    required this.governanceRecordId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.ownerName,
    required this.decisionMakerName,
    required this.executiveSponsorName,
    required this.lane,
    required this.priority,
    required this.riskLevel,
    required this.coverageScore,
    required this.decisionDate,
    required this.outcome,
    required this.commitmentSummary,
    required this.minutesNote,
    required this.followUpDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return outcome ==
            IncomingTalentSuccessionCoverageCouncilDecisionOutcome
                .deferToNextCouncil ||
        outcome ==
            IncomingTalentSuccessionCoverageCouncilDecisionOutcome
                .escalateToPeopleBoard ||
        priority ==
            IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent ||
        riskLevel ==
            IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical;
  }

  double get coverageRatio => coverageScore / 100;
}
