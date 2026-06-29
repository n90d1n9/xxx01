import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

IncomingTalentMobilityCadenceInterventionOutcomeDecision
defaultIncomingTalentMobilityCadenceInterventionOutcomeDecision(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  if (intervention.priority ==
          IncomingTalentMobilityCadenceInterventionPriority.urgent ||
      intervention.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.high) {
    return IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor;
  }
  if (intervention.hostConfidenceScore >= 4 &&
      intervention.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.low) {
    return IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered;
  }
  return IncomingTalentMobilityCadenceInterventionOutcomeDecision.stabilized;
}

IncomingTalentMobilityCadenceInterventionSustainability
defaultIncomingTalentMobilityCadenceInterventionSustainability(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  if (intervention.hostConfidenceScore <= 2 ||
      intervention.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.high) {
    return IncomingTalentMobilityCadenceInterventionSustainability.fragile;
  }
  if (intervention.hostConfidenceScore <= 3 ||
      intervention.residualRisk ==
          IncomingTalentMobilityStabilizationResidualRisk.moderate) {
    return IncomingTalentMobilityCadenceInterventionSustainability.moderate;
  }
  return IncomingTalentMobilityCadenceInterventionSustainability.strong;
}

IncomingTalentMobilityStabilizationResidualRisk
defaultIncomingTalentMobilityCadenceInterventionResidualRiskAfter(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  return switch (intervention.residualRisk) {
    IncomingTalentMobilityStabilizationResidualRisk.high =>
      IncomingTalentMobilityStabilizationResidualRisk.moderate,
    IncomingTalentMobilityStabilizationResidualRisk.moderate =>
      IncomingTalentMobilityStabilizationResidualRisk.low,
    IncomingTalentMobilityStabilizationResidualRisk.low =>
      IncomingTalentMobilityStabilizationResidualRisk.low,
  };
}

int defaultIncomingTalentMobilityCadenceInterventionConfidenceAfter(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  return (intervention.hostConfidenceScore + 1).clamp(1, 5);
}

DateTime defaultIncomingTalentMobilityCadenceInterventionNextReviewDate({
  required IncomingTalentMobilityCadenceInterventionOutcomeDecision decision,
  required DateTime asOfDate,
}) {
  return switch (decision) {
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered =>
      asOfDate.add(const Duration(days: 60)),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.stabilized =>
      asOfDate.add(const Duration(days: 30)),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor => asOfDate
        .add(const Duration(days: 14)),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate =>
      asOfDate.add(const Duration(days: 7)),
  };
}

String defaultIncomingTalentMobilityCadenceInterventionOutcomeEvidence(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  return 'Resolved ${intervention.interventionType.label.toLowerCase()} with evidence against ${intervention.successMeasure.toLowerCase()}.';
}

String defaultIncomingTalentMobilityCadenceInterventionOutcomeLearning(
  IncomingTalentMobilityCadenceIntervention intervention,
) {
  return 'Capture what changed confidence from ${intervention.hostConfidenceScore}/5 and update mobility recovery playbooks.';
}

String defaultIncomingTalentMobilityCadenceInterventionNextAction(
  IncomingTalentMobilityCadenceInterventionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered =>
      'Return to standard mobility cadence and archive the recovery pattern.',
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.stabilized =>
      'Keep manager support active through the next cadence review.',
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor =>
      'Monitor residual risk weekly and confirm host confidence recovery.',
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate =>
      'Escalate unresolved mobility risk to HR leadership immediately.',
  };
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeStatus(
  IncomingTalentMobilityCadenceInterventionStatus? value,
) {
  if (value == null) return 'Select intervention status';
  if (value != IncomingTalentMobilityCadenceInterventionStatus.resolved) {
    return 'Intervention must be resolved before outcome';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeDecision(
  IncomingTalentMobilityCadenceInterventionOutcomeDecision? value,
) {
  if (value == null) return 'Select outcome decision';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionSustainability(
  IncomingTalentMobilityCadenceInterventionSustainability? value,
) {
  if (value == null) return 'Select sustainability';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeRisk(
  IncomingTalentMobilityStabilizationResidualRisk? value,
) {
  if (value == null) return 'Select residual risk';
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeConfidence(
  int value,
) {
  if (value < 1 || value > 5) {
    return 'Host confidence must be between 1 and 5';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeReviewDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select review date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Review date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeNextReviewDate(
  DateTime? reviewDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (reviewDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
    return 'Next review date must be after review date';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeEvidence(
  String? value,
) {
  return _validateLongText(value, 'evidence summary');
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeLearning(
  String? value,
) {
  return _validateLongText(value, 'learning summary');
}

String? validateIncomingTalentMobilityCadenceInterventionOutcomeNextAction(
  String? value,
) {
  return _validateLongText(value, 'next cadence action');
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      validateIncomingTalentMobilityCadenceInterventionOutcomeRequired(
        value,
        label,
      );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
