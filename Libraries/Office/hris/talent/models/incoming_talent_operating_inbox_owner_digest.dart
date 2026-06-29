import 'incoming_talent_operating_inbox_item.dart';

/// Workload band for an owner in the cross-HRIS talent operating inbox.
enum IncomingTalentOperatingInboxOwnerLoad {
  critical('Critical'),
  stretched('Stretched'),
  balanced('Balanced'),
  clear('Clear');

  final String label;

  const IncomingTalentOperatingInboxOwnerLoad(this.label);
}

/// Owner-level rollup for active talent operating inbox work.
class IncomingTalentOperatingInboxOwnerDigest {
  final String ownerName;
  final IncomingTalentOperatingInboxOwnerLoad load;
  final int totalCount;
  final int criticalCount;
  final int watchCount;
  final int routineCount;
  final int overdueCount;
  final int dueSoonCount;
  final int riskCouncilCount;
  final int developmentCount;
  final int successionCount;
  final int promotionCount;
  final DateTime earliestDueDate;
  final String nextAction;
  final List<String> itemIds;

  const IncomingTalentOperatingInboxOwnerDigest({
    required this.ownerName,
    required this.load,
    required this.totalCount,
    required this.criticalCount,
    required this.watchCount,
    required this.routineCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.riskCouncilCount,
    required this.developmentCount,
    required this.successionCount,
    required this.promotionCount,
    required this.earliestDueDate,
    required this.nextAction,
    required this.itemIds,
  });

  int get sourceCount {
    return [
      riskCouncilCount,
      developmentCount,
      successionCount,
      promotionCount,
    ].where((count) => count > 0).length;
  }

  bool get needsAttention {
    return load == IncomingTalentOperatingInboxOwnerLoad.critical ||
        load == IncomingTalentOperatingInboxOwnerLoad.stretched ||
        criticalCount > 0 ||
        overdueCount > 0;
  }

  int get urgencyRank {
    return switch (load) {
      IncomingTalentOperatingInboxOwnerLoad.critical => 0,
      IncomingTalentOperatingInboxOwnerLoad.stretched => 1,
      IncomingTalentOperatingInboxOwnerLoad.balanced => 2,
      IncomingTalentOperatingInboxOwnerLoad.clear => 3,
    };
  }

  List<IncomingTalentOperatingInboxSource> get activeSources {
    return [
      if (riskCouncilCount > 0)
        IncomingTalentOperatingInboxSource.riskCouncilDecision,
      if (developmentCount > 0)
        IncomingTalentOperatingInboxSource.trainingSession,
      if (successionCount > 0)
        IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
      if (promotionCount > 0)
        IncomingTalentOperatingInboxSource.promotionStabilization,
    ];
  }
}
