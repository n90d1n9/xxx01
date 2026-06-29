import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_review.dart';

/// Default values for a stabilization follow-up action generated from a review.
class IncomingTalentPromotionStabilizationFollowUpActionDefaults {
  final IncomingTalentPromotionStabilizationFollowUpActionType actionType;
  final IncomingTalentPromotionStabilizationFollowUpPriority priority;
  final IncomingTalentPromotionStabilizationFollowUpStatus status;
  final Duration dueOffset;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;

  const IncomingTalentPromotionStabilizationFollowUpActionDefaults({
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueOffset,
    required this.actionPlan,
    required this.successCriteria,
    required this.escalationNote,
  });

  factory IncomingTalentPromotionStabilizationFollowUpActionDefaults.fromReview(
    IncomingTalentPromotionStabilizationReview review,
  ) {
    final priority = _priorityFromReview(review);

    return IncomingTalentPromotionStabilizationFollowUpActionDefaults(
      actionType: _actionTypeFromReview(review),
      priority: priority,
      status: IncomingTalentPromotionStabilizationFollowUpStatus.open,
      dueOffset: _dueOffset(priority),
      actionPlan: _actionPlan(review),
      successCriteria: _successCriteria(review),
      escalationNote: _escalationNote(review),
    );
  }
}

IncomingTalentPromotionStabilizationFollowUpActionType _actionTypeFromReview(
  IncomingTalentPromotionStabilizationReview review,
) {
  return switch (review.outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      IncomingTalentPromotionStabilizationFollowUpActionType
          .compensationConfirmation,
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      IncomingTalentPromotionStabilizationFollowUpActionType.trialCheckpoint,
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      IncomingTalentPromotionStabilizationFollowUpActionType.roleResetPlan,
  };
}

IncomingTalentPromotionStabilizationFollowUpPriority _priorityFromReview(
  IncomingTalentPromotionStabilizationReview review,
) {
  if (review.status == IncomingTalentPromotionStabilizationStatus.escalated ||
      review.outcome == IncomingTalentPromotionStabilizationOutcome.roleReset ||
      review.confidenceScore <= 2) {
    return IncomingTalentPromotionStabilizationFollowUpPriority.critical;
  }
  if (review.needsAttention) {
    return IncomingTalentPromotionStabilizationFollowUpPriority.high;
  }
  return IncomingTalentPromotionStabilizationFollowUpPriority.medium;
}

Duration _dueOffset(
  IncomingTalentPromotionStabilizationFollowUpPriority priority,
) {
  return switch (priority) {
    IncomingTalentPromotionStabilizationFollowUpPriority.critical =>
      const Duration(days: 7),
    IncomingTalentPromotionStabilizationFollowUpPriority.high => const Duration(
      days: 14,
    ),
    IncomingTalentPromotionStabilizationFollowUpPriority.medium =>
      const Duration(days: 30),
  };
}

String _actionPlan(IncomingTalentPromotionStabilizationReview review) {
  return switch (review.outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      'Confirm promotion stabilization evidence and close support loop.',
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      'Run manager coaching checkpoint and clarify promotion success measures.',
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      'Confirm compensation routing, payroll effective date, and employee communication.',
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      'Reset trial goals, sponsor support, and decision checkpoint date.',
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      'Prepare role reset plan with people panel, manager, and employee support.',
  };
}

String _successCriteria(IncomingTalentPromotionStabilizationReview review) {
  return switch (review.outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      'Review is closed with evidence and manager confirmation.',
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      'Manager and employee confirm clear expectations and support cadence.',
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      'Compensation confirmation is documented and communicated.',
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      'Trial checkpoint has signed success criteria and next review date.',
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      'Role reset decision, communication, and transition support are approved.',
  };
}

String _escalationNote(IncomingTalentPromotionStabilizationReview review) {
  if (review.status == IncomingTalentPromotionStabilizationStatus.escalated ||
      review.outcome == IncomingTalentPromotionStabilizationOutcome.roleReset) {
    return 'Escalate with ${review.reviewerName} and people leadership within one week.';
  }
  return 'Escalate if ${review.ownerName} cannot confirm progress by the due date.';
}

String? validateIncomingTalentPromotionStabilizationFollowUpRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpLongText(
  String? value,
  String label,
) {
  final requiredError =
      validateIncomingTalentPromotionStabilizationFollowUpRequired(
        value,
        label,
      );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpActionType(
  IncomingTalentPromotionStabilizationFollowUpActionType? value,
) {
  if (value == null) return 'Select follow-up action type';
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpPriority(
  IncomingTalentPromotionStabilizationFollowUpPriority? value,
) {
  if (value == null) return 'Select follow-up priority';
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpStatus(
  IncomingTalentPromotionStabilizationFollowUpStatus? value,
) {
  if (value == null) return 'Select follow-up status';
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpDueDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select due date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Due date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentPromotionStabilizationFollowUpResolutionNote({
  required IncomingTalentPromotionStabilizationFollowUpStatus? status,
  required String resolutionNote,
}) {
  final requiresResolution =
      status == IncomingTalentPromotionStabilizationFollowUpStatus.resolved ||
      status == IncomingTalentPromotionStabilizationFollowUpStatus.escalated ||
      status == IncomingTalentPromotionStabilizationFollowUpStatus.cancelled;
  if (!requiresResolution) return null;
  return validateIncomingTalentPromotionStabilizationFollowUpLongText(
    resolutionNote,
    'resolution note',
  );
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
