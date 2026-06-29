import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_activation_follow_up_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention.dart';

class IncomingTalentDevelopmentInterventionDefaults {
  final IncomingTalentDevelopmentInterventionType actionType;
  final IncomingTalentDevelopmentInterventionPriority priority;
  final Duration dueInterval;
  final String action;
  final String successCriteria;

  const IncomingTalentDevelopmentInterventionDefaults({
    required this.actionType,
    required this.priority,
    required this.dueInterval,
    required this.action,
    required this.successCriteria,
  });

  factory IncomingTalentDevelopmentInterventionDefaults.fromCheckIn(
    IncomingTalentDevelopmentCheckIn checkIn,
  ) {
    return IncomingTalentDevelopmentInterventionDefaults(
      actionType: _typeFromCheckIn(checkIn),
      priority: _priorityFromCheckIn(checkIn),
      dueInterval: _dueIntervalFromCheckIn(checkIn),
      action: _actionFromCheckIn(checkIn),
      successCriteria: _successCriteriaFromCheckIn(checkIn),
    );
  }

  factory IncomingTalentDevelopmentInterventionDefaults.fromFollowUp(
    IncomingTalentActivationFollowUpAction action,
  ) {
    return IncomingTalentDevelopmentInterventionDefaults(
      actionType: _typeFromFollowUp(action),
      priority: _priorityFromFollowUp(action),
      dueInterval: _dueIntervalFromFollowUp(action),
      action: _actionFromFollowUp(action),
      successCriteria: _successCriteriaFromFollowUp(action),
    );
  }
}

IncomingTalentDevelopmentInterventionType _typeFromCheckIn(
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.blocked) {
    return checkIn.retentionRisk == IncomingTalentActivationRetentionRisk.high
        ? IncomingTalentDevelopmentInterventionType.escalation
        : IncomingTalentDevelopmentInterventionType.unblocker;
  }
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.watch) {
    return IncomingTalentDevelopmentInterventionType.coaching;
  }
  return IncomingTalentDevelopmentInterventionType.roleShadowing;
}

IncomingTalentDevelopmentInterventionPriority _priorityFromCheckIn(
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.blocked ||
      checkIn.retentionRisk == IncomingTalentActivationRetentionRisk.high ||
      checkIn.confidenceScore <= 2) {
    return IncomingTalentDevelopmentInterventionPriority.critical;
  }
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.watch ||
      checkIn.confidenceScore <= 3) {
    return IncomingTalentDevelopmentInterventionPriority.high;
  }
  return IncomingTalentDevelopmentInterventionPriority.medium;
}

Duration _dueIntervalFromCheckIn(IncomingTalentDevelopmentCheckIn checkIn) {
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.blocked ||
      checkIn.confidenceScore <= 2) {
    return const Duration(days: 7);
  }
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.watch ||
      checkIn.confidenceScore <= 3) {
    return const Duration(days: 10);
  }
  return const Duration(days: 14);
}

String _actionFromCheckIn(IncomingTalentDevelopmentCheckIn checkIn) {
  return switch (checkIn.trend) {
    IncomingTalentDevelopmentCheckInTrend.blocked =>
      'Escalate blockers and confirm ownership for ${checkIn.candidateName}.',
    IncomingTalentDevelopmentCheckInTrend.watch =>
      'Run focused coaching on ${checkIn.nextAction.toLowerCase()}',
    IncomingTalentDevelopmentCheckInTrend.steady =>
      'Reinforce progress through mentor-guided role practice.',
    IncomingTalentDevelopmentCheckInTrend.improving =>
      'Capture improvement evidence and prepare calibration notes.',
  };
}

String _successCriteriaFromCheckIn(IncomingTalentDevelopmentCheckIn checkIn) {
  return switch (checkIn.trend) {
    IncomingTalentDevelopmentCheckInTrend.blocked =>
      'Blockers resolved and confidence restored above 3/5.',
    IncomingTalentDevelopmentCheckInTrend.watch =>
      'Manager confirms progress and confidence reaches 4/5.',
    IncomingTalentDevelopmentCheckInTrend.steady =>
      'Roadmap milestone remains on cadence with mentor sign-off.',
    IncomingTalentDevelopmentCheckInTrend.improving =>
      'Improvement evidence is ready for the next talent review.',
  };
}

IncomingTalentDevelopmentInterventionType _typeFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.programCompletionExtensionCount > 0 ||
      action.actionType ==
          IncomingTalentActivationFollowUpType.learningAdjustment) {
    return IncomingTalentDevelopmentInterventionType.learningAdjustment;
  }
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return IncomingTalentDevelopmentInterventionType.escalation;
  }
  if (action.actionType == IncomingTalentActivationFollowUpType.accessBlocker) {
    return IncomingTalentDevelopmentInterventionType.unblocker;
  }
  return IncomingTalentDevelopmentInterventionType.coaching;
}

IncomingTalentDevelopmentInterventionPriority _priorityFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked ||
      action.programCompletionExtensionCount > 0) {
    return IncomingTalentDevelopmentInterventionPriority.critical;
  }
  if (action.status == IncomingTalentActivationFollowUpStatus.inProgress) {
    return IncomingTalentDevelopmentInterventionPriority.high;
  }
  return IncomingTalentDevelopmentInterventionPriority.medium;
}

Duration _dueIntervalFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return const Duration(days: 3);
  }
  if (action.programCompletionExtensionCount > 0) {
    return const Duration(days: 7);
  }
  return const Duration(days: 10);
}

String _actionFromFollowUp(IncomingTalentActivationFollowUpAction action) {
  final extensionCount = action.programCompletionExtensionCount;
  if (extensionCount > 0) {
    return 'Run a targeted learning adjustment for ${action.candidateName} '
        'and close $extensionCount program extension ${_decisionNoun(extensionCount)}.';
  }
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return 'Escalate activation blockers and confirm development ownership for ${action.candidateName}.';
  }
  return 'Convert activation follow-up into manager-owned coaching for ${action.candidateName}.';
}

String _successCriteriaFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.programCompletionExtensionCount > 0) {
    return 'Program extension decisions closed and role readiness evidence restored.';
  }
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return 'Activation blocker removed and next development review has an owner.';
  }
  return 'Manager confirms activation progress and next development step is clear.';
}

String _decisionNoun(int count) {
  return count == 1 ? 'decision' : 'decisions';
}
