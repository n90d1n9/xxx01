import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_stabilization_action.dart';

IncomingTalentMobilityStabilizationActionType
defaultIncomingTalentMobilityStabilizationActionType(
  IncomingTalentMobilityFirstReview review,
) {
  if (review.retentionRisk ==
      IncomingTalentMobilityFirstReviewRetentionRisk.high) {
    return IncomingTalentMobilityStabilizationActionType.retentionSave;
  }
  if (review.outcome == IncomingTalentMobilityFirstReviewOutcome.blocked) {
    return IncomingTalentMobilityStabilizationActionType.sponsorAlignment;
  }
  if (review.hostConfidenceScore <= 3) {
    return IncomingTalentMobilityStabilizationActionType.hostManagerCoaching;
  }
  if (review.outcome == IncomingTalentMobilityFirstReviewOutcome.watch) {
    return IncomingTalentMobilityStabilizationActionType.roleScopeClarification;
  }
  return IncomingTalentMobilityStabilizationActionType.capabilitySupport;
}

IncomingTalentMobilityStabilizationStatus
defaultIncomingTalentMobilityStabilizationStatus(
  IncomingTalentMobilityFirstReview review,
) {
  return review.outcome == IncomingTalentMobilityFirstReviewOutcome.blocked
      ? IncomingTalentMobilityStabilizationStatus.blocked
      : IncomingTalentMobilityStabilizationStatus.planned;
}

DateTime defaultIncomingTalentMobilityStabilizationDueDate({
  required IncomingTalentMobilityFirstReview review,
  required DateTime asOfDate,
}) {
  if (review.followUpDate.isBefore(asOfDate)) {
    return asOfDate.add(const Duration(days: 7));
  }
  return review.followUpDate;
}

String defaultIncomingTalentMobilityStabilizationActionSummary(
  IncomingTalentMobilityFirstReview review,
) {
  return 'Stabilize ${review.candidateName} in ${review.opportunityTitle.toLowerCase()} with targeted owner follow-up.';
}

String defaultIncomingTalentMobilityStabilizationSuccessMeasure(
  IncomingTalentMobilityFirstReview review,
) {
  return 'Raise host confidence above 3/5 and confirm ${review.targetRole.toLowerCase()} delivery signal in the next review.';
}

String? validateIncomingTalentMobilityStabilizationRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationActionType(
  IncomingTalentMobilityStabilizationActionType? value,
) {
  if (value == null) return 'Select action type';
  return null;
}

String? validateIncomingTalentMobilityStabilizationStatus(
  IncomingTalentMobilityStabilizationStatus? value,
) {
  if (value == null) return 'Select action status';
  return null;
}

String? validateIncomingTalentMobilityStabilizationDueDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select due date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityStabilizationActionSummary(
  String? value,
) {
  return _validateLongText(value, 'action summary');
}

String? validateIncomingTalentMobilityStabilizationSuccessMeasure(
  String? value,
) {
  return _validateLongText(value, 'success measure');
}

String? validateIncomingTalentMobilityStabilizationBlockerNote(
  String? value,
  IncomingTalentMobilityStabilizationStatus? status,
) {
  if (status != IncomingTalentMobilityStabilizationStatus.blocked) {
    return null;
  }
  return _validateLongText(value, 'blocker note');
}

String? _validateLongText(String? value, String label) {
  final requiredError = validateIncomingTalentMobilityStabilizationRequired(
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
