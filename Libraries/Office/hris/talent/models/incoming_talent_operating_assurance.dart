/// Audit readiness level for a talent operating workstream.
enum IncomingTalentOperatingAssuranceLevel {
  exposed('Exposed'),
  guarded('Guarded'),
  ready('Ready');

  final String label;

  const IncomingTalentOperatingAssuranceLevel(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingAssuranceLevel.exposed => 0,
      IncomingTalentOperatingAssuranceLevel.guarded => 1,
      IncomingTalentOperatingAssuranceLevel.ready => 2,
    };
  }
}

/// Workstream-level audit assurance for active talent operations.
class IncomingTalentOperatingAssuranceWorkstream {
  final String workstreamLabel;
  final IncomingTalentOperatingAssuranceLevel level;
  final int gapCount;
  final int criticalGapCount;
  final int highGapCount;
  final int watchGapCount;
  final int overdueGapCount;
  final int dueTodayGapCount;
  final int linkedEscalationCount;
  final int ownerCount;
  final DateTime? nextDueDate;
  final String nextAction;
  final List<String> gapIds;

  const IncomingTalentOperatingAssuranceWorkstream({
    required this.workstreamLabel,
    required this.level,
    required this.gapCount,
    required this.criticalGapCount,
    required this.highGapCount,
    required this.watchGapCount,
    required this.overdueGapCount,
    required this.dueTodayGapCount,
    required this.linkedEscalationCount,
    required this.ownerCount,
    required this.nextDueDate,
    required this.nextAction,
    required this.gapIds,
  });

  int get urgencyRank => level.sortRank;

  bool get needsAttention {
    return level != IncomingTalentOperatingAssuranceLevel.ready;
  }

  double get exposureRatio {
    if (gapCount == 0) return 0;

    final score =
        (criticalGapCount * 3) +
        (highGapCount * 2) +
        watchGapCount +
        (overdueGapCount * 3) +
        (dueTodayGapCount * 2) +
        linkedEscalationCount;
    final ratio = score / (gapCount * 10);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}
