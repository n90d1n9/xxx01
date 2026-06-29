import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

enum IncomingTalentSuccessionCoverageActionType {
  slateRework('Slate rework'),
  executiveSponsor('Executive sponsor'),
  readinessAcceleration('Readiness acceleration'),
  governanceReview('Governance review'),
  riskClosure('Risk closure');

  final String label;

  const IncomingTalentSuccessionCoverageActionType(this.label);
}

enum IncomingTalentSuccessionCoverageActionStatus {
  planned('Planned'),
  inProgress('In progress'),
  resolved('Resolved'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionCoverageActionStatus(this.label);
}

class IncomingTalentSuccessionCoverageAction {
  final String id;
  final String coverageReviewId;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final IncomingTalentSuccessionCoverageReviewDecision reviewDecision;
  final IncomingTalentSuccessionCoverageHealth coverageHealth;
  final int coverageScore;
  final String ownerName;
  final IncomingTalentSuccessionCoverageActionType actionType;
  final IncomingTalentSuccessionCoverageActionStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String escalationPath;
  final String resolutionEvidence;
  final DateTime createdAt;

  const IncomingTalentSuccessionCoverageAction({
    required this.id,
    required this.coverageReviewId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.attentionOnly,
    required this.reviewerName,
    required this.reviewDecision,
    required this.coverageHealth,
    required this.coverageScore,
    required this.ownerName,
    required this.actionType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.escalationPath,
    required this.resolutionEvidence,
    required this.createdAt,
  });

  bool get isOpen {
    return status != IncomingTalentSuccessionCoverageActionStatus.resolved;
  }

  bool get needsAttention {
    return isOpen ||
        status == IncomingTalentSuccessionCoverageActionStatus.blocked;
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

  IncomingTalentSuccessionCoverageAction copyWith({
    IncomingTalentSuccessionCoverageActionStatus? status,
  }) {
    return IncomingTalentSuccessionCoverageAction(
      id: id,
      coverageReviewId: coverageReviewId,
      scopeLabel: scopeLabel,
      departmentScope: departmentScope,
      attentionOnly: attentionOnly,
      reviewerName: reviewerName,
      reviewDecision: reviewDecision,
      coverageHealth: coverageHealth,
      coverageScore: coverageScore,
      ownerName: ownerName,
      actionType: actionType,
      status: status ?? this.status,
      dueDate: dueDate,
      actionPlan: actionPlan,
      escalationPath: escalationPath,
      resolutionEvidence: resolutionEvidence,
      createdAt: createdAt,
    );
  }
}
