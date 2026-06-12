import 'incoming_talent_profile_timeline_models.dart';
import 'incoming_talent_risk_council_queue_item.dart';

List<IncomingTalentRiskCouncilQueueItem> buildIncomingTalentRiskCouncilQueue({
  required List<IncomingTalentProfileTimeline> timelines,
  required DateTime asOfDate,
}) {
  final items = <IncomingTalentRiskCouncilQueueItem>[
    for (final timeline in timelines) ..._itemsForTimeline(timeline, asOfDate),
  ]..sort(compareIncomingTalentRiskCouncilQueueItems);

  return items;
}

int compareIncomingTalentRiskCouncilQueueItems(
  IncomingTalentRiskCouncilQueueItem left,
  IncomingTalentRiskCouncilQueueItem right,
) {
  final severity = left.severity.index.compareTo(right.severity.index);
  if (severity != 0) return severity;

  final signalCount = right.signalCount.compareTo(left.signalCount);
  if (signalCount != 0) return signalCount;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.candidateName.compareTo(right.candidateName);
}

List<IncomingTalentRiskCouncilQueueItem> _itemsForTimeline(
  IncomingTalentProfileTimeline timeline,
  DateTime asOfDate,
) {
  final dueDate = timeline.latestEventDate ?? asOfDate;

  return [
    if (timeline.openInterventionCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:intervention',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.intervention,
        severity: _severityForCount(timeline.openInterventionCount),
        title: 'Open development interventions',
        detail:
            '${timeline.openInterventionCount} interventions still need owner closure.',
        recommendedAction: 'Confirm blockers, owner, and closure date.',
        dueDate: dueDate,
        signalCount: timeline.openInterventionCount,
        source: IncomingTalentRiskCouncilQueueSource.developmentIntervention,
      ),
    if (timeline.watchDevelopmentResolutionCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:resolution-review',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
        severity: IncomingTalentRiskCouncilQueueSeverity.critical,
        title: 'Follow-up resolution review risk',
        detail:
            '${timeline.watchDevelopmentResolutionCount} resolution reviews still carry risk.',
        recommendedAction:
            'Decide whether to escalate, reopen, or approve monitoring.',
        dueDate: dueDate,
        signalCount: timeline.watchDevelopmentResolutionCount,
        source:
            IncomingTalentRiskCouncilQueueSource.developmentResolutionReview,
      ),
    if (timeline.watchPromotionResolutionCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:promotion-resolution-review',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
        severity: _promotionResolutionSeverity(timeline),
        title: 'Promotion resolution review risk',
        detail:
            '${timeline.watchPromotionResolutionCount} promotion resolution reviews still carry residual role risk.',
        recommendedAction:
            'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
        dueDate: _eventDueDate(
          timeline,
          IncomingTalentProfileTimelineEventType.promotionFollowUpResolution,
          dueDate,
        ),
        signalCount: timeline.watchPromotionResolutionCount,
        source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
      ),
    if (timeline.watchDevelopmentFollowUpCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:follow-up',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.followUp,
        severity: _severityForCount(timeline.watchDevelopmentFollowUpCount),
        title: 'Intervention outcome follow-ups',
        detail:
            '${timeline.watchDevelopmentFollowUpCount} follow-ups are due, overdue, or escalated.',
        recommendedAction: 'Assign follow-up owner and review evidence.',
        dueDate: dueDate,
        signalCount: timeline.watchDevelopmentFollowUpCount,
        source: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
      ),
    if (timeline.watchDevelopmentOutcomeCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:outcome',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.followUp,
        severity: _severityForCount(timeline.watchDevelopmentOutcomeCount),
        title: 'Development intervention outcomes',
        detail:
            '${timeline.watchDevelopmentOutcomeCount} outcomes need release-risk follow-up.',
        recommendedAction: 'Confirm outcome evidence and next review path.',
        dueDate: dueDate,
        signalCount: timeline.watchDevelopmentOutcomeCount,
        source: IncomingTalentRiskCouncilQueueSource.developmentOutcome,
      ),
    if (timeline.openCareerSupportCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:career-support-action',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.careerSupport,
        severity: _severityForCount(timeline.openCareerSupportCount),
        title: 'Open career support actions',
        detail:
            '${timeline.openCareerSupportCount} career support actions need closure.',
        recommendedAction:
            'Validate support owner, target level, and evidence.',
        dueDate: dueDate,
        signalCount: timeline.openCareerSupportCount,
        source: IncomingTalentRiskCouncilQueueSource.careerSupportAction,
      ),
    if (timeline.watchCareerSupportOutcomeCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:career-support-outcome',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.careerSupport,
        severity: _severityForCount(timeline.watchCareerSupportOutcomeCount),
        title: 'Career support outcomes on watch',
        detail:
            '${timeline.watchCareerSupportOutcomeCount} career support outcomes carry residual risk.',
        recommendedAction: 'Decide whether to continue, escalate, or close.',
        dueDate: dueDate,
        signalCount: timeline.watchCareerSupportOutcomeCount,
        source: IncomingTalentRiskCouncilQueueSource.careerSupportOutcome,
      ),
    if (timeline.programMilestoneRevisionCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:program-milestone',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.program,
        severity: _severityForCount(timeline.programMilestoneRevisionCount),
        title: 'Program milestone revisions',
        detail:
            '${timeline.programMilestoneRevisionCount} milestones need revision before evidence can be accepted.',
        recommendedAction: 'Confirm revision owner and acceptance criteria.',
        dueDate: dueDate,
        signalCount: timeline.programMilestoneRevisionCount,
        source: IncomingTalentRiskCouncilQueueSource.programMilestone,
      ),
    if (timeline.programCompletionExtensionCount > 0)
      IncomingTalentRiskCouncilQueueItem(
        id: 'risk-council:${timeline.candidateId}:program-completion',
        candidateId: timeline.candidateId,
        candidateName: timeline.candidateName,
        role: timeline.role,
        department: timeline.department,
        category: IncomingTalentRiskCouncilQueueCategory.program,
        severity: IncomingTalentRiskCouncilQueueSeverity.critical,
        title: 'Program completion extension',
        detail:
            '${timeline.programCompletionExtensionCount} program completion decisions extended.',
        recommendedAction: 'Decide extension owner, credential path, and date.',
        dueDate: dueDate,
        signalCount: timeline.programCompletionExtensionCount,
        source: IncomingTalentRiskCouncilQueueSource.programCompletion,
      ),
  ];
}

