import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_action_outcome.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

enum IncomingTalentSuccessionCoverageGovernanceStage {
  actionRequired('Action required'),
  actionOpen('Action open'),
  outcomeReview('Outcome review'),
  outcomeWatch('Outcome watch'),
  closed('Closed');

  final String label;

  const IncomingTalentSuccessionCoverageGovernanceStage(this.label);
}

enum IncomingTalentSuccessionCoverageGovernanceRiskLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const IncomingTalentSuccessionCoverageGovernanceRiskLevel(this.label);
}

class IncomingTalentSuccessionCoverageGovernanceRecord {
  final String id;
  final String reviewId;
  final String? actionId;
  final String? outcomeId;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String ownerName;
  final IncomingTalentSuccessionCoverageGovernanceStage stage;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel;
  final IncomingTalentSuccessionCoverageReviewDecision reviewDecision;
  final IncomingTalentSuccessionCoverageHealth coverageHealth;
  final int coverageScore;
  final IncomingTalentSuccessionCoverageActionType? actionType;
  final IncomingTalentSuccessionCoverageActionStatus? actionStatus;
  final IncomingTalentSuccessionCoverageActionOutcomeDecision? outcomeDecision;
  final IncomingTalentSuccessionCoverageActionResidualRisk? residualRisk;
  final DateTime openedAt;
  final DateTime dueDate;
  final String nextAction;
  final String evidenceSummary;

  const IncomingTalentSuccessionCoverageGovernanceRecord({
    required this.id,
    required this.reviewId,
    required this.actionId,
    required this.outcomeId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.attentionOnly,
    required this.ownerName,
    required this.stage,
    required this.riskLevel,
    required this.reviewDecision,
    required this.coverageHealth,
    required this.coverageScore,
    required this.actionType,
    required this.actionStatus,
    required this.outcomeDecision,
    required this.residualRisk,
    required this.openedAt,
    required this.dueDate,
    required this.nextAction,
    required this.evidenceSummary,
  });

  factory IncomingTalentSuccessionCoverageGovernanceRecord.fromChain({
    required IncomingTalentSuccessionCoverageReview review,
    IncomingTalentSuccessionCoverageAction? action,
    IncomingTalentSuccessionCoverageActionOutcome? outcome,
  }) {
    final stage = _stageFor(action: action, outcome: outcome);

    return IncomingTalentSuccessionCoverageGovernanceRecord(
      id: 'coverage-governance:${review.id}',
      reviewId: review.id,
      actionId: action?.id,
      outcomeId: outcome?.id,
      scopeLabel: review.scopeLabel,
      departmentScope: review.departmentScope,
      attentionOnly: review.attentionOnly,
      ownerName:
          outcome?.reviewerName ?? action?.ownerName ?? review.reviewerName,
      stage: stage,
      riskLevel: _riskFor(review: review, action: action, outcome: outcome),
      reviewDecision: review.decision,
      coverageHealth: review.coverageHealth,
      coverageScore:
          outcome?.coverageScoreAfter ??
          action?.coverageScore ??
          review.coverageScore,
      actionType: action?.actionType,
      actionStatus: action?.status,
      outcomeDecision: outcome?.decision,
      residualRisk: outcome?.residualRisk,
      openedAt: review.reviewDate,
      dueDate: _dueDateFor(
        stage: stage,
        review: review,
        action: action,
        outcome: outcome,
      ),
      nextAction: _nextActionFor(
        stage: stage,
        review: review,
        action: action,
        outcome: outcome,
      ),
      evidenceSummary:
          outcome?.evidenceSummary ??
          action?.resolutionEvidence ??
          review.executiveCommitment,
    );
  }

  bool get isClosed {
    return stage == IncomingTalentSuccessionCoverageGovernanceStage.closed;
  }

  bool get needsAttention {
    return !isClosed ||
        riskLevel == IncomingTalentSuccessionCoverageGovernanceRiskLevel.high ||
        riskLevel ==
            IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical;
  }

  double get coverageRatio => coverageScore / 100;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return !isClosed && days >= 0 && days <= 7;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isClosed && daysUntilDue(asOfDate) < 0;
  }
}

