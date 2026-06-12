/// Due-date window used by the talent operating cadence forecast.
enum IncomingTalentOperatingCadenceWindow {
  overdue('Overdue'),
  dueToday('Due today'),
  next7Days('Next 7 days'),
  next14Days('Next 14 days'),
  later('Later');

  final String label;

  const IncomingTalentOperatingCadenceWindow(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingCadenceWindow.overdue => 0,
      IncomingTalentOperatingCadenceWindow.dueToday => 1,
      IncomingTalentOperatingCadenceWindow.next7Days => 2,
      IncomingTalentOperatingCadenceWindow.next14Days => 3,
      IncomingTalentOperatingCadenceWindow.later => 4,
    };
  }
}

/// Risk tier for a due-date window in the talent cadence forecast.
enum IncomingTalentOperatingCadenceRisk {
  critical('Critical'),
  watch('Watch'),
  steady('Steady');

  final String label;

  const IncomingTalentOperatingCadenceRisk(this.label);
}

/// Due-date bucket for active talent operating inbox work.
class IncomingTalentOperatingCadenceBucket {
  final IncomingTalentOperatingCadenceWindow window;
  final IncomingTalentOperatingCadenceRisk risk;
  final int totalCount;
  final int criticalCount;
  final int watchCount;
  final int routineCount;
  final int overdueCount;
  final int dueTodayCount;
  final int ownerCount;
  final int workstreamCount;
  final DateTime earliestDueDate;
  final String nextAction;
  final List<String> itemIds;

  const IncomingTalentOperatingCadenceBucket({
    required this.window,
    required this.risk,
    required this.totalCount,
    required this.criticalCount,
    required this.watchCount,
    required this.routineCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.ownerCount,
    required this.workstreamCount,
    required this.earliestDueDate,
    required this.nextAction,
    required this.itemIds,
  });

  bool get needsAttention {
    return risk == IncomingTalentOperatingCadenceRisk.critical ||
        risk == IncomingTalentOperatingCadenceRisk.watch;
  }

  int get urgencyRank {
    return switch (risk) {
      IncomingTalentOperatingCadenceRisk.critical => 0,
      IncomingTalentOperatingCadenceRisk.watch => 1,
      IncomingTalentOperatingCadenceRisk.steady => 2,
    };
  }

  double get pressureRatio {
    if (totalCount == 0) return 0;

    final score =
        (criticalCount * 2) + (overdueCount * 2) + dueTodayCount + watchCount;
    final ratio = score / (totalCount * 4);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}