IncomingTalentRiskCouncilQueueSeverity _promotionResolutionSeverity(
  IncomingTalentProfileTimeline timeline,
) {
  final hasCriticalResolutionEvent = timeline.events.any(
    (event) =>
        event.type ==
            IncomingTalentProfileTimelineEventType
                .promotionFollowUpResolution &&
        event.tone == IncomingTalentProfileTimelineEventTone.critical,
  );
  if (hasCriticalResolutionEvent) {
    return IncomingTalentRiskCouncilQueueSeverity.critical;
  }
  return _severityForCount(timeline.watchPromotionResolutionCount);
}

DateTime _eventDueDate(
  IncomingTalentProfileTimeline timeline,
  IncomingTalentProfileTimelineEventType eventType,
  DateTime fallback,
) {
  final matchingEvents =
      timeline.events.where((event) => event.type == eventType).toList()
        ..sort((left, right) => right.eventDate.compareTo(left.eventDate));

  if (matchingEvents.isEmpty) return fallback;
  return matchingEvents.first.eventDate;
}

IncomingTalentRiskCouncilQueueSeverity _severityForCount(int count) {
  if (count > 1) return IncomingTalentRiskCouncilQueueSeverity.critical;
  return IncomingTalentRiskCouncilQueueSeverity.watch;
}
