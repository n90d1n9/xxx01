import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_stabilization_action.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

IncomingTalentMobilityStabilizationOutcomeDecision
defaultIncomingTalentMobilityStabilizationOutcomeDecision(
  IncomingTalentMobilityStabilizationAction action,
) {
  if (action.retentionRisk ==
      IncomingTalentMobilityFirstReviewRetentionRisk.high) {
    return IncomingTalentMobilityStabilizationOutcomeDecision.monitor;
  }
  if (action.reviewOutcome ==
      IncomingTalentMobilityFirstReviewOutcome.blocked) {
    return IncomingTalentMobilityStabilizationOutcomeDecision.improved;
  }
  return IncomingTalentMobilityStabilizationOutcomeDecision.resolved;
}

IncomingTalentMobilityStabilizationResidualRisk
defaultIncomingTalentMobilityStabilizationResidualRisk(
  IncomingTalentMobilityStabilizationAction action,
) {
  return switch (action.retentionRisk) {
    IncomingTalentMobilityFirstReviewRetentionRisk.low =>
      IncomingTalentMobilityStabilizationResidualRisk.low,
    IncomingTalentMobilityFirstReviewRetentionRisk.moderate =>
      IncomingTalentMobilityStabilizationResidualRisk.low,
    IncomingTalentMobilityFirstReviewRetentionRisk.high =>
      IncomingTalentMobilityStabilizationResidualRisk.moderate,
  };
}

int defaultIncomingTalentMobilityStabilizationConfidenceAfter(
  IncomingTalentMobilityStabilizationAction action,
) {
  return (action.hostConfidenceScore + 1).clamp(1, 5);
}

DateTime defaultIncomingTalentMobilityStabilizationOutcomeNextReviewDate({
  required IncomingTalentMobilityStabilizationOutcomeDecision decision,
  required DateTime asOfDate,
}) {
  return switch (decision) {
    IncomingTalentMobilityStabilizationOutcomeDecision.resolved => asOfDate.add(
      const Duration(days: 45),
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.improved => asOfDate.add(
      const Duration(days: 30),
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.monitor => asOfDate.add(
      const Duration(days: 14),
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.escalate => asOfDate.add(
      const Duration(days: 7),
    ),
  };
}

String defaultIncomingTalentMobilityStabilizationOutcomeEvidence(
  IncomingTalentMobilityStabilizationAction action,
) {
  return 'Completed ${action.actionType.label.toLowerCase()} with evidence against ${action.successMeasure.toLowerCase()}.';
}

String defaultIncomingTalentMobilityStabilizationOutcomeLearning(
  IncomingTalentMobilityStabilizationAction action,
) {
  return 'Capture what changed host confidence from ${action.hostConfidenceScore}/5 and update mobility playbooks.';
}

String defaultIncomingTalentMobilityStabilizationOutcomeNextAction(
  IncomingTalentMobilityStabilizationOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentMobilityStabilizationOutcomeDecision.resolved =>
      'Return to standard mobility cadence with manager check-ins.',
    IncomingTalentMobilityStabilizationOutcomeDecision.improved =>
      'Extend support through the next review and confirm sustained confidence.',
    IncomingTalentMobilityStabilizationOutcomeDecision.monitor =>
      'Monitor residual risk weekly and keep sponsor support active.',
    IncomingTalentMobilityStabilizationOutcomeDecision.escalate =>
      'Escalate mobility risk to HR leadership for resolution support.',
  };
}

String? validateIncomingTalentMobilityStabilizationOutcomeRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeActionStatus(
  IncomingTalentMobilityStabilizationStatus? value,
) {
  if (value == null) return 'Select action status';
  if (value != IncomingTalentMobilityStabilizationStatus.completed) {
    return 'Action must be completed before outcome';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeDecision(
  IncomingTalentMobilityStabilizationOutcomeDecision? value,
) {
  if (value == null) return 'Select outcome decision';
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeResidualRisk(
  IncomingTalentMobilityStabilizationResidualRisk? value,
) {
  if (value == null) return 'Select residual risk';
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeConfidence(
  int value,
) {
  if (value < 1 || value > 5) {
    return 'Host confidence must be between 1 and 5';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select outcome date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Outcome date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeNextReviewDate(
  DateTime? outcomeDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (outcomeDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(outcomeDate))) {
    return 'Next review date must be after outcome date';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationOutcomeEvidence(
  String? value,
) {
  return _validateLongText(value, 'evidence summary');
}

String? validateIncomingTalentMobilityStabilizationOutcomeLearning(
  String? value,
) {
  return _validateLongText(value, 'learning summary');
}

String? validateIncomingTalentMobilityStabilizationOutcomeNextAction(
  String? value,
) {
  return _validateLongText(value, 'next cadence action');
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      validateIncomingTalentMobilityStabilizationOutcomeRequired(value, label);
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
