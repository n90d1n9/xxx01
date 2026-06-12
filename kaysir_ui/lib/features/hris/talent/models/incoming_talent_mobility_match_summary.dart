import 'incoming_talent_mobility_match.dart';

class IncomingTalentMobilityMatchSummary {
  final int totalCount;
  final int proposedCount;
  final int sponsorReviewCount;
  final int acceptedCount;
  final int blockedCount;
  final int activatedCount;
  final int dueSoonCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentMobilityMatchSummary({
    required this.totalCount,
    required this.proposedCount,
    required this.sponsorReviewCount,
    required this.acceptedCount,
    required this.blockedCount,
    required this.activatedCount,
    required this.dueSoonCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentMobilityMatchSummary.fromMatches({
    required List<IncomingTalentMobilityMatch> matches,
    required DateTime asOfDate,
  }) {
    final proposedCount = _countByStatus(
      matches,
      IncomingTalentMobilityMatchStatus.proposed,
    );
    final sponsorReviewCount = _countByStatus(
      matches,
      IncomingTalentMobilityMatchStatus.sponsorReview,
    );
    final acceptedCount = _countByStatus(
      matches,
      IncomingTalentMobilityMatchStatus.accepted,
    );
    final blockedCount = _countByStatus(
      matches,
      IncomingTalentMobilityMatchStatus.blocked,
    );
    final activatedCount = _countByStatus(
      matches,
      IncomingTalentMobilityMatchStatus.activated,
    );
    final dueSoonCount =
        matches.where((match) => match.isDueSoon(asOfDate)).length;
    final attentionCount =
        matches.where((match) => match.needsAttention).length;

    return IncomingTalentMobilityMatchSummary(
      totalCount: matches.length,
      proposedCount: proposedCount,
      sponsorReviewCount: sponsorReviewCount,
      acceptedCount: acceptedCount,
      blockedCount: blockedCount,
      activatedCount: activatedCount,
      dueSoonCount: dueSoonCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: matches.length,
        proposedCount: proposedCount,
        sponsorReviewCount: sponsorReviewCount,
        acceptedCount: acceptedCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentMobilityMatch> matches,
  IncomingTalentMobilityMatchStatus status,
) {
  return matches.where((match) => match.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int proposedCount,
  required int sponsorReviewCount,
  required int acceptedCount,
  required int blockedCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create mobility matches from panel decisions.';
  if (blockedCount > 0) return 'Unblock $blockedCount mobility matches.';
  if (sponsorReviewCount > 0) {
    return 'Confirm $sponsorReviewCount sponsor reviews.';
  }
  if (dueSoonCount > 0) return 'Launch $dueSoonCount mobility moves due soon.';
  if (acceptedCount > 0) return 'Activate $acceptedCount accepted moves.';
  if (proposedCount > 0) return 'Review $proposedCount proposed moves.';
  return 'Mobility matches are activated.';
}
