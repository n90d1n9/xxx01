import 'dart:math' as math;

import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_action_outcome.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';

IncomingTalentSuccessionCoverageActionOutcomeDecision
defaultCoverageActionOutcomeDecision(
  IncomingTalentSuccessionCoverageAction action,
) {
  if (action.actionType ==
          IncomingTalentSuccessionCoverageActionType.executiveSponsor ||
      action.coverageHealth ==
          IncomingTalentSuccessionCoverageHealth.critical) {
    return IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor;
  }
  if (action.actionType ==
      IncomingTalentSuccessionCoverageActionType.slateRework) {
    return IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor;
  }
  return IncomingTalentSuccessionCoverageActionOutcomeDecision.validated;
}

IncomingTalentSuccessionCoverageActionResidualRisk
defaultCoverageActionOutcomeResidualRisk(
  IncomingTalentSuccessionCoverageAction action,
) {
  if (action.coverageHealth ==
      IncomingTalentSuccessionCoverageHealth.critical) {
    return IncomingTalentSuccessionCoverageActionResidualRisk.high;
  }
  if (action.coverageHealth == IncomingTalentSuccessionCoverageHealth.watch ||
      action.actionType ==
          IncomingTalentSuccessionCoverageActionType.slateRework) {
    return IncomingTalentSuccessionCoverageActionResidualRisk.medium;
  }
  return IncomingTalentSuccessionCoverageActionResidualRisk.low;
}

int defaultCoverageActionOutcomeScoreAfter(
  IncomingTalentSuccessionCoverageAction action,
) {
  final lift = switch (action.actionType) {
    IncomingTalentSuccessionCoverageActionType.slateRework => 18,
    IncomingTalentSuccessionCoverageActionType.executiveSponsor => 16,
    IncomingTalentSuccessionCoverageActionType.readinessAcceleration => 12,
    IncomingTalentSuccessionCoverageActionType.governanceReview => 8,
    IncomingTalentSuccessionCoverageActionType.riskClosure => 10,
  };
  final score = math.min(100, action.coverageScore + lift);
  return (score / 5).round() * 5;
}

DateTime defaultCoverageActionOutcomeNextReviewDate({
  required IncomingTalentSuccessionCoverageActionOutcomeDecision decision,
  required DateTime asOfDate,
}) {
  final days = switch (decision) {
    IncomingTalentSuccessionCoverageActionOutcomeDecision.validated => 60,
    IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor => 30,
    IncomingTalentSuccessionCoverageActionOutcomeDecision.reworkCoverage => 14,
    IncomingTalentSuccessionCoverageActionOutcomeDecision.executiveReview => 14,
  };
  return asOfDate.add(Duration(days: days));
}

String defaultCoverageActionOutcomeNextAction(
  IncomingTalentSuccessionCoverageActionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentSuccessionCoverageActionOutcomeDecision.validated =>
      'Archive the evidence and keep the next coverage review on the governance calendar.',
    IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor =>
      'Keep the scope on watch and confirm coverage gains in the next talent council.',
    IncomingTalentSuccessionCoverageActionOutcomeDecision.reworkCoverage =>
      'Reopen coverage design and assign a new slate owner for the critical roles.',
    IncomingTalentSuccessionCoverageActionOutcomeDecision.executiveReview =>
      'Route the evidence to executive sponsors for a coverage recovery decision.',
  };
}

String? coverageActionOutcomeLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String? validateCoverageActionOutcomeActionId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please select a resolved coverage action';
  }
  return null;
}

String? validateCoverageActionOutcomeActionStatus(
  IncomingTalentSuccessionCoverageActionStatus? value,
) {
  if (value == null) return 'Select a resolved coverage action';
  if (value != IncomingTalentSuccessionCoverageActionStatus.resolved) {
    return 'Coverage action must be resolved before outcome review';
  }
  return null;
}

String? validateCoverageActionOutcomeReviewDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select review date';
  if (coverageActionOutcomeDateOnly(
    value,
  ).isBefore(coverageActionOutcomeDateOnly(asOfDate))) {
    return 'Review date cannot be in the past';
  }
  return null;
}

String? validateCoverageActionOutcomeDecision(
  IncomingTalentSuccessionCoverageActionOutcomeDecision? value,
) {
  if (value == null) return 'Select outcome decision';
  return null;
}

String? validateCoverageActionOutcomeResidualRisk(
  IncomingTalentSuccessionCoverageActionResidualRisk? value,
) {
  if (value == null) return 'Select residual risk';
  return null;
}

String? validateCoverageActionOutcomeScoreAfter(int value) {
  if (value < 0 || value > 100) {
    return 'Coverage score must be between 0 and 100';
  }
  return null;
}

String? validateCoverageActionOutcomeNextReviewDate(
  DateTime? reviewDate,
  DateTime? nextReviewDate,
) {
  if (nextReviewDate == null) return 'Select next review date';
  if (reviewDate == null) return null;
  if (!coverageActionOutcomeDateOnly(
    nextReviewDate,
  ).isAfter(coverageActionOutcomeDateOnly(reviewDate))) {
    return 'Next review must be after review date';
  }
  return null;
}

String? validateCoverageActionOutcomeRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

DateTime coverageActionOutcomeDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}
