import 'incoming_talent_development_program_milestone.dart';

String? validateIncomingTalentProgramMilestoneRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentProgramMilestoneLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentProgramMilestoneRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentProgramMilestoneType(
  IncomingTalentDevelopmentProgramMilestoneType? value,
) {
  if (value == null) return 'Select milestone type';
  return null;
}

String? validateIncomingTalentProgramMilestoneStatus(
  IncomingTalentDevelopmentProgramMilestoneStatus? value,
) {
  if (value == null) return 'Select milestone status';
  return null;
}

String? validateIncomingTalentProgramMilestoneScore(int value) {
  if (value < 0) return 'Score cannot be below 0';
  if (value > 100) return 'Score cannot exceed 100';
  return null;
}

String? validateIncomingTalentProgramMilestoneDueDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select a due date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
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
