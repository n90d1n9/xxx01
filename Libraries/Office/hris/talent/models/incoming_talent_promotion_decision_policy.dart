import 'incoming_talent_promotion_decision.dart';

String? validateIncomingTalentPromotionDecisionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionDecisionLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentPromotionDecisionRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentPromotionDecisionOutcome(
  IncomingTalentPromotionDecisionOutcome? value,
) {
  if (value == null) return 'Select promotion outcome';
  return null;
}

String? validateIncomingTalentPromotionDecisionStatus(
  IncomingTalentPromotionDecisionStatus? value,
) {
  if (value == null) return 'Select decision status';
  return null;
}

String? validateIncomingTalentPromotionDecisionEffectiveDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select effective date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Effective date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentPromotionDecisionFollowUpDate({
  required DateTime? effectiveDate,
  required DateTime? followUpDate,
}) {
  if (followUpDate == null) return 'Select follow-up date';
  if (effectiveDate == null) return null;
  if (!_dateOnly(followUpDate).isAfter(_dateOnly(effectiveDate))) {
    return 'Follow-up date must be after effective date';
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
