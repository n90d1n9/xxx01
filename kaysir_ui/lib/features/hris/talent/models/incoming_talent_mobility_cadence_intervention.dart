import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

enum IncomingTalentMobilityCadenceInterventionType {
  managerCoaching('Manager coaching'),
  sponsorEscalation('Sponsor escalation'),
  roleScopeReset('Role scope reset'),
  workloadRebalance('Workload rebalance'),
  retentionConversation('Retention conversation');

  final String label;

  const IncomingTalentMobilityCadenceInterventionType(this.label);
}

enum IncomingTalentMobilityCadenceInterventionPriority {
  standard('Standard'),
  high('High'),
  urgent('Urgent');

  final String label;

  const IncomingTalentMobilityCadenceInterventionPriority(this.label);
}

enum IncomingTalentMobilityCadenceInterventionStatus {
  planned('Planned'),
  inProgress('In progress'),
  blocked('Blocked'),
  resolved('Resolved');

  final String label;

  const IncomingTalentMobilityCadenceInterventionStatus(this.label);
}

class IncomingTalentMobilityCadenceIntervention {
  final String id;
  final String checkInId;
  final String outcomeId;
  final String actionId;
  final String reviewId;
  final String checklistId;
  final String matchId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String currentRole;
  final String department;
  final String targetRole;
  final String opportunityTitle;
  final String hostDepartment;
  final IncomingTalentMobilityCadenceStatus cadenceStatus;
  final IncomingTalentMobilityStabilizationResidualRisk residualRisk;
  final int hostConfidenceScore;
  final IncomingTalentMobilityCadenceInterventionType interventionType;
  final IncomingTalentMobilityCadenceInterventionPriority priority;
  final IncomingTalentMobilityCadenceInterventionStatus status;
  final String ownerName;
  final DateTime dueDate;
  final String interventionSummary;
  final String successMeasure;
  final String blockerNote;
  final DateTime createdAt;

  const IncomingTalentMobilityCadenceIntervention({
    required this.id,
    required this.checkInId,
    required this.outcomeId,
    required this.actionId,
    required this.reviewId,
    required this.checklistId,
    required this.matchId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.currentRole,
    required this.department,
    required this.targetRole,
    required this.opportunityTitle,
    required this.hostDepartment,
    required this.cadenceStatus,
    required this.residualRisk,
    required this.hostConfidenceScore,
    required this.interventionType,
    required this.priority,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.interventionSummary,
    required this.successMeasure,
    required this.blockerNote,
    required this.createdAt,
  });

  bool get isResolved {
    return status == IncomingTalentMobilityCadenceInterventionStatus.resolved;
  }

  bool get needsAttention {
    return status == IncomingTalentMobilityCadenceInterventionStatus.blocked ||
        (!isResolved &&
            (priority !=
                    IncomingTalentMobilityCadenceInterventionPriority
                        .standard ||
                cadenceStatus ==
                    IncomingTalentMobilityCadenceStatus.intervene ||
                residualRisk !=
                    IncomingTalentMobilityStabilizationResidualRisk.low ||
                hostConfidenceScore <= 3));
  }

  double get progressRatio {
    return switch (status) {
      IncomingTalentMobilityCadenceInterventionStatus.planned => 0.2,
      IncomingTalentMobilityCadenceInterventionStatus.inProgress => 0.6,
      IncomingTalentMobilityCadenceInterventionStatus.blocked => 0.35,
      IncomingTalentMobilityCadenceInterventionStatus.resolved => 1,
    };
  }

  int daysUntilDue(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return !isResolved && days >= 0 && days <= 7;
  }

  IncomingTalentMobilityCadenceIntervention copyWith({
    IncomingTalentMobilityCadenceInterventionStatus? status,
  }) {
    return IncomingTalentMobilityCadenceIntervention(
      id: id,
      checkInId: checkInId,
      outcomeId: outcomeId,
      actionId: actionId,
      reviewId: reviewId,
      checklistId: checklistId,
      matchId: matchId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      currentRole: currentRole,
      department: department,
      targetRole: targetRole,
      opportunityTitle: opportunityTitle,
      hostDepartment: hostDepartment,
      cadenceStatus: cadenceStatus,
      residualRisk: residualRisk,
      hostConfidenceScore: hostConfidenceScore,
      interventionType: interventionType,
      priority: priority,
      status: status ?? this.status,
      ownerName: ownerName,
      dueDate: dueDate,
      interventionSummary: interventionSummary,
      successMeasure: successMeasure,
      blockerNote: blockerNote,
      createdAt: createdAt,
    );
  }
}
