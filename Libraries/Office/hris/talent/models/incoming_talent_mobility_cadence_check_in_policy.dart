import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

IncomingTalentMobilityCadenceStatus defaultIncomingTalentMobilityCadenceStatus(
  IncomingTalentMobilityStabilizationOutcome outcome,
) {
  if (outcome.decision ==
      IncomingTalentMobilityStabilizationOutcomeDecision.escalate) {
    return IncomingTalentMobilityCadenceStatus.intervene;
  }
  if (outcome.decision ==
          IncomingTalentMobilityStabilizationOutcomeDecision.monitor ||
      outcome.residualRisk !=
          IncomingTalentMobilityStabilizationResidualRisk.low ||
      outcome.hostConfidenceAfter <= 3) {
    return IncomingTalentMobilityCadenceStatus.watch;
  }
  return IncomingTalentMobilityCadenceStatus.onTrack;
}

DateTime defaultIncomingTalentMobilityCadenceNextReviewDate({
  required IncomingTalentMobilityCadenceStatus status,
  required DateTime checkInDate,
}) {
  return switch (status) {
    IncomingTalentMobilityCadenceStatus.closed => checkInDate.add(
      const Duration(days: 90),
    ),
    IncomingTalentMobilityCadenceStatus.onTrack => checkInDate.add(
      const Duration(days: 45),
    ),
    IncomingTalentMobilityCadenceStatus.watch => checkInDate.add(
      const Duration(days: 21),
    ),
    IncomingTalentMobilityCadenceStatus.intervene => checkInDate.add(
      const Duration(days: 7),
    ),
  };
}

String defaultIncomingTalentMobilityCadencePulseSummary(
  IncomingTalentMobilityStabilizationOutcome outcome,
) {
  return 'Host and manager confirmed ${outcome.candidateName} is progressing against ${outcome.nextCadenceAction.toLowerCase()}.';
}

String defaultIncomingTalentMobilityCadenceSupportPlan(
  IncomingTalentMobilityStabilizationOutcome outcome,
) {
  return 'Keep ${outcome.actionOwnerName} accountable for follow-up and refresh evidence before the next mobility review.';
}

String defaultIncomingTalentMobilityCadenceSupportByStatus(
  IncomingTalentMobilityCadenceStatus status,
) {
  return switch (status) {
    IncomingTalentMobilityCadenceStatus.closed =>
      'Close cadence and archive lessons for future internal mobility moves.',
    IncomingTalentMobilityCadenceStatus.onTrack =>
      'Maintain manager check-ins and monitor confidence at the next cadence.',
    IncomingTalentMobilityCadenceStatus.watch =>
      'Keep weekly sponsor touchpoints active until residual risk is low.',
    IncomingTalentMobilityCadenceStatus.intervene =>
      'Escalate support with HR leadership and define a recovery owner.',
  };
}

String? validateIncomingTalentMobilityCadenceRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceStatus(
  IncomingTalentMobilityCadenceStatus? value,
) {
  if (value == null) return 'Select cadence status';
  return null;
}

String? validateIncomingTalentMobilityCadenceResidualRisk(
  IncomingTalentMobilityStabilizationResidualRisk? value,
) {
  if (value == null) return 'Select residual risk';
  return null;
}

String? validateIncomingTalentMobilityCadenceConfidence(int value) {
  if (value < 1 || value > 5) {
    return 'Host confidence must be between 1 and 5';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceCheckInDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select check-in date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Check-in date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityCadenceNextReviewDate(
  DateTime? checkInDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (checkInDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(checkInDate))) {
    return 'Next review date must be after check-in date';
  }
  return null;
}

String? validateIncomingTalentMobilityCadencePulse(String? value) {
  return _validateLongText(value, 'pulse summary');
}

String? validateIncomingTalentMobilityCadenceSupportPlan(String? value) {
  return _validateLongText(value, 'support plan');
}

String? _validateLongText(String? value, String label) {
  final requiredError = validateIncomingTalentMobilityCadenceRequired(
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
