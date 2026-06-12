enum IncomingTalentProfileTimelineEventType {
  outcome('Outcome'),
  roadmap('Roadmap'),
  checkIn('Check-in'),
  intervention('Intervention'),
  interventionOutcome('Intervention outcome'),
  interventionOutcomeFollowUp('Outcome follow-up'),
  interventionOutcomeFollowUpResolution('Follow-up review'),
  calibration('Calibration'),
  careerSupportAction('Career support'),
  careerSupportOutcome('Support outcome'),
  programMilestone('Program milestone'),
  programCompletion('Program completion'),
  promotionStabilization('Promotion stabilization'),
  promotionFollowUp('Promotion follow-up'),
  promotionFollowUpResolution('Promotion resolution');

  final String label;

  const IncomingTalentProfileTimelineEventType(this.label);
}

enum IncomingTalentProfileTimelineEventTone {
  positive,
  neutral,
  watch,
  critical,
}

/// Single dated profile event shown in the HRIS talent timeline.
class IncomingTalentProfileTimelineEvent {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final IncomingTalentProfileTimelineEventType type;
  final IncomingTalentProfileTimelineEventTone tone;
  final String title;
  final String description;
  final DateTime eventDate;
  final String statusLabel;

  const IncomingTalentProfileTimelineEvent({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.type,
    required this.tone,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.statusLabel,
  });

  bool get needsAttention {
    return tone == IncomingTalentProfileTimelineEventTone.watch ||
        tone == IncomingTalentProfileTimelineEventTone.critical;
  }
}

/// Aggregated candidate timeline with action counters and next-step guidance.
class IncomingTalentProfileTimeline {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final int readinessScore;
  final int confidenceScore;
  final int openInterventionCount;
  final int watchDevelopmentOutcomeCount;
  final int openDevelopmentFollowUpCount;
  final int watchDevelopmentFollowUpCount;
  final int watchDevelopmentResolutionCount;
  final int openCareerSupportCount;
  final int watchCareerSupportOutcomeCount;
  final int programMilestoneRevisionCount;
  final int programCompletionExtensionCount;
  final int watchPromotionStabilizationCount;
  final int openPromotionFollowUpCount;
  final int watchPromotionFollowUpCount;
  final int watchPromotionResolutionCount;
  final String latestCalibrationDecisionLabel;
  final String nextAction;
  final List<IncomingTalentProfileTimelineEvent> events;

  const IncomingTalentProfileTimeline({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.readinessScore,
    required this.confidenceScore,
    required this.openInterventionCount,
    required this.watchDevelopmentOutcomeCount,
    required this.openDevelopmentFollowUpCount,
    required this.watchDevelopmentFollowUpCount,
    required this.watchDevelopmentResolutionCount,
    required this.openCareerSupportCount,
    required this.watchCareerSupportOutcomeCount,
    required this.programMilestoneRevisionCount,
    required this.programCompletionExtensionCount,
    this.watchPromotionStabilizationCount = 0,
    this.openPromotionFollowUpCount = 0,
    this.watchPromotionFollowUpCount = 0,
    this.watchPromotionResolutionCount = 0,
    required this.latestCalibrationDecisionLabel,
    required this.nextAction,
    required this.events,
  });

  bool get needsAttention {
    return openInterventionCount > 0 ||
        watchDevelopmentOutcomeCount > 0 ||
        openDevelopmentFollowUpCount > 0 ||
        watchDevelopmentFollowUpCount > 0 ||
        watchDevelopmentResolutionCount > 0 ||
        openCareerSupportCount > 0 ||
        watchCareerSupportOutcomeCount > 0 ||
        programMilestoneRevisionCount > 0 ||
        programCompletionExtensionCount > 0 ||
        watchPromotionStabilizationCount > 0 ||
        openPromotionFollowUpCount > 0 ||
        watchPromotionFollowUpCount > 0 ||
        watchPromotionResolutionCount > 0 ||
        events.any((event) => event.needsAttention);
  }

  DateTime? get latestEventDate {
    return events.isEmpty ? null : events.first.eventDate;
  }

  double get readinessRatio => readinessScore / 100;

  double get confidenceRatio => confidenceScore / 5;

  bool get hasCalibration {
    return latestCalibrationDecisionLabel != 'Not calibrated';
  }

  int get openTalentActionCount {
    return openInterventionCount +
        openDevelopmentFollowUpCount +
        openCareerSupportCount +
        openPromotionFollowUpCount;
  }
}
