import 'incoming_talent_promotion_implementation.dart';

String? validateIncomingTalentPromotionImplementationRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionImplementationLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentPromotionImplementationRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentPromotionImplementationAction(
  IncomingTalentPromotionImplementationAction? value,
) {
  if (value == null) return 'Select implementation action';
  return null;
}

String? validateIncomingTalentPromotionImplementationStatus(
  IncomingTalentPromotionImplementationStatus? value,
) {
  if (value == null) return 'Select implementation status';
  return null;
}

String? validateIncomingTalentPromotionImplementationDueDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select due date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentPromotionImplementationCompletedDate({
  required IncomingTalentPromotionImplementationStatus? status,
  required DateTime? completedDate,
  required DateTime asOfDate,
}) {
  if (status != IncomingTalentPromotionImplementationStatus.completed) {
    return null;
  }
  if (completedDate == null) return 'Select completed date';
  if (_dateOnly(completedDate).isBefore(_dateOnly(asOfDate))) {
    return 'Completed date cannot be in the past';
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
