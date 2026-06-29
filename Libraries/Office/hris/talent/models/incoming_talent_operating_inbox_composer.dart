import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path.dart';
import 'incoming_talent_operating_inbox_item.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';
import 'incoming_talent_risk_council_queue_item.dart';
import 'incoming_talent_succession_coverage_council_follow_up.dart';
import 'incoming_talent_training_session.dart';

/// Builds a unified HR operating queue from active talent-management records.
List<IncomingTalentOperatingInboxItem> buildIncomingTalentOperatingInboxItems({
  required List<IncomingTalentRiskCouncilQueueItem> riskQueueItems,
  required List<IncomingTalentRiskCouncilDecision> riskDecisions,
  required List<IncomingTalentRiskCouncilFollowUp> riskFollowUps,
  required List<IncomingTalentTrainingSession> trainingSessions,
  required List<IncomingTalentCareerPathReview> careerPathReviews,
  required List<IncomingTalentSuccessionCoverageCouncilFollowUp>
  successionFollowUps,
  required List<IncomingTalentPromotionStabilizationFollowUpAction>
  promotionActions,
  required DateTime asOfDate,
}) {
  final items = <IncomingTalentOperatingInboxItem>[
    for (final item in riskQueueItems) _fromRiskQueueItem(item),
    for (final decision in riskDecisions) _fromRiskDecision(decision),
    for (final followUp in riskFollowUps.where((followUp) => followUp.isOpen))
      _fromRiskFollowUp(followUp),
    for (final session in trainingSessions.where(
      (session) => _shouldIncludeTrainingSession(session, asOfDate),
    ))
      _fromTrainingSession(session, asOfDate),
    for (final review in careerPathReviews.where(
      (review) => _shouldIncludeCareerPathReview(review, asOfDate),
    ))
      _fromCareerPathReview(review, asOfDate),
    for (final followUp in successionFollowUps.where(
      (followUp) => followUp.isOpen,
    ))
      _fromSuccessionFollowUp(followUp),
    for (final action in promotionActions.where((action) => !action.isClosed))
      _fromPromotionAction(action),
  ]..sort((left, right) => _compareInboxItems(left, right, asOfDate));

  return items;
}

IncomingTalentOperatingInboxItem _fromRiskQueueItem(
  IncomingTalentRiskCouncilQueueItem item,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'risk-queue:${item.id}',
    source: IncomingTalentOperatingInboxSource.riskCouncilDecision,
    priority:
        item.isCritical
            ? IncomingTalentOperatingInboxPriority.critical
            : IncomingTalentOperatingInboxPriority.watch,
    title: item.title,
    subjectName: item.candidateName,
    department: item.department,
    ownerName: '${item.department} Talent Partner',
    statusLabel: item.severity.label,
    nextAction: item.recommendedAction,
    dueDate: item.dueDate,
  );
}

IncomingTalentOperatingInboxItem _fromRiskDecision(
  IncomingTalentRiskCouncilDecision decision,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'risk-decision:${decision.id}',
    source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
    priority:
        decision.needsAttention
            ? IncomingTalentOperatingInboxPriority.critical
            : IncomingTalentOperatingInboxPriority.watch,
    title: 'Create risk council follow-up',
    subjectName: decision.candidateName,
    department: decision.department,
    ownerName: decision.ownerName,
    statusLabel: decision.outcome.label,
    nextAction: decision.commitmentSummary,
    dueDate: decision.followUpDate,
  );
}

IncomingTalentOperatingInboxItem _fromRiskFollowUp(
  IncomingTalentRiskCouncilFollowUp followUp,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'risk-follow-up:${followUp.id}',
    source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
    priority:
        followUp.needsAttention
            ? IncomingTalentOperatingInboxPriority.critical
            : IncomingTalentOperatingInboxPriority.watch,
    title: followUp.followUpType.label,
    subjectName: followUp.candidateName,
    department: followUp.department,
    ownerName: followUp.followUpOwnerName,
    statusLabel: followUp.status.label,
    nextAction: followUp.actionPlan,
    dueDate: followUp.dueDate,
  );
}

IncomingTalentOperatingInboxItem _fromTrainingSession(
  IncomingTalentTrainingSession session,
  DateTime asOfDate,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'training-session:${session.id}',
    source: IncomingTalentOperatingInboxSource.trainingSession,
    priority: _trainingPriority(session, asOfDate),
    title: session.programTitle,
    subjectName: session.sourceProgramTrack.label,
    department: session.department,
    ownerName: session.trainerName,
    statusLabel: session.status.label,
    nextAction: session.outcomeCheckpoint,
    dueDate: session.sessionDate,
  );
}

