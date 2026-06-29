import 'incoming_talent_career_framework_level.dart';

String? validateIncomingTalentCareerFrameworkRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentCareerFrameworkLevelCode(String? value) {
  final requiredError = validateIncomingTalentCareerFrameworkRequired(
    value,
    'a level code',
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 2) {
    return 'Level code must be at least 2 characters';
  }
  return null;
}

String? validateIncomingTalentCareerFrameworkFocus(String? value) {
  final requiredError = validateIncomingTalentCareerFrameworkRequired(
    value,
    'a competency',
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 3) return 'Competency is too short';
  return null;
}

String? validateIncomingTalentCareerFrameworkLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentCareerFrameworkRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentCareerFrameworkScope(
  IncomingTalentCareerFrameworkLevelScope? value,
) {
  if (value == null) return 'Select a ladder scope';
  return null;
}

String? validateIncomingTalentCareerFrameworkStatus(
  IncomingTalentCareerFrameworkLevelStatus? value,
) {
  if (value == null) return 'Select framework status';
  return null;
}

String? validateIncomingTalentCareerFrameworkReviewCadence(
  IncomingTalentCareerFrameworkReviewCadence? value,
) {
  if (value == null) return 'Select review cadence';
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}
