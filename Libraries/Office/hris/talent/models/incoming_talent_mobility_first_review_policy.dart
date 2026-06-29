import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_launch_checklist.dart';

IncomingTalentMobilityFirstReviewOutcome
defaultIncomingTalentMobilityFirstReviewOutcome(
  IncomingTalentMobilityLaunchChecklist checklist,
) {
  if (checklist.fitScore >= 85 && checklist.allGatesReady) {
    return IncomingTalentMobilityFirstReviewOutcome.accelerating;
  }
  if (checklist.fitScore >= 75) {
    return IncomingTalentMobilityFirstReviewOutcome.stable;
  }
  return IncomingTalentMobilityFirstReviewOutcome.watch;
}

IncomingTalentMobilityFirstReviewRetentionRisk
defaultIncomingTalentMobilityFirstReviewRetentionRisk(
  IncomingTalentMobilityLaunchChecklist checklist,
) {
  if (checklist.fitScore >= 85 && checklist.riskNote.isEmpty) {
    return IncomingTalentMobilityFirstReviewRetentionRisk.low;
  }
  if (checklist.fitScore >= 75) {
    return IncomingTalentMobilityFirstReviewRetentionRisk.moderate;
  }
  return IncomingTalentMobilityFirstReviewRetentionRisk.high;
}

int defaultIncomingTalentMobilityFirstReviewConfidence(
  IncomingTalentMobilityLaunchChecklist checklist,
) {
  if (checklist.fitScore >= 85 && checklist.allGatesReady) return 5;
  if (checklist.fitScore >= 75) return 4;
  return 3;
}

DateTime defaultIncomingTalentMobilityFirstReviewCaptureDate({
  required IncomingTalentMobilityLaunchChecklist checklist,
  required DateTime asOfDate,
}) {
  return checklist.firstReviewDate.isBefore(asOfDate)
      ? asOfDate
      : checklist.firstReviewDate;
}

String defaultIncomingTalentMobilityFirstReviewDeliverySignal(
  IncomingTalentMobilityLaunchChecklist checklist,
) {
  return 'Review early delivery for ${checklist.opportunityTitle.toLowerCase()} with host manager evidence and sponsor feedback.';
}

String defaultIncomingTalentMobilityFirstReviewNextAction(
  IncomingTalentMobilityLaunchChecklist checklist,
) {
  return 'Confirm next milestone for ${checklist.candidateName} and update mobility sponsor cadence.';
}

String? validateIncomingTalentMobilityFirstReviewRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityFirstReviewOutcome(
  IncomingTalentMobilityFirstReviewOutcome? value,
) {
  if (value == null) return 'Select review outcome';
  return null;
}

String? validateIncomingTalentMobilityFirstReviewRetentionRisk(
  IncomingTalentMobilityFirstReviewRetentionRisk? value,
) {
  if (value == null) return 'Select retention risk';
  return null;
}

String? validateIncomingTalentMobilityFirstReviewLaunchStatus(
  IncomingTalentMobilityLaunchStatus? value,
) {
  if (value == null) return 'Select launch status';
  if (value != IncomingTalentMobilityLaunchStatus.launched) {
    return 'Launch must be completed before first review';
  }
  return null;
}

String? validateIncomingTalentMobilityFirstReviewConfidenceScore(int value) {
  if (value < 1 || value > 5) {
    return 'Host confidence must be between 1 and 5';
  }
  return null;
}

String? validateIncomingTalentMobilityFirstReviewDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select review date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Review date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityFirstReviewFollowUpDate(
  DateTime? reviewDate,
  DateTime? followUpDate,
) {
  if (followUpDate == null) return 'Select follow-up date';
  if (reviewDate == null) return null;
  if (!_dateOnly(followUpDate).isAfter(_dateOnly(reviewDate))) {
    return 'Follow-up date must be after review date';
  }
  return null;
}

String? validateIncomingTalentMobilityFirstReviewDeliverySignal(String? value) {
  return _validateLongText(value, 'delivery signal');
}

String? validateIncomingTalentMobilityFirstReviewBlockerNote(
  String? value,
  IncomingTalentMobilityFirstReviewOutcome? outcome,
) {
  if (outcome != IncomingTalentMobilityFirstReviewOutcome.watch &&
      outcome != IncomingTalentMobilityFirstReviewOutcome.blocked) {
    return null;
  }
  return _validateLongText(value, 'blocker note');
}

String? validateIncomingTalentMobilityFirstReviewNextAction(String? value) {
  return _validateLongText(value, 'next action');
}

String? _validateLongText(String? value, String label) {
  final requiredError = validateIncomingTalentMobilityFirstReviewRequired(
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
