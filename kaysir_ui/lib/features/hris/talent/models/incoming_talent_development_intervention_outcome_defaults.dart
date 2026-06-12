import 'incoming_talent_development_intervention_models.dart';
import 'incoming_talent_development_intervention_outcome.dart';

IncomingTalentDevelopmentInterventionOutcomeDecision
defaultIncomingTalentDevelopmentInterventionOutcomeDecision(
  IncomingTalentDevelopmentInterventionAction action,
) {
  if (action.programCompletionExtensionCount > 0 &&
      !action.resolutionNote.toLowerCase().contains('closed')) {
    return IncomingTalentDevelopmentInterventionOutcomeDecision.monitor;
  }
  if (action.confidenceScore <= 2) {
    return IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized;
  }
  return IncomingTalentDevelopmentInterventionOutcomeDecision.improved;
}

int defaultIncomingTalentDevelopmentInterventionConfidenceAfter(
  IncomingTalentDevelopmentInterventionAction action,
) {
  final recovery =
      action.priority == IncomingTalentDevelopmentInterventionPriority.critical
          ? 2
          : 1;
  return (action.confidenceScore + recovery).clamp(1, 5);
}

int defaultIncomingTalentDevelopmentInterventionRemainingReleaseRisk(
  IncomingTalentDevelopmentInterventionAction action,
) {
  final note = action.resolutionNote.toLowerCase();
  if (note.contains('closed') ||
      note.contains('resolved') ||
      note.contains('recovered')) {
    return 0;
  }
  return action.programCompletionExtensionCount;
}

String defaultIncomingTalentDevelopmentInterventionEvidence(
  IncomingTalentDevelopmentInterventionAction action,
) {
  if (action.resolutionNote.isNotEmpty) return action.resolutionNote;
  if (action.releaseEvidenceCount > 0) {
    return '${action.releaseEvidenceCount} release evidence signals reviewed for ${action.candidateName}.';
  }
  return 'Manager and talent partner reviewed intervention evidence for ${action.candidateName}.';
}

String defaultIncomingTalentDevelopmentInterventionLearning(
  IncomingTalentDevelopmentInterventionAction action,
) {
  if (action.actionType ==
      IncomingTalentDevelopmentInterventionType.learningAdjustment) {
    return 'Learning adjustment clarified readiness gaps and follow-up ownership.';
  }
  if (action.actionType ==
      IncomingTalentDevelopmentInterventionType.escalation) {
    return 'Escalation improved ownership clarity and blocker response time.';
  }
  return 'Intervention produced reusable coaching insight for the next development review.';
}

String defaultIncomingTalentDevelopmentInterventionNextAction(
  IncomingTalentDevelopmentInterventionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentDevelopmentInterventionOutcomeDecision.improved =>
      'Archive outcome evidence and keep normal development cadence.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized =>
      'Schedule one light follow-up to confirm the improvement sustains.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.monitor =>
      'Create a follow-up review for remaining development risk.',
    IncomingTalentDevelopmentInterventionOutcomeDecision.escalate =>
      'Escalate unresolved development risk to HR and manager council.',
  };
}

DateTime defaultIncomingTalentDevelopmentInterventionNextReviewDate({
  required IncomingTalentDevelopmentInterventionOutcomeDecision decision,
  required DateTime reviewDate,
}) {
  final days = switch (decision) {
    IncomingTalentDevelopmentInterventionOutcomeDecision.improved => 45,
    IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized => 30,
    IncomingTalentDevelopmentInterventionOutcomeDecision.monitor => 14,
    IncomingTalentDevelopmentInterventionOutcomeDecision.escalate => 7,
  };
  return reviewDate.add(Duration(days: days));
}
