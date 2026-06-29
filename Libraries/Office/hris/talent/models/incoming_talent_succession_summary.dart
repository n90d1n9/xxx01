import 'incoming_talent_succession_candidate.dart';

/// Aggregate succession slate metrics and the recommended next action.
class IncomingTalentSuccessionSummary {
  final int totalCandidates;
  final int readyNowCount;
  final int readySoonCount;
  final int developingCount;
  final int blockedCount;
  final int openInterventions;
  final String nextAction;

  const IncomingTalentSuccessionSummary({
    required this.totalCandidates,
    required this.readyNowCount,
    required this.readySoonCount,
    required this.developingCount,
    required this.blockedCount,
    required this.openInterventions,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionSummary.fromCandidates(
    List<IncomingTalentSuccessionCandidate> candidates,
  ) {
    final readyNowCount = _countByReadiness(
      candidates,
      IncomingTalentSuccessionReadiness.readyNow,
    );
    final readySoonCount = _countByReadiness(
      candidates,
      IncomingTalentSuccessionReadiness.readySoon,
    );
    final developingCount = _countByReadiness(
      candidates,
      IncomingTalentSuccessionReadiness.developing,
    );
    final blockedCount = _countByReadiness(
      candidates,
      IncomingTalentSuccessionReadiness.blocked,
    );
    final openInterventions = candidates.fold<int>(
      0,
      (total, candidate) => total + candidate.openInterventionCount,
    );

    return IncomingTalentSuccessionSummary(
      totalCandidates: candidates.length,
      readyNowCount: readyNowCount,
      readySoonCount: readySoonCount,
      developingCount: developingCount,
      blockedCount: blockedCount,
      openInterventions: openInterventions,
      nextAction: _nextAction(
        totalCandidates: candidates.length,
        readyNowCount: readyNowCount,
        readySoonCount: readySoonCount,
        developingCount: developingCount,
        blockedCount: blockedCount,
        openInterventions: openInterventions,
      ),
    );
  }

  static int _countByReadiness(
    List<IncomingTalentSuccessionCandidate> candidates,
    IncomingTalentSuccessionReadiness readiness,
  ) {
    return candidates
        .where((candidate) => candidate.readiness == readiness)
        .length;
  }

  static String _nextAction({
    required int totalCandidates,
    required int readyNowCount,
    required int readySoonCount,
    required int developingCount,
    required int blockedCount,
    required int openInterventions,
  }) {
    if (totalCandidates == 0) {
      return 'Build profile timelines to create a succession slate.';
    }
    if (openInterventions > 0) {
      return 'Unblock $openInterventions succession actions.';
    }
    if (blockedCount > 0) {
      return 'Review $blockedCount blocked succession profiles.';
    }
    if (readyNowCount > 0) {
      return 'Nominate $readyNowCount ready-now ${_profileNoun(readyNowCount)}.';
    }
    if (readySoonCount > 0) {
      return 'Sponsor $readySoonCount ready-soon ${_profileNoun(readySoonCount)}.';
    }
    if (developingCount > 0) {
      return 'Review $developingCount developing succession ${_profileNoun(developingCount)}.';
    }
    return 'Keep developing the succession bench.';
  }

  static String _profileNoun(int count) {
    return count == 1 ? 'successor' : 'successors';
  }
}
