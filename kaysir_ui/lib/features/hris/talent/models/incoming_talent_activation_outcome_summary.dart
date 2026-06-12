import 'incoming_talent_activation_outcome.dart';

class IncomingTalentActivationOutcomeSummary {
  final int totalCount;
  final int stabilizedCount;
  final int extendedSupportCount;
  final int developmentTrackCount;
  final int escalatedCount;
  final int highRiskCount;
  final double averageReadinessScore;
  final String nextAction;

  const IncomingTalentActivationOutcomeSummary({
    required this.totalCount,
    required this.stabilizedCount,
    required this.extendedSupportCount,
    required this.developmentTrackCount,
    required this.escalatedCount,
    required this.highRiskCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory IncomingTalentActivationOutcomeSummary.fromReviews(
    List<IncomingTalentActivationOutcomeReview> reviews,
  ) {
    final stabilizedCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentActivationOutcomeDecision.stabilized,
            )
            .length;
    final extendedSupportCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentActivationOutcomeDecision.extendSupport,
            )
            .length;
    final developmentTrackCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentActivationOutcomeDecision
                      .assignDevelopmentTrack,
            )
            .length;
    final escalatedCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentActivationOutcomeDecision.escalateRisk,
            )
            .length;
    final highRiskCount =
        reviews
            .where(
              (review) =>
                  review.retentionRisk ==
                  IncomingTalentActivationRetentionRisk.high,
            )
            .length;
    final totalReadiness = reviews.fold<int>(
      0,
      (total, review) => total + review.readinessScore,
    );

    return IncomingTalentActivationOutcomeSummary(
      totalCount: reviews.length,
      stabilizedCount: stabilizedCount,
      extendedSupportCount: extendedSupportCount,
      developmentTrackCount: developmentTrackCount,
      escalatedCount: escalatedCount,
      highRiskCount: highRiskCount,
      averageReadinessScore:
          reviews.isEmpty ? 0 : totalReadiness / reviews.length,
      nextAction: _nextAction(
        totalCount: reviews.length,
        stabilizedCount: stabilizedCount,
        extendedSupportCount: extendedSupportCount,
        developmentTrackCount: developmentTrackCount,
        escalatedCount: escalatedCount,
        highRiskCount: highRiskCount,
      ),
    );
  }
}

String _nextAction({
  required int totalCount,
  required int stabilizedCount,
  required int extendedSupportCount,
  required int developmentTrackCount,
  required int escalatedCount,
  required int highRiskCount,
}) {
  if (totalCount == 0) return 'Submit activation outcome reviews.';
  if (escalatedCount > 0 || highRiskCount > 0) {
    return 'Escalate $escalatedCount high-risk activation outcomes.';
  }
  if (extendedSupportCount > 0) {
    return 'Extend support for $extendedSupportCount activation outcomes.';
  }
  if (developmentTrackCount > 0) {
    return 'Assign $developmentTrackCount development tracks.';
  }
  return 'Move $stabilizedCount stabilized hires into regular talent cadence.';
}
