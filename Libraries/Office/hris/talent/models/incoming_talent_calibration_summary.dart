import 'incoming_talent_calibration_packet.dart';
import 'incoming_talent_calibration_review.dart';

class IncomingTalentCalibrationSummary {
  final int totalCount;
  final int accelerateCount;
  final int maintainCount;
  final int coachCount;
  final int escalateCount;
  final int highPotentialCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentCalibrationSummary({
    required this.totalCount,
    required this.accelerateCount,
    required this.maintainCount,
    required this.coachCount,
    required this.escalateCount,
    required this.highPotentialCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentCalibrationSummary.fromPackets(
    List<IncomingTalentCalibrationPacket> packets,
  ) {
    final accelerateCount = _countRecommendation(
      packets,
      IncomingTalentCalibrationRecommendation.accelerate,
    );
    final maintainCount = _countRecommendation(
      packets,
      IncomingTalentCalibrationRecommendation.maintainCadence,
    );
    final coachCount = _countRecommendation(
      packets,
      IncomingTalentCalibrationRecommendation.coach,
    );
    final escalateCount = _countRecommendation(
      packets,
      IncomingTalentCalibrationRecommendation.escalate,
    );
    final highPotentialCount =
        packets
            .where(
              (packet) =>
                  packet.potential == IncomingTalentCalibrationPotential.high,
            )
            .length;
    final attentionCount =
        packets.where((packet) => packet.needsAttention).length;

    return IncomingTalentCalibrationSummary(
      totalCount: packets.length,
      accelerateCount: accelerateCount,
      maintainCount: maintainCount,
      coachCount: coachCount,
      escalateCount: escalateCount,
      highPotentialCount: highPotentialCount,
      attentionCount: attentionCount,
      nextAction: _packetNextAction(
        totalCount: packets.length,
        coachCount: coachCount,
        escalateCount: escalateCount,
        highPotentialCount: highPotentialCount,
      ),
    );
  }

  factory IncomingTalentCalibrationSummary.fromReviews(
    List<IncomingTalentCalibrationReview> reviews,
  ) {
    final accelerateCount = _countDecision(
      reviews,
      IncomingTalentCalibrationDecision.accelerateGrowth,
    );
    final maintainCount = _countDecision(
      reviews,
      IncomingTalentCalibrationDecision.maintainTrack,
    );
    final coachCount = _countDecision(
      reviews,
      IncomingTalentCalibrationDecision.coachingPlan,
    );
    final escalateCount = _countDecision(
      reviews,
      IncomingTalentCalibrationDecision.retentionEscalation,
    );
    final highPotentialCount =
        reviews
            .where(
              (review) =>
                  review.potential == IncomingTalentCalibrationPotential.high,
            )
            .length;
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;

    return IncomingTalentCalibrationSummary(
      totalCount: reviews.length,
      accelerateCount: accelerateCount,
      maintainCount: maintainCount,
      coachCount: coachCount,
      escalateCount: escalateCount,
      highPotentialCount: highPotentialCount,
      attentionCount: attentionCount,
      nextAction: _reviewNextAction(
        totalCount: reviews.length,
        coachCount: coachCount,
        escalateCount: escalateCount,
        highPotentialCount: highPotentialCount,
      ),
    );
  }
}

int _countRecommendation(
  List<IncomingTalentCalibrationPacket> packets,
  IncomingTalentCalibrationRecommendation recommendation,
) {
  return packets
      .where((packet) => packet.recommendation == recommendation)
      .length;
}

int _countDecision(
  List<IncomingTalentCalibrationReview> reviews,
  IncomingTalentCalibrationDecision decision,
) {
  return reviews.where((review) => review.decision == decision).length;
}

String _packetNextAction({
  required int totalCount,
  required int coachCount,
  required int escalateCount,
  required int highPotentialCount,
}) {
  if (totalCount == 0) return 'Build calibration packets from talent signals.';
  if (escalateCount > 0) return 'Calibrate $escalateCount retention risks.';
  if (coachCount > 0) return 'Calibrate $coachCount coaching decisions.';
  if (highPotentialCount > 0) {
    return 'Review $highPotentialCount high-potential growth packets.';
  }
  return 'Keep talent calibration packets on cadence.';
}

String _reviewNextAction({
  required int totalCount,
  required int coachCount,
  required int escalateCount,
  required int highPotentialCount,
}) {
  if (totalCount == 0) return 'Submit calibration reviews.';
  if (escalateCount > 0) return 'Follow through $escalateCount escalations.';
  if (coachCount > 0) return 'Track $coachCount coaching calibrations.';
  if (highPotentialCount > 0) {
    return 'Activate $highPotentialCount high-potential tracks.';
  }
  return 'Keep calibration decisions current.';
}
