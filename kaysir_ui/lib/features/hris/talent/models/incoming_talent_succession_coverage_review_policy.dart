import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

IncomingTalentSuccessionCoverageReviewDecision defaultCoverageReviewDecision(
  IncomingTalentSuccessionCoverageDashboard dashboard,
) {
  if (dashboard.health == IncomingTalentSuccessionCoverageHealth.strong) {
    return IncomingTalentSuccessionCoverageReviewDecision.endorsed;
  }
  if (dashboard.openBenchActionCount > 0 ||
      dashboard.health == IncomingTalentSuccessionCoverageHealth.critical) {
    return IncomingTalentSuccessionCoverageReviewDecision.rework;
  }
  return IncomingTalentSuccessionCoverageReviewDecision.watch;
}

DateTime nextCoverageReviewDateForDecision(
  IncomingTalentSuccessionCoverageReviewDecision decision,
  DateTime asOfDate,
) {
  final days = switch (decision) {
    IncomingTalentSuccessionCoverageReviewDecision.endorsed => 90,
    IncomingTalentSuccessionCoverageReviewDecision.watch => 30,
    IncomingTalentSuccessionCoverageReviewDecision.rework => 14,
    IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation => 7,
  };
  return asOfDate.add(Duration(days: days));
}

String defaultCoverageReviewCommitment(
  IncomingTalentSuccessionCoverageReviewDecision decision,
) {
  return switch (decision) {
    IncomingTalentSuccessionCoverageReviewDecision.endorsed =>
      'Maintain quarterly executive review and keep successor evidence current.',
    IncomingTalentSuccessionCoverageReviewDecision.watch =>
      'Keep the slate on watch and review readiness movement within 30 days.',
    IncomingTalentSuccessionCoverageReviewDecision.rework =>
      'Assign owners to close coverage gaps before the next talent council.',
    IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation =>
      'Escalate critical coverage risks to executive sponsors this week.',
  };
}

String? coverageReviewLongTextError(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $label';
  }
  if (value.trim().length < 12) {
    return '${capitalizeCoverageReviewLabel(label)} must be at least 12 characters';
  }
  return null;
}

String capitalizeCoverageReviewLabel(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime coverageReviewDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
