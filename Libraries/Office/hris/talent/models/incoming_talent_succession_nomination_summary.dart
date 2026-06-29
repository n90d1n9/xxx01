import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';

class IncomingTalentSuccessionNominationSummary {
  final int totalNominations;
  final int panelReviewCount;
  final int approvedCount;
  final int deferredCount;
  final int readyNowCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentSuccessionNominationSummary({
    required this.totalNominations,
    required this.panelReviewCount,
    required this.approvedCount,
    required this.deferredCount,
    required this.readyNowCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionNominationSummary.fromNominations(
    List<IncomingTalentSuccessionNomination> nominations,
  ) {
    final panelReviewCount = _countByStatus(
      nominations,
      IncomingTalentSuccessionNominationStatus.panelReview,
    );
    final approvedCount = _countByStatus(
      nominations,
      IncomingTalentSuccessionNominationStatus.approved,
    );
    final deferredCount = _countByStatus(
      nominations,
      IncomingTalentSuccessionNominationStatus.deferred,
    );
    final readyNowCount =
        nominations
            .where(
              (nomination) =>
                  nomination.readiness ==
                  IncomingTalentSuccessionReadiness.readyNow,
            )
            .length;
    final attentionCount =
        nominations.where((nomination) => nomination.needsAttention).length;

    return IncomingTalentSuccessionNominationSummary(
      totalNominations: nominations.length,
      panelReviewCount: panelReviewCount,
      approvedCount: approvedCount,
      deferredCount: deferredCount,
      readyNowCount: readyNowCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalNominations: nominations.length,
        panelReviewCount: panelReviewCount,
        approvedCount: approvedCount,
        deferredCount: deferredCount,
        attentionCount: attentionCount,
      ),
    );
  }

  static int _countByStatus(
    List<IncomingTalentSuccessionNomination> nominations,
    IncomingTalentSuccessionNominationStatus status,
  ) {
    return nominations
        .where((nomination) => nomination.status == status)
        .length;
  }

  static String _nextAction({
    required int totalNominations,
    required int panelReviewCount,
    required int approvedCount,
    required int deferredCount,
    required int attentionCount,
  }) {
    if (totalNominations == 0) {
      return 'Nominate ready successors for panel review.';
    }
    if (deferredCount > 0) {
      return 'Resolve $deferredCount deferred nominations.';
    }
    if (attentionCount > 0) {
      return 'Follow up $attentionCount nomination risks.';
    }
    if (panelReviewCount > 0) {
      return 'Prepare $panelReviewCount nominations for panel review.';
    }
    if (approvedCount > 0) {
      return 'Activate $approvedCount approved succession moves.';
    }
    return 'Succession nominations are current.';
  }
}
