import 'incoming_talent_development_program.dart';

String? validateIncomingTalentDevelopmentProgramRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentDevelopmentProgramLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentDevelopmentProgramRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentDevelopmentProgramTrack(
  IncomingTalentDevelopmentProgramTrack? value,
) {
  if (value == null) return 'Select program track';
  return null;
}

String? validateIncomingTalentDevelopmentProgramStatus(
  IncomingTalentDevelopmentProgramStatus? value,
) {
  if (value == null) return 'Select program status';
  return null;
}

String? validateIncomingTalentDevelopmentProgramIntensity(
  IncomingTalentDevelopmentProgramIntensity? value,
) {
  if (value == null) return 'Select program intensity';
  return null;
}

String? validateIncomingTalentDevelopmentProgramCapacity(int value) {
  if (value < 1) return 'Capacity must be at least 1';
  if (value > 200) return 'Capacity cannot exceed 200';
  return null;
}

String? validateIncomingTalentDevelopmentProgramDuration(int value) {
  if (value < 14) return 'Duration must be at least 14 days';
  if (value > 365) return 'Duration cannot exceed 365 days';
  return null;
}

String? validateIncomingTalentDevelopmentProgramStartDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select a start date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Start date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentDevelopmentProgramEndDate(
  DateTime? startDate,
  DateTime? endDate,
) {
  if (endDate == null) return 'Select an end date';
  if (startDate == null) return null;
  if (!_dateOnly(endDate).isAfter(_dateOnly(startDate))) {
    return 'End date must be after the start date';
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
