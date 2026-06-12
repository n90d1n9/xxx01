import 'incoming_talent_mobility_match.dart';
import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_panel_decision.dart';

IncomingTalentMobilityMoveType defaultIncomingTalentMobilityMoveType(
  IncomingTalentSuccessionPanelDecision decision,
) {
  return switch (decision.outcome) {
    IncomingTalentSuccessionPanelOutcome.approvePromotion =>
      IncomingTalentMobilityMoveType.promotion,
    IncomingTalentSuccessionPanelOutcome.approveSuccessionBench =>
      IncomingTalentMobilityMoveType.successionCoverage,
    IncomingTalentSuccessionPanelOutcome.conditionalApproval =>
      IncomingTalentMobilityMoveType.stretchAssignment,
    IncomingTalentSuccessionPanelOutcome.defer =>
      IncomingTalentMobilityMoveType.projectRotation,
    IncomingTalentSuccessionPanelOutcome.decline =>
      IncomingTalentMobilityMoveType.lateralMove,
  };
}

int defaultIncomingTalentMobilityFitScore(
  IncomingTalentSuccessionPanelDecision decision,
) {
  final readinessScore = switch (decision.readiness) {
    IncomingTalentSuccessionReadiness.readyNow => 92,
    IncomingTalentSuccessionReadiness.readySoon => 82,
    IncomingTalentSuccessionReadiness.developing => 68,
    IncomingTalentSuccessionReadiness.blocked => 48,
  };
  final riskPenalty = switch (decision.risk) {
    IncomingTalentSuccessionRisk.low => 0,
    IncomingTalentSuccessionRisk.medium => 8,
    IncomingTalentSuccessionRisk.high => 18,
  };
  final outcomePenalty =
      decision.outcome ==
              IncomingTalentSuccessionPanelOutcome.conditionalApproval
          ? 6
          : 0;
  return (readinessScore - riskPenalty - outcomePenalty).clamp(0, 100);
}

String defaultIncomingTalentMobilityOpportunityTitle(
  IncomingTalentSuccessionPanelDecision decision,
) {
  return switch (decision.outcome) {
    IncomingTalentSuccessionPanelOutcome.approvePromotion =>
      decision.targetRole,
    IncomingTalentSuccessionPanelOutcome.approveSuccessionBench =>
      '${decision.targetRole} succession coverage',
    IncomingTalentSuccessionPanelOutcome.conditionalApproval =>
      '${decision.targetRole} stretch scope',
    IncomingTalentSuccessionPanelOutcome.defer =>
      '${decision.targetRole} project rotation',
    IncomingTalentSuccessionPanelOutcome.decline =>
      '${decision.targetRole} lateral exploration',
  };
}

String defaultIncomingTalentMobilityBusinessRationale(
  IncomingTalentSuccessionPanelDecision decision,
) {
  return '${decision.candidateName} is approved for ${decision.targetRole} with ${decision.readiness.label.toLowerCase()} readiness.';
}

String defaultIncomingTalentMobilitySuccessMeasure(
  IncomingTalentSuccessionPanelDecision decision,
) {
  return 'Confirm ${decision.targetRole} impact, manager confidence, and role readiness in first review.';
}

String defaultIncomingTalentMobilitySupportPlan(
  IncomingTalentSuccessionPanelDecision decision,
) {
  return 'Sponsor, host manager, and mentor align weekly until the first mobility review.';
}

String? validateIncomingTalentMobilityRequired(
  String? value,
  String fieldName,
) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName';
  }
  return null;
}

String? validateIncomingTalentMobilityMoveType(
  IncomingTalentMobilityMoveType? value,
) {
  if (value == null) return 'Select mobility type';
  return null;
}

String? validateIncomingTalentMobilityStatus(
  IncomingTalentMobilityMatchStatus? value,
) {
  if (value == null) return 'Select match status';
  return null;
}

String? validateIncomingTalentMobilityFitScore(int value) {
  if (value < 0 || value > 100) return 'Fit score must be between 0 and 100';
  return null;
}

String? validateIncomingTalentMobilityStartDate(
  DateTime? value,
  DateTime asOfDate,
) {
  if (value == null) return 'Select start date';
  if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
    return 'Start date cannot be in the past';
  }
  return null;
}

String? validateIncomingTalentMobilityReviewDate(
  DateTime? startDate,
  DateTime? reviewDate,
) {
  if (reviewDate == null) return 'Select review date';
  if (startDate == null) return null;
  if (!_dateOnly(reviewDate).isAfter(_dateOnly(startDate))) {
    return 'Review date must be after start date';
  }
  return null;
}

String? incomingTalentMobilityLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
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
