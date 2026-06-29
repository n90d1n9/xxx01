import 'incoming_talent_training_session.dart';

String? validateIncomingTalentTrainingSessionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentTrainingSessionLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentTrainingSessionRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentTrainingSessionFormat(
  IncomingTalentTrainingSessionFormat? value,
) {
  if (value == null) return 'Select training format';
  return null;
}

String? validateIncomingTalentTrainingSessionStatus(
  IncomingTalentTrainingSessionStatus? value,
) {
  if (value == null) return 'Select session status';
  return null;
}

String? validateIncomingTalentTrainingSessionCapacity(int value) {
  if (value < 1) return 'Capacity must be at least 1';
  if (value > 100) return 'Capacity cannot exceed 100';
  return null;
}

String? validateIncomingTalentTrainingSessionReservedSeats({
  required int reservedSeats,
  required int capacity,
}) {
  if (reservedSeats < 0) return 'Reserved seats cannot be negative';
  if (reservedSeats > capacity) return 'Reserved seats cannot exceed capacity';
  return null;
}

String? validateIncomingTalentTrainingSessionDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select a session date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Session date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentTrainingSessionFollowUpDate({
  required DateTime? sessionDate,
  required DateTime? followUpDate,
}) {
  if (followUpDate == null) return 'Select a follow-up date';
  if (sessionDate == null) return null;
  if (!_dateOnly(followUpDate).isAfter(_dateOnly(sessionDate))) {
    return 'Follow-up date must be after the session date';
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
