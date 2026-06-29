/// Urgency level used to prioritize items in the talent risk council queue.
enum IncomingTalentRiskCouncilQueueSeverity {
  critical('Critical'),
  watch('Watch');

  final String label;

  const IncomingTalentRiskCouncilQueueSeverity(this.label);
}

/// Operational category that explains why a talent risk needs council review.
enum IncomingTalentRiskCouncilQueueCategory {
  intervention('Intervention'),
  followUp('Follow-up'),
  resolutionReview('Resolution review'),
  careerSupport('Career support'),
  program('Program');

  final String label;

  const IncomingTalentRiskCouncilQueueCategory(this.label);
}

/// Source signal that produced the talent risk council queue item.
enum IncomingTalentRiskCouncilQueueSource {
  general('General'),
  developmentIntervention('Development intervention'),
  developmentResolutionReview('Development resolution review'),
  promotionResolutionReview('Promotion resolution review'),
  developmentFollowUp('Development follow-up'),
  developmentOutcome('Development outcome'),
  careerSupportAction('Career support action'),
  careerSupportOutcome('Career support outcome'),
  programMilestone('Program milestone'),
  programCompletion('Program completion');

  final String label;

  const IncomingTalentRiskCouncilQueueSource(this.label);
}

/// Queue item that turns profile timeline signals into council-ready work.
class IncomingTalentRiskCouncilQueueItem {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final IncomingTalentRiskCouncilQueueCategory category;
  final IncomingTalentRiskCouncilQueueSeverity severity;
  final String title;
  final String detail;
  final String recommendedAction;
  final DateTime dueDate;
  final int signalCount;
  final IncomingTalentRiskCouncilQueueSource source;

  const IncomingTalentRiskCouncilQueueItem({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.category,
    required this.severity,
    required this.title,
    required this.detail,
    required this.recommendedAction,
    required this.dueDate,
    required this.signalCount,
    this.source = IncomingTalentRiskCouncilQueueSource.general,
  });

  bool get isCritical {
    return severity == IncomingTalentRiskCouncilQueueSeverity.critical;
  }

  /// Whether this item came from a promotion stabilization resolution review.
  bool get isPromotionResolutionReview {
    return source ==
        IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;
  }

  double get urgencyRatio {
    if (isCritical) return 1;
    return 0.62;
  }
}
