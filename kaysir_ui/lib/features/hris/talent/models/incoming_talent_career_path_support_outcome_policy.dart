import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';
import 'incoming_talent_career_path_support_outcome.dart';

IncomingTalentCareerPathSupportOutcomeDecision
defaultIncomingTalentCareerPathSupportOutcomeDecision(
  IncomingTalentCareerPathSupportAction action,
) {
  if (action.sourceLevelGap >= 2) {
    return IncomingTalentCareerPathSupportOutcomeDecision.improved;
  }
  if (action.priority == IncomingTalentCareerPathSupportActionPriority.high ||
      action.priority ==
          IncomingTalentCareerPathSupportActionPriority.critical) {
    return IncomingTalentCareerPathSupportOutcomeDecision.monitor;
  }
  return IncomingTalentCareerPathSupportOutcomeDecision.resolved;
}

IncomingTalentCareerPathSupportOutcomeResidualRisk
defaultIncomingTalentCareerPathSupportOutcomeResidualRisk(
  IncomingTalentCareerPathSupportAction action,
) {
  if (action.sourceDecision == IncomingTalentCareerPathReviewDecision.blocked ||
      action.priority ==
          IncomingTalentCareerPathSupportActionPriority.critical) {
    return IncomingTalentCareerPathSupportOutcomeResidualRisk.high;
  }
  if (action.sourceLevelGap >= 2 ||
      action.priority == IncomingTalentCareerPathSupportActionPriority.high) {
    return IncomingTalentCareerPathSupportOutcomeResidualRisk.moderate;
  }
  return IncomingTalentCareerPathSupportOutcomeResidualRisk.low;
}

int defaultIncomingTalentCareerPathSupportOutcomeVerifiedLevel(
  IncomingTalentCareerPathSupportAction action,
) {
  return (action.reviewedLevel + 1).clamp(1, action.targetLevel);
}

DateTime defaultIncomingTalentCareerPathSupportOutcomeNextReviewDate({
  required IncomingTalentCareerPathSupportOutcomeDecision decision,
  required DateTime asOfDate,
}) {
  return switch (decision) {
    IncomingTalentCareerPathSupportOutcomeDecision.resolved => asOfDate.add(
      const Duration(days: 45),
    ),
    IncomingTalentCareerPathSupportOutcomeDecision.improved => asOfDate.add(
      const Duration(days: 30),
    ),
    IncomingTalentCareerPathSupportOutcomeDecision.monitor => asOfDate.add(
      const Duration(days: 14),
    ),
    IncomingTalentCareerPathSupportOutcomeDecision.escalate => asOfDate.add(
      const Duration(days: 7),
    ),
  };
}

String defaultIncomingTalentCareerPathSupportOutcomeEvidence(
  IncomingTalentCareerPathSupportAction action,
) {
  return 'Validated ${action.actionType.label.toLowerCase()} against ${action.successCriteria.toLowerCase()}.';
}

String defaultIncomingTalentCareerPathSupportOutcomeManagerNote(
  IncomingTalentCareerPathSupportAction action,
) {
  return 'Confirmed ${action.ownerName} completed support for ${action.competencyName}.';
}

String defaultIncomingTalentCareerPathSupportOutcomeNextAction(
  IncomingTalentCareerPathSupportOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentCareerPathSupportOutcomeDecision.resolved =>
      'Return to standard career review cadence with manager follow-through.',
    IncomingTalentCareerPathSupportOutcomeDecision.improved =>
      'Keep support active through the next competency review.',
    IncomingTalentCareerPathSupportOutcomeDecision.monitor =>
      'Monitor residual career risk weekly with the action owner.',
    IncomingTalentCareerPathSupportOutcomeDecision.escalate =>
      'Escalate unresolved career support blockers to HR leadership.',
  };
}

String? validateIncomingTalentCareerPathSupportOutcomeRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeActionStatus(
  IncomingTalentCareerPathSupportActionStatus? value,
) {
  if (value == null) return 'Select action status';
  if (value != IncomingTalentCareerPathSupportActionStatus.resolved) {
    return 'Action must be resolved before outcome';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeDecision(
  IncomingTalentCareerPathSupportOutcomeDecision? value,
) {
  if (value == null) return 'Select outcome decision';
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeResidualRisk(
  IncomingTalentCareerPathSupportOutcomeResidualRisk? value,
) {
  if (value == null) return 'Select residual risk';
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeVerifiedLevel(int value) {
  if (value < 1 || value > 5) {
    return 'Verified level must be between 1 and 5';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select outcome date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Outcome date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeNextReviewDate(
  DateTime? outcomeDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (outcomeDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(outcomeDate))) {
    return 'Next review date must be after outcome date';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportOutcomeLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentCareerPathSupportOutcomeRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
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
