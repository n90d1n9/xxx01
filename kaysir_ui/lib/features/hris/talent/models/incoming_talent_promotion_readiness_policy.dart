import 'incoming_talent_promotion_readiness.dart';

String? validateIncomingTalentPromotionReadinessRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionReadinessLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentPromotionReadinessRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentPromotionReadinessRating(
  IncomingTalentPromotionReadinessRating? value,
) {
  if (value == null) return 'Select readiness rating';
  return null;
}

String? validateIncomingTalentPromotionReadinessStatus(
  IncomingTalentPromotionReadinessStatus? value,
) {
  if (value == null) return 'Select readiness status';
  return null;
}

String? validateIncomingTalentPromotionReadinessDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select review date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Review date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentPromotionReadinessNextReviewDate({
  required DateTime? reviewDate,
  required DateTime? nextReviewDate,
}) {
  if (nextReviewDate == null) return 'Select next review date';
  if (reviewDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
    return 'Next review date must be after review date';
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
