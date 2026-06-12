import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';

class IncomingTalentCareerPathSupportActionDefaults {
  final IncomingTalentCareerPathSupportActionType actionType;
  final IncomingTalentCareerPathSupportActionPriority priority;
  final IncomingTalentCareerPathSupportActionStatus status;
  final Duration dueOffset;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;

  const IncomingTalentCareerPathSupportActionDefaults({
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueOffset,
    required this.actionPlan,
    required this.successCriteria,
    required this.escalationNote,
  });

  factory IncomingTalentCareerPathSupportActionDefaults.fromReview(
    IncomingTalentCareerPathReview review,
  ) {
    final priority = _priorityFromReview(review);

    return IncomingTalentCareerPathSupportActionDefaults(
      actionType: _actionTypeFromReview(review),
      priority: priority,
      status: IncomingTalentCareerPathSupportActionStatus.open,
      dueOffset: _dueOffset(priority),
      actionPlan: review.nextAction,
      successCriteria: _successCriteria(review),
      escalationNote: _escalationNote(review),
    );
  }
}

IncomingTalentCareerPathSupportActionType _actionTypeFromReview(
  IncomingTalentCareerPathReview review,
) {
  if (review.decision == IncomingTalentCareerPathReviewDecision.blocked) {
    return IncomingTalentCareerPathSupportActionType.managerUnblocker;
  }
  if (review.levelGap >= 2) {
    return IncomingTalentCareerPathSupportActionType.learningAssignment;
  }
  if (review.decision == IncomingTalentCareerPathReviewDecision.needsSupport) {
    return IncomingTalentCareerPathSupportActionType.coaching;
  }
  return IncomingTalentCareerPathSupportActionType.mentorReview;
}

IncomingTalentCareerPathSupportActionPriority _priorityFromReview(
  IncomingTalentCareerPathReview review,
) {
  if (review.decision == IncomingTalentCareerPathReviewDecision.blocked ||
      review.levelGap >= 2) {
    return IncomingTalentCareerPathSupportActionPriority.critical;
  }
  if (review.decision == IncomingTalentCareerPathReviewDecision.needsSupport) {
    return IncomingTalentCareerPathSupportActionPriority.high;
  }
  return IncomingTalentCareerPathSupportActionPriority.medium;
}

Duration _dueOffset(IncomingTalentCareerPathSupportActionPriority priority) {
  return switch (priority) {
    IncomingTalentCareerPathSupportActionPriority.critical => const Duration(
      days: 7,
    ),
    IncomingTalentCareerPathSupportActionPriority.high => const Duration(
      days: 14,
    ),
    IncomingTalentCareerPathSupportActionPriority.medium => const Duration(
      days: 21,
    ),
  };
}

String _successCriteria(IncomingTalentCareerPathReview review) {
  return 'Lift ${review.competencyName} to level ${review.targetLevel} with signed evidence.';
}

String _escalationNote(IncomingTalentCareerPathReview review) {
  if (review.decision == IncomingTalentCareerPathReviewDecision.blocked) {
    return 'Escalate blocker ownership with ${review.reviewerName}.';
  }
  return 'Monitor support progress with ${review.reviewerName}.';
}

String? validateIncomingTalentCareerPathSupportActionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportActionLongText(
  String? value,
  String label,
) {
  final requiredError = validateIncomingTalentCareerPathSupportActionRequired(
    value,
    label,
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentCareerPathSupportActionType(
  IncomingTalentCareerPathSupportActionType? value,
) {
  if (value == null) return 'Select action type';
  return null;
}

String? validateIncomingTalentCareerPathSupportActionPriority(
  IncomingTalentCareerPathSupportActionPriority? value,
) {
  if (value == null) return 'Select priority';
  return null;
}

String? validateIncomingTalentCareerPathSupportActionStatus(
  IncomingTalentCareerPathSupportActionStatus? value,
) {
  if (value == null) return 'Select action status';
  return null;
}

String? validateIncomingTalentCareerPathSupportActionDueDate(
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
