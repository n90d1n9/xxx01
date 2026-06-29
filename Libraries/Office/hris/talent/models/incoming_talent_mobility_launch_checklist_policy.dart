import 'incoming_talent_mobility_launch_checklist.dart';
import 'incoming_talent_mobility_match.dart';

DateTime defaultIncomingTalentMobilityLaunchDate({
  required IncomingTalentMobilityMatch match,
  required DateTime asOfDate,
}) {
  return match.startDate.isBefore(asOfDate) ? asOfDate : match.startDate;
}

DateTime defaultIncomingTalentMobilityFirstReviewDate({
  required IncomingTalentMobilityMatch match,
  required DateTime launchDate,
}) {
  return match.reviewDate.isAfter(launchDate)
      ? match.reviewDate
      : launchDate.add(const Duration(days: 45));
}

IncomingTalentMobilityLaunchStatus defaultIncomingTalentMobilityLaunchStatus(
  IncomingTalentMobilityMatchStatus status,
) {
  return status == IncomingTalentMobilityMatchStatus.activated
      ? IncomingTalentMobilityLaunchStatus.launched
      : IncomingTalentMobilityLaunchStatus.planned;
}

bool defaultIncomingTalentMobilityLaunchSponsorSignoff(
  IncomingTalentMobilityMatchStatus status,
) {
  return status == IncomingTalentMobilityMatchStatus.accepted ||
      status == IncomingTalentMobilityMatchStatus.activated;
}

bool defaultIncomingTalentMobilityLaunchBackfillReady(
  IncomingTalentMobilityMoveType moveType,
) {
  return switch (moveType) {
    IncomingTalentMobilityMoveType.stretchAssignment => true,
    IncomingTalentMobilityMoveType.projectRotation => true,
    IncomingTalentMobilityMoveType.promotion => false,
    IncomingTalentMobilityMoveType.lateralMove => false,
    IncomingTalentMobilityMoveType.successionCoverage => false,
  };
}

String defaultIncomingTalentMobilityLaunchRiskNote(
  IncomingTalentMobilityMatch match,
) {
  if (match.fitScore >= 75) return '';
  return 'Fit score below launch threshold; confirm mitigation before launch.';
}

String defaultIncomingTalentMobilityLaunchNotes(
  IncomingTalentMobilityMatch match,
) {
  return 'Confirm ${match.candidateName} can start ${match.opportunityTitle.toLowerCase()} with sponsor, host manager, and HR launch support.';
}

bool incomingTalentMobilityLaunchRequiresReadyGates(
  IncomingTalentMobilityLaunchStatus? status,
) {
  return status == IncomingTalentMobilityLaunchStatus.ready ||
      status == IncomingTalentMobilityLaunchStatus.launched;
}

String? validateIncomingTalentMobilityLaunchRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityLaunchStatus(
  IncomingTalentMobilityLaunchStatus? value,
) {
  if (value == null) return 'Select launch status';
  return null;
}

String? validateIncomingTalentMobilityLaunchMoveType(
  IncomingTalentMobilityMoveType? value,
) {
  if (value == null) return 'Select mobility type';
  return null;
}

String? validateIncomingTalentMobilityLaunchMatchStatus(
  IncomingTalentMobilityMatchStatus? value,
) {
  if (value == null) return 'Select mobility match status';
  return null;
}

String? validateIncomingTalentMobilityLaunchDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select launch date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Launch date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityLaunchFirstReviewDate(
  DateTime? launchDate,
  DateTime? firstReviewDate,
) {
  if (firstReviewDate == null) return 'Select first review date';
  if (launchDate == null) return null;
  if (!_dateOnly(firstReviewDate).isAfter(_dateOnly(launchDate))) {
    return 'First review must be after launch date';
  }
  return null;
}

String? validateIncomingTalentMobilityLaunchNotes(String? value) {
  return _validateLongText(value, 'launch notes');
}

String? validateIncomingTalentMobilityLaunchRiskNote(String? value) {
  return _validateLongText(value, 'risk note');
}

String? _validateLongText(String? value, String label) {
  final requiredError = validateIncomingTalentMobilityLaunchRequired(
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
