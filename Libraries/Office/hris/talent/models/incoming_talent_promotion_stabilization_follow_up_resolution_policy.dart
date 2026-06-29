import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution.dart';

/// Defaulting and validation policy for promotion follow-up resolution reviews.
class IncomingTalentPromotionStabilizationFollowUpResolutionDefaults {
  final IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome;
  final int confidenceAfter;
  final int residualRiskCount;
  final String evidenceSummary;
  final String managerNote;
  final String nextAction;
  final Duration nextReviewOffset;

  const IncomingTalentPromotionStabilizationFollowUpResolutionDefaults({
    required this.outcome,
    required this.confidenceAfter,
    required this.residualRiskCount,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextAction,
    required this.nextReviewOffset,
  });

  factory IncomingTalentPromotionStabilizationFollowUpResolutionDefaults.fromAction(
    IncomingTalentPromotionStabilizationFollowUpAction action,
  ) {
    final confidenceAfter =
        defaultIncomingTalentPromotionFollowUpResolutionConfidenceAfter(action);
    final residualRiskCount =
        defaultIncomingTalentPromotionFollowUpResolutionResidualRiskCount(
          action,
          confidenceAfter,
        );
    final outcome = defaultIncomingTalentPromotionFollowUpResolutionOutcome(
      action: action,
      confidenceAfter: confidenceAfter,
      residualRiskCount: residualRiskCount,
    );

    return IncomingTalentPromotionStabilizationFollowUpResolutionDefaults(
      outcome: outcome,
      confidenceAfter: confidenceAfter,
      residualRiskCount: residualRiskCount,
      evidenceSummary: defaultIncomingTalentPromotionFollowUpResolutionEvidence(
        action,
      ),
      managerNote: defaultIncomingTalentPromotionFollowUpResolutionManagerNote(
        action,
      ),
      nextAction: defaultIncomingTalentPromotionFollowUpResolutionNextAction(
        outcome,
      ),
      nextReviewOffset:
          defaultIncomingTalentPromotionFollowUpResolutionNextReviewOffset(
            outcome,
          ),
    );
  }
}

int defaultIncomingTalentPromotionFollowUpResolutionConfidenceAfter(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  if (action.status ==
      IncomingTalentPromotionStabilizationFollowUpStatus.resolved) {
    return (action.sourceConfidenceScore + 1).clamp(1, 5);
  }
  if (action.status ==
      IncomingTalentPromotionStabilizationFollowUpStatus.escalated) {
    return (action.sourceConfidenceScore - 1).clamp(1, 5);
  }
  return action.sourceConfidenceScore.clamp(1, 5);
}

int defaultIncomingTalentPromotionFollowUpResolutionResidualRiskCount(
  IncomingTalentPromotionStabilizationFollowUpAction action,
  int confidenceAfter,
) {
  if (action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.resolved &&
      confidenceAfter >= 4) {
    return 0;
  }
  if (action.status ==
      IncomingTalentPromotionStabilizationFollowUpStatus.escalated) {
    return 2;
  }
  return 1;
}

IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
defaultIncomingTalentPromotionFollowUpResolutionOutcome({
  required IncomingTalentPromotionStabilizationFollowUpAction action,
  required int confidenceAfter,
  required int residualRiskCount,
}) {
  if (action.status ==
      IncomingTalentPromotionStabilizationFollowUpStatus.escalated) {
    return IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .peoplePanelEscalation;
  }
  if (residualRiskCount > 1) {
    return IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .reopenFollowUp;
  }
  if (residualRiskCount > 0 || confidenceAfter <= 3) {
    return IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .monitor;
  }
  return IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
      .stabilized;
}

String defaultIncomingTalentPromotionFollowUpResolutionEvidence(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  if (action.resolutionNote.trim().isNotEmpty) {
    return 'Promotion follow-up evidence: ${action.resolutionNote.trim()}';
  }
  return 'Promotion follow-up evidence confirms ${action.successCriteria.toLowerCase()}';
}

String defaultIncomingTalentPromotionFollowUpResolutionManagerNote(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  return 'Manager confirms ${action.actionPlan.toLowerCase()}';
}

String defaultIncomingTalentPromotionFollowUpResolutionNextAction(
  IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized =>
      'Archive stabilization evidence and return to standard promotion cadence.',
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.monitor =>
      'Monitor promotion stabilization with manager and HRBP checkpoint.',
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .reopenFollowUp =>
      'Reopen promotion follow-up with clearer owner and success criteria.',
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .peoplePanelEscalation =>
      'Escalate residual promotion risk to the people panel.',
  };
}

Duration defaultIncomingTalentPromotionFollowUpResolutionNextReviewOffset(
  IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized =>
      const Duration(days: 45),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.monitor =>
      const Duration(days: 21),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .reopenFollowUp =>
      const Duration(days: 14),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .peoplePanelEscalation =>
      const Duration(days: 7),
  };
}

String? validateIncomingTalentPromotionFollowUpResolutionRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionSourceStatus(
  IncomingTalentPromotionStabilizationFollowUpStatus? value,
) {
  if (value == null) return 'Select a resolved or escalated follow-up';
  if (value != IncomingTalentPromotionStabilizationFollowUpStatus.resolved &&
      value != IncomingTalentPromotionStabilizationFollowUpStatus.escalated) {
    return 'Follow-up must be resolved or escalated before review';
  }
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select resolution review date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Resolution review date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionOutcome(
  IncomingTalentPromotionStabilizationFollowUpResolutionOutcome? value,
) {
  if (value == null) return 'Select resolution outcome';
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionConfidence(int value) {
  if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionResidualRisk(
  int value,
) {
  if (value < 0) return 'Residual risk cannot be negative';
  if (value > 5) return 'Residual risk must be 5 or fewer';
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionNextReviewDate(
  DateTime? reviewDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (reviewDate == null) return null;
  if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
    return 'Next review must be after resolution review date';
  }
  return null;
}

String? validateIncomingTalentPromotionFollowUpResolutionLongText(
  String? value,
  String label,
) {
  final requiredError =
      validateIncomingTalentPromotionFollowUpResolutionRequired(value, label);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

DateTime dateOnlyIncomingTalentPromotionFollowUpResolution(DateTime value) {
  return _dateOnly(value);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}
