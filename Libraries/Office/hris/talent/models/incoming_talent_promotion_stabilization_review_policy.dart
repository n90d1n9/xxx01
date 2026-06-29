import 'incoming_talent_promotion_stabilization_review.dart';

String? validateIncomingTalentPromotionStabilizationRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentPromotionStabilizationRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationOutcome(
  IncomingTalentPromotionStabilizationOutcome? value,
) {
  if (value == null) return 'Select stabilization outcome';
  return null;
}

String? validateIncomingTalentPromotionStabilizationStatus(
  IncomingTalentPromotionStabilizationStatus? value,
) {
  if (value == null) return 'Select stabilization status';
  return null;
}

String? validateIncomingTalentPromotionStabilizationReviewDate(
  DateTime? value,
) {
  if (value == null) return 'Select review date';
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpDate({
  required IncomingTalentPromotionStabilizationStatus? status,
  required DateTime? reviewDate,
  required DateTime? followUpDate,
}) {
  if (!_requiresFollowUp(status)) return null;
  if (followUpDate == null) return 'Select follow-up date';
  if (reviewDate != null &&
      _dateOnly(followUpDate).isBefore(_dateOnly(reviewDate))) {
    return 'Follow-up date cannot be before review date';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationConfidence(int value) {
  if (value < 1 || value > 5) {
    return 'Select confidence score';
  }
  return null;
}

bool _requiresFollowUp(IncomingTalentPromotionStabilizationStatus? status) {
  return status == IncomingTalentPromotionStabilizationStatus.scheduled ||
      status == IncomingTalentPromotionStabilizationStatus.followUpRequired ||
      status == IncomingTalentPromotionStabilizationStatus.escalated;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
