import 'incoming_talent_development_program_completion.dart';

String? validateIncomingTalentProgramCompletionRequired(
  String? value,
  String label,
) {
  if (value == null || value.trim().isEmpty) return 'Please enter $label';
  return null;
}

String? validateIncomingTalentProgramCompletionLongText(
  String? value,
  String label,
) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Please enter $label';
  if (text.length < 12) return '$label must be at least 12 characters';
  return null;
}

String? validateIncomingTalentProgramCompletionDecision(
  IncomingTalentDevelopmentProgramCompletionDecision? value,
) {
  if (value == null) return 'Select completion decision';
  return null;
}

String? validateIncomingTalentProgramCredentialLevel(
  IncomingTalentDevelopmentProgramCredentialLevel? value,
) {
  if (value == null) return 'Select credential level';
  return null;
}

String? validateIncomingTalentProgramCompletionScore(int value) {
  if (value < 0) return 'Score cannot be below 0';
  if (value > 100) return 'Score cannot exceed 100';
  return null;
}

String? validateIncomingTalentProgramCompletionDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select completion date';
  if (value.isAfter(asOfDate)) return 'Completion date cannot be in the future';
  return null;
}

String? validateIncomingTalentProgramCompletionRenewalDate({
  required DateTime? renewalDate,
  required DateTime? completedAt,
}) {
  if (renewalDate == null || completedAt == null) return null;
  if (renewalDate.isBefore(completedAt)) {
    return 'Renewal date cannot be before completion';
  }
  return null;
}