IncomingTalentSuccessionCoverageGovernanceStage _stageFor({
  required IncomingTalentSuccessionCoverageAction? action,
  required IncomingTalentSuccessionCoverageActionOutcome? outcome,
}) {
  if (action == null) {
    return IncomingTalentSuccessionCoverageGovernanceStage.actionRequired;
  }
  if (action.status != IncomingTalentSuccessionCoverageActionStatus.resolved) {
    return IncomingTalentSuccessionCoverageGovernanceStage.actionOpen;
  }
  if (outcome == null) {
    return IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview;
  }
  if (outcome.needsAttention) {
    return IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch;
  }
  return IncomingTalentSuccessionCoverageGovernanceStage.closed;
}

IncomingTalentSuccessionCoverageGovernanceRiskLevel _riskFor({
  required IncomingTalentSuccessionCoverageReview review,
  IncomingTalentSuccessionCoverageAction? action,
  IncomingTalentSuccessionCoverageActionOutcome? outcome,
}) {
  if (outcome != null) return _outcomeRisk(outcome);
  if (action != null) return _actionRisk(action);

  if (review.decision ==
          IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation ||
      review.coverageHealth ==
          IncomingTalentSuccessionCoverageHealth.critical) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical;
  }
  if (review.decision ==
          IncomingTalentSuccessionCoverageReviewDecision.rework ||
      review.attentionSignalCount > 1) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.high;
  }
  if (review.needsAttention) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium;
  }
  return IncomingTalentSuccessionCoverageGovernanceRiskLevel.low;
}

IncomingTalentSuccessionCoverageGovernanceRiskLevel _actionRisk(
  IncomingTalentSuccessionCoverageAction action,
) {
  if (action.status == IncomingTalentSuccessionCoverageActionStatus.blocked) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical;
  }
  if (action.coverageHealth ==
      IncomingTalentSuccessionCoverageHealth.critical) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.high;
  }
  if (action.coverageHealth == IncomingTalentSuccessionCoverageHealth.watch ||
      action.status == IncomingTalentSuccessionCoverageActionStatus.planned) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium;
  }
  return IncomingTalentSuccessionCoverageGovernanceRiskLevel.low;
}

IncomingTalentSuccessionCoverageGovernanceRiskLevel _outcomeRisk(
  IncomingTalentSuccessionCoverageActionOutcome outcome,
) {
  if (outcome.decision ==
          IncomingTalentSuccessionCoverageActionOutcomeDecision
              .executiveReview ||
      outcome.residualRisk ==
          IncomingTalentSuccessionCoverageActionResidualRisk.high ||
      outcome.coverageScoreAfter < 50) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical;
  }
  if (outcome.needsAttention) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.high;
  }
  if (outcome.residualRisk ==
      IncomingTalentSuccessionCoverageActionResidualRisk.medium) {
    return IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium;
  }
  return IncomingTalentSuccessionCoverageGovernanceRiskLevel.low;
}

DateTime _dueDateFor({
  required IncomingTalentSuccessionCoverageGovernanceStage stage,
  required IncomingTalentSuccessionCoverageReview review,
  IncomingTalentSuccessionCoverageAction? action,
  IncomingTalentSuccessionCoverageActionOutcome? outcome,
}) {
  return switch (stage) {
    IncomingTalentSuccessionCoverageGovernanceStage.actionRequired =>
      review.nextReviewDate,
    IncomingTalentSuccessionCoverageGovernanceStage.actionOpen =>
      action!.dueDate,
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview =>
      action!.dueDate,
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch =>
      outcome!.nextReviewDate,
    IncomingTalentSuccessionCoverageGovernanceStage.closed =>
      outcome!.nextReviewDate,
  };
}

String _nextActionFor({
  required IncomingTalentSuccessionCoverageGovernanceStage stage,
  required IncomingTalentSuccessionCoverageReview review,
  IncomingTalentSuccessionCoverageAction? action,
  IncomingTalentSuccessionCoverageActionOutcome? outcome,
}) {
  return switch (stage) {
    IncomingTalentSuccessionCoverageGovernanceStage.actionRequired =>
      'Create coverage action for ${review.scopeLabel}.',
    IncomingTalentSuccessionCoverageGovernanceStage.actionOpen =>
      action!.status == IncomingTalentSuccessionCoverageActionStatus.blocked
          ? 'Unblock ${action.scopeLabel} coverage action.'
          : 'Complete ${action.actionType.label.toLowerCase()} action.',
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview =>
      'Review resolved coverage action evidence.',
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch =>
      outcome!.nextCoverageAction,
    IncomingTalentSuccessionCoverageGovernanceStage.closed =>
      'Keep coverage evidence archived for the next council.',
  };
}
