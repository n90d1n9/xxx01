/// Cross-HRIS workstream represented in the talent operating view.
enum IncomingTalentOperatingWorkstream {
  riskCouncil('Risk council'),
  development('Development'),
  succession('Succession'),
  promotion('Promotion');

  final String label;

  const IncomingTalentOperatingWorkstream(this.label);
}

/// Pressure level for a talent operating workstream.
enum IncomingTalentOperatingWorkstreamPressureLevel {
  critical('Critical'),
  elevated('Elevated'),
  steady('Steady');

  final String label;

  const IncomingTalentOperatingWorkstreamPressureLevel(this.label);
}

/// Ranked pressure snapshot for one talent operating workstream.
class IncomingTalentOperatingWorkstreamPressure {
  final IncomingTalentOperatingWorkstream workstream;
  final IncomingTalentOperatingWorkstreamPressureLevel level;
  final int totalCount;
  final int criticalCount;
  final int watchCount;
  final int routineCount;
  final int overdueCount;
  final int dueSoonCount;
  final int ownerCount;
  final int overloadedOwnerCount;
  final DateTime earliestDueDate;
  final String nextAction;
  final List<String> itemIds;

  const IncomingTalentOperatingWorkstreamPressure({
    required this.workstream,
    required this.level,
    required this.totalCount,
    required this.criticalCount,
    required this.watchCount,
    required this.routineCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.ownerCount,
    required this.overloadedOwnerCount,
    required this.earliestDueDate,
    required this.nextAction,
    required this.itemIds,
  });

  bool get needsAttention {
    return level == IncomingTalentOperatingWorkstreamPressureLevel.critical ||
        level == IncomingTalentOperatingWorkstreamPressureLevel.elevated;
  }

  int get urgencyRank {
    return switch (level) {
      IncomingTalentOperatingWorkstreamPressureLevel.critical => 0,
      IncomingTalentOperatingWorkstreamPressureLevel.elevated => 1,
      IncomingTalentOperatingWorkstreamPressureLevel.steady => 2,
    };
  }

  double get pressureRatio {
    if (totalCount == 0) return 0;

    final score =
        (criticalCount * 2) +
        (overdueCount * 2) +
        dueSoonCount +
        overloadedOwnerCount;
    final ratio = score / (totalCount * 4);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}
