import 'incoming_talent_promotion_readiness.dart';

/// Aggregates promotion-readiness packets into calibration metrics.
class IncomingTalentPromotionReadinessSummary {
  final int totalCount;
  final int readyNowCount;
  final int readySoonCount;
  final int developingCount;
  final int blockedCount;
  final int endorsedCount;
  final int holdCount;
  final int attentionCount;
  final double averageReadinessScore;
  final String nextAction;

  const IncomingTalentPromotionReadinessSummary({
    required this.totalCount,
    required this.readyNowCount,
    required this.readySoonCount,
    required this.developingCount,
    required this.blockedCount,
    required this.endorsedCount,
    required this.holdCount,
    required this.attentionCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory IncomingTalentPromotionReadinessSummary.fromReadinessPackets(
    List<IncomingTalentPromotionReadiness> packets,
  ) {
    final readyNowCount = _countRating(
      packets,
      IncomingTalentPromotionReadinessRating.readyNow,
    );
    final readySoonCount = _countRating(
      packets,
      IncomingTalentPromotionReadinessRating.readySoon,
    );
    final developingCount = _countRating(
      packets,
      IncomingTalentPromotionReadinessRating.developing,
    );
    final blockedCount = _countRating(
      packets,
      IncomingTalentPromotionReadinessRating.blocked,
    );
    final endorsedCount = _countStatus(
      packets,
      IncomingTalentPromotionReadinessStatus.endorsed,
    );
    final holdCount = _countStatus(
      packets,
      IncomingTalentPromotionReadinessStatus.hold,
    );
    final attentionCount =
        packets.where((packet) => packet.needsAttention).length;
    final readinessTotal = packets.fold<double>(
      0,
      (total, packet) => total + packet.readinessScore,
    );

    return IncomingTalentPromotionReadinessSummary(
      totalCount: packets.length,
      readyNowCount: readyNowCount,
      readySoonCount: readySoonCount,
      developingCount: developingCount,
      blockedCount: blockedCount,
      endorsedCount: endorsedCount,
      holdCount: holdCount,
      attentionCount: attentionCount,
      averageReadinessScore:
          packets.isEmpty ? 0 : readinessTotal / packets.length,
      nextAction: _nextAction(
        totalCount: packets.length,
        blockedCount: blockedCount,
        holdCount: holdCount,
        readyNowCount: readyNowCount,
        readySoonCount: readySoonCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countRating(
  List<IncomingTalentPromotionReadiness> packets,
  IncomingTalentPromotionReadinessRating rating,
) {
  return packets.where((packet) => packet.rating == rating).length;
}

int _countStatus(
  List<IncomingTalentPromotionReadiness> packets,
  IncomingTalentPromotionReadinessStatus status,
) {
  return packets.where((packet) => packet.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int holdCount,
  required int readyNowCount,
  required int readySoonCount,
  required int attentionCount,
}) {
  if (totalCount == 0) {
    return 'Assess career paths with framework coverage.';
  }
  if (blockedCount > 0 || holdCount > 0) {
    return 'Resolve $blockedCount blocked readiness packets.';
  }
  if (readyNowCount > 0) {
    return 'Prepare $readyNowCount promotion endorsements.';
  }
  if (readySoonCount > 0) {
    return 'Calibrate $readySoonCount near-ready promotion cases.';
  }
  if (attentionCount > 0) {
    return 'Coach $attentionCount readiness packets needing support.';
  }
  return 'Keep promotion readiness evidence current.';
}
