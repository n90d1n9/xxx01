import 'incoming_talent_mobility_first_review.dart';

enum IncomingTalentMobilityStabilizationActionType {
  sponsorAlignment('Sponsor alignment'),
  hostManagerCoaching('Host manager coaching'),
  roleScopeClarification('Role scope clarification'),
  capabilitySupport('Capability support'),
  retentionSave('Retention save');

  final String label;

  const IncomingTalentMobilityStabilizationActionType(this.label);
}

enum IncomingTalentMobilityStabilizationStatus {
  planned('Planned'),
  inProgress('In progress'),
  blocked('Blocked'),
  completed('Completed');

  final String label;

  const IncomingTalentMobilityStabilizationStatus(this.label);
}

class IncomingTalentMobilityStabilizationAction {
  final String id;
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
  final IncomingTalentMobilityFirstReviewOutcome reviewOutcome;
  final IncomingTalentMobilityFirstReviewRetentionRisk retentionRisk;
  final int hostConfidenceScore;
  final IncomingTalentMobilityStabilizationActionType actionType;
  final IncomingTalentMobilityStabilizationStatus status;
  final String ownerName;
  final DateTime dueDate;
  final String actionSummary;
  final String successMeasure;
  final String blockerNote;
  final DateTime createdAt;

  const IncomingTalentMobilityStabilizationAction({
    required this.id,
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
    required this.reviewOutcome,
    required this.retentionRisk,
    required this.hostConfidenceScore,
    required this.actionType,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.actionSummary,
    required this.successMeasure,
    required this.blockerNote,
    required this.createdAt,
  });

  bool get isCompleted {
    return status == IncomingTalentMobilityStabilizationStatus.completed;
  }

  bool get needsAttention {
    return status == IncomingTalentMobilityStabilizationStatus.blocked ||
        (!isCompleted &&
            (reviewOutcome == IncomingTalentMobilityFirstReviewOutcome.watch ||
                reviewOutcome ==
                    IncomingTalentMobilityFirstReviewOutcome.blocked ||
                retentionRisk !=
                    IncomingTalentMobilityFirstReviewRetentionRisk.low ||
                hostConfidenceScore <= 3));
  }

  double get progressRatio {
    return switch (status) {
      IncomingTalentMobilityStabilizationStatus.planned => 0.2,
      IncomingTalentMobilityStabilizationStatus.inProgress => 0.55,
      IncomingTalentMobilityStabilizationStatus.blocked => 0.35,
      IncomingTalentMobilityStabilizationStatus.completed => 1,
    };
  }

  int daysUntilDue(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return !isCompleted && days >= 0 && days <= 7;
  }

  IncomingTalentMobilityStabilizationAction copyWith({
    IncomingTalentMobilityStabilizationStatus? status,
  }) {
    return IncomingTalentMobilityStabilizationAction(
      id: id,
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
      reviewOutcome: reviewOutcome,
      retentionRisk: retentionRisk,
      hostConfidenceScore: hostConfidenceScore,
      actionType: actionType,
      status: status ?? this.status,
      ownerName: ownerName,
      dueDate: dueDate,
      actionSummary: actionSummary,
      successMeasure: successMeasure,
      blockerNote: blockerNote,
      createdAt: createdAt,
    );
  }
}
