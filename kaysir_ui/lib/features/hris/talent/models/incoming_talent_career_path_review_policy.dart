import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_review.dart';

class IncomingTalentCareerPathReviewDefaults {
  final IncomingTalentCareerPathReviewDecision decision;
  final int reviewedLevel;
  final String evidenceNote;
  final String blockerNote;
  final String nextAction;
  final Duration nextReviewOffset;

  const IncomingTalentCareerPathReviewDefaults({
    required this.decision,
    required this.reviewedLevel,
    required this.evidenceNote,
    required this.blockerNote,
    required this.nextAction,
    required this.nextReviewOffset,
  });

  factory IncomingTalentCareerPathReviewDefaults.fromCareerPath(
    IncomingTalentCareerPath careerPath,
  ) {
    final decision = _decisionFromCareerPath(careerPath);

    return IncomingTalentCareerPathReviewDefaults(
      decision: decision,
      reviewedLevel: _reviewedLevel(careerPath, decision),
      evidenceNote: careerPath.evidenceRequirement,
      blockerNote: _blockerNote(careerPath, decision),
      nextAction: _nextAction(careerPath, decision),
      nextReviewOffset: _nextReviewOffset(careerPath, decision),
    );
  }
}

IncomingTalentCareerPathReviewDecision _decisionFromCareerPath(
  IncomingTalentCareerPath careerPath,
) {
  if (careerPath.status == IncomingTalentCareerPathStatus.achieved ||
      careerPath.currentLevel >= careerPath.targetLevel) {
    return IncomingTalentCareerPathReviewDecision.achieved;
  }
  if (careerPath.status == IncomingTalentCareerPathStatus.blocked) {
    return IncomingTalentCareerPathReviewDecision.blocked;
  }
  if (careerPath.priority == IncomingTalentCareerPathPriority.critical ||
      careerPath.levelGap >= 2) {
    return IncomingTalentCareerPathReviewDecision.needsSupport;
  }
  return IncomingTalentCareerPathReviewDecision.progressing;
}

int _reviewedLevel(
  IncomingTalentCareerPath careerPath,
  IncomingTalentCareerPathReviewDecision decision,
) {
  if (decision == IncomingTalentCareerPathReviewDecision.achieved) {
    return careerPath.targetLevel;
  }
  return careerPath.currentLevel;
}

String _blockerNote(
  IncomingTalentCareerPath careerPath,
  IncomingTalentCareerPathReviewDecision decision,
) {
  if (decision == IncomingTalentCareerPathReviewDecision.blocked ||
      decision == IncomingTalentCareerPathReviewDecision.needsSupport) {
    return 'Review blockers against ${careerPath.competencyName}.';
  }
  return 'No active blockers recorded for this review.';
}

String _nextAction(
  IncomingTalentCareerPath careerPath,
  IncomingTalentCareerPathReviewDecision decision,
) {
  return switch (decision) {
    IncomingTalentCareerPathReviewDecision.achieved =>
      'Graduate ${careerPath.candidateName} from this career path.',
    IncomingTalentCareerPathReviewDecision.blocked =>
      'Unblock ${careerPath.competencyName} with manager and mentor support.',
    IncomingTalentCareerPathReviewDecision.needsSupport =>
      'Add targeted support to close ${careerPath.levelGap} level gap.',
    IncomingTalentCareerPathReviewDecision.progressing =>
      'Keep ${careerPath.competencyName} progress on cadence.',
  };
}

Duration _nextReviewOffset(
  IncomingTalentCareerPath careerPath,
  IncomingTalentCareerPathReviewDecision decision,
) {
  if (decision == IncomingTalentCareerPathReviewDecision.achieved) {
    return const Duration(days: 90);
  }
  if (decision == IncomingTalentCareerPathReviewDecision.blocked ||
      careerPath.priority == IncomingTalentCareerPathPriority.critical) {
    return const Duration(days: 14);
  }
  if (decision == IncomingTalentCareerPathReviewDecision.needsSupport) {
    return const Duration(days: 30);
  }
  return const Duration(days: 45);
}

String? validateIncomingTalentCareerPathReviewRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentCareerPathReviewLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentCareerPathReviewRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentCareerPathReviewDecision(
  IncomingTalentCareerPathReviewDecision? value,
) {
  if (value == null) return 'Select review decision';
  return null;
}

String? validateIncomingTalentCareerPathReviewLevel(int value, String label) {
  if (value < 1 || value > 5) return '$label must be between 1 and 5';
  return null;
}

String? validateIncomingTalentCareerPathReviewReviewedLevel({
  required int reviewedLevel,
  required int targetLevel,
}) {
  final levelError = validateIncomingTalentCareerPathReviewLevel(
    reviewedLevel,
    'Reviewed level',
  );
  if (levelError != null) return levelError;
  if (reviewedLevel > targetLevel) {
    return 'Reviewed level cannot exceed target level';
  }
  return null;
}

String? validateIncomingTalentCareerPathReviewDate(
  DateTime? value,
  DateTime asOfDate,
  String label,
) {
  if (value == null) return 'Select a $label';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return '${_capitalize(label)} cannot be in the past';
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