IncomingTalentOperatingInboxItem _fromCareerPathReview(
  IncomingTalentCareerPathReview review,
  DateTime asOfDate,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'career-review:${review.id}',
    source: IncomingTalentOperatingInboxSource.careerPathReview,
    priority: _careerReviewPriority(review, asOfDate),
    title: '${review.targetRole} career review',
    subjectName: review.candidateName,
    department: review.department,
    ownerName: review.reviewerName,
    statusLabel: review.decision.label,
    nextAction: review.nextAction,
    dueDate: review.nextReviewDate,
  );
}

IncomingTalentOperatingInboxItem _fromSuccessionFollowUp(
  IncomingTalentSuccessionCoverageCouncilFollowUp followUp,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'succession-follow-up:${followUp.id}',
    source: IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
    priority:
        followUp.needsAttention
            ? IncomingTalentOperatingInboxPriority.critical
            : IncomingTalentOperatingInboxPriority.watch,
    title: followUp.followUpType.label,
    subjectName: followUp.scopeLabel,
    department: followUp.departmentScope,
    ownerName: followUp.followUpOwnerName,
    statusLabel: followUp.status.label,
    nextAction: followUp.actionPlan,
    dueDate: followUp.dueDate,
  );
}

IncomingTalentOperatingInboxItem _fromPromotionAction(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  return IncomingTalentOperatingInboxItem(
    id: 'promotion-follow-up:${action.id}',
    source: IncomingTalentOperatingInboxSource.promotionStabilization,
    priority: _promotionActionPriority(action),
    title: action.actionType.label,
    subjectName: action.candidateName,
    department: action.department,
    ownerName: action.ownerName,
    statusLabel: action.status.label,
    nextAction: action.actionPlan,
    dueDate: action.dueDate,
  );
}

bool _shouldIncludeTrainingSession(
  IncomingTalentTrainingSession session,
  DateTime asOfDate,
) {
  if (session.isClosed) return false;
  return session.needsAttention ||
      _daysUntil(session.sessionDate, asOfDate) <= 14;
}

bool _shouldIncludeCareerPathReview(
  IncomingTalentCareerPathReview review,
  DateTime asOfDate,
) {
  return review.needsAttention ||
      _daysUntil(review.nextReviewDate, asOfDate) <= 14;
}

IncomingTalentOperatingInboxPriority _trainingPriority(
  IncomingTalentTrainingSession session,
  DateTime asOfDate,
) {
  if (session.needsAttention || _daysUntil(session.sessionDate, asOfDate) < 0) {
    return IncomingTalentOperatingInboxPriority.critical;
  }
  if (_daysUntil(session.sessionDate, asOfDate) <= 7) {
    return IncomingTalentOperatingInboxPriority.watch;
  }
  return IncomingTalentOperatingInboxPriority.routine;
}

IncomingTalentOperatingInboxPriority _careerReviewPriority(
  IncomingTalentCareerPathReview review,
  DateTime asOfDate,
) {
  if (review.decision == IncomingTalentCareerPathReviewDecision.blocked ||
      review.sourceStatus == IncomingTalentCareerPathStatus.blocked ||
      review.sourcePriority == IncomingTalentCareerPathPriority.critical ||
      _daysUntil(review.nextReviewDate, asOfDate) < 0) {
    return IncomingTalentOperatingInboxPriority.critical;
  }
  if (review.needsAttention ||
      _daysUntil(review.nextReviewDate, asOfDate) <= 7) {
    return IncomingTalentOperatingInboxPriority.watch;
  }
  return IncomingTalentOperatingInboxPriority.routine;
}

IncomingTalentOperatingInboxPriority _promotionActionPriority(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  if (action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.escalated ||
      action.priority ==
          IncomingTalentPromotionStabilizationFollowUpPriority.critical) {
    return IncomingTalentOperatingInboxPriority.critical;
  }
  if (action.needsAttention ||
      action.priority ==
          IncomingTalentPromotionStabilizationFollowUpPriority.high) {
    return IncomingTalentOperatingInboxPriority.watch;
  }
  return IncomingTalentOperatingInboxPriority.routine;
}

int _compareInboxItems(
  IncomingTalentOperatingInboxItem left,
  IncomingTalentOperatingInboxItem right,
  DateTime asOfDate,
) {
  final leftOverdue = left.isOverdue(asOfDate);
  final rightOverdue = right.isOverdue(asOfDate);
  if (leftOverdue != rightOverdue) return leftOverdue ? -1 : 1;

  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.title.compareTo(right.title);
}

int _daysUntil(DateTime dueDate, DateTime asOfDate) {
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(start).inDays;
}
