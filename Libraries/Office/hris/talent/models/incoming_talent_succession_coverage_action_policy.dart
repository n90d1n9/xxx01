import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

IncomingTalentSuccessionCoverageActionType defaultCoverageActionType(
  IncomingTalentSuccessionCoverageReview review,
) {
  if (review.decision ==
      IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation) {
    return IncomingTalentSuccessionCoverageActionType.executiveSponsor;
  }
  if (review.openBenchActionCount > 0 ||
      review.decision ==
          IncomingTalentSuccessionCoverageReviewDecision.rework) {
    return IncomingTalentSuccessionCoverageActionType.slateRework;
  }
  if (review.coverageHealth == IncomingTalentSuccessionCoverageHealth.watch) {
    return IncomingTalentSuccessionCoverageActionType.readinessAcceleration;
  }
  if (review.attentionSignalCount > 0) {
    return IncomingTalentSuccessionCoverageActionType.riskClosure;
  }
  return IncomingTalentSuccessionCoverageActionType.governanceReview;
}

DateTime defaultCoverageActionDueDate({
  required IncomingTalentSuccessionCoverageReview review,
  required DateTime asOfDate,
}) {
  final days =
      review.decision ==
                  IncomingTalentSuccessionCoverageReviewDecision
                      .executiveEscalation ||
              review.coverageHealth ==
                  IncomingTalentSuccessionCoverageHealth.critical
          ? 7
          : review.decision ==
              IncomingTalentSuccessionCoverageReviewDecision.rework
          ? 14
          : 30;
  return asOfDate.add(Duration(days: days));
}

String defaultCoverageActionEscalationPath(
  IncomingTalentSuccessionCoverageReview review,
) {
  if (review.decision ==
      IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation) {
    return 'Escalate to executive sponsor and HR leadership for weekly coverage recovery.';
  }
  if (review.openBenchActionCount > 0) {
    return 'Route open bench actions through talent council until coverage risk closes.';
  }
  if (review.coverageHealth ==
      IncomingTalentSuccessionCoverageHealth.critical) {
    return 'Escalate critical coverage gaps to HR leadership and department sponsor.';
  }
  return 'Escalate to talent partner if coverage signals remain on watch.';
}

String? coverageActionLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
    return '${capitalizeCoverageActionLabel(label)} must be at least 12 characters';
  }
  return null;
}

String capitalizeCoverageActionLabel(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime coverageActionDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
