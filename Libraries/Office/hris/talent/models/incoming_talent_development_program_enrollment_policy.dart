import 'incoming_talent_development_program_enrollment.dart';

String? validateIncomingTalentProgramEnrollmentRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentProgramEnrollmentLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentProgramEnrollmentRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentProgramEnrollmentStatus(
  IncomingTalentDevelopmentProgramEnrollmentStatus? value,
) {
  if (value == null) return 'Select enrollment status';
  return null;
}

String? validateIncomingTalentProgramEnrollmentProgress(int value) {
  if (value < 0) return 'Progress cannot be below 0';
  if (value > 100) return 'Progress cannot exceed 100';
  return null;
}

String? validateIncomingTalentProgramEnrollmentStartDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select an enrollment date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Enrollment date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentProgramEnrollmentNextReviewDate(
  DateTime? enrolledAt,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select a next review date';
  if (enrolledAt == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(enrolledAt))) {
    return 'Next review must be after enrollment';
  }
  return null;
}

String? validateIncomingTalentProgramEnrollmentTargetDate(
  DateTime? enrolledAt,
  DateTime? targetCompletionDate,
) {
  if (targetCompletionDate == null) return 'Select a target completion date';
  if (enrolledAt == null) return null;
  if (!_dateOnly(targetCompletionDate).isAfter(_dateOnly(enrolledAt))) {
    return 'Target completion must be after enrollment';
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
