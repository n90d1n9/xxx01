import 'incoming_talent_operating_inbox_item.dart';

/// Rollup for the talent operating inbox queue.
class IncomingTalentOperatingInboxSummary {
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
  final String nextAction;

  const IncomingTalentOperatingInboxSummary({
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
    required this.nextAction,
  });

  factory IncomingTalentOperatingInboxSummary.fromItems({
    required List<IncomingTalentOperatingInboxItem> items,
    required DateTime asOfDate,
  }) {
    final criticalCount = _countByPriority(
      items,
      IncomingTalentOperatingInboxPriority.critical,
    );
    final watchCount = _countByPriority(
      items,
      IncomingTalentOperatingInboxPriority.watch,
    );
    final routineCount = _countByPriority(
      items,
      IncomingTalentOperatingInboxPriority.routine,
    );
    final overdueCount = items.where((item) => item.isOverdue(asOfDate)).length;
    final dueSoonCount = items.where((item) => item.isDueSoon(asOfDate)).length;
    final riskCouncilCount =
        _countBySource(
          items,
          IncomingTalentOperatingInboxSource.riskCouncilDecision,
        ) +
        _countBySource(
          items,
          IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
        );
    final developmentCount =
        _countBySource(
          items,
          IncomingTalentOperatingInboxSource.trainingSession,
        ) +
        _countBySource(
          items,
          IncomingTalentOperatingInboxSource.careerPathReview,
        );
    final successionCount = _countBySource(
      items,
      IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
    );
    final promotionCount = _countBySource(
      items,
      IncomingTalentOperatingInboxSource.promotionStabilization,
    );

    return IncomingTalentOperatingInboxSummary(
      totalCount: items.length,
      criticalCount: criticalCount,
      watchCount: watchCount,
      routineCount: routineCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      riskCouncilCount: riskCouncilCount,
      developmentCount: developmentCount,
      successionCount: successionCount,
      promotionCount: promotionCount,
      nextAction: _nextAction(
        totalCount: items.length,
        criticalCount: criticalCount,
        overdueCount: overdueCount,
        dueSoonCount: dueSoonCount,
        riskCouncilCount: riskCouncilCount,
      ),
    );
  }
}

int _countByPriority(
  List<IncomingTalentOperatingInboxItem> items,
  IncomingTalentOperatingInboxPriority priority,
) {
  return items.where((item) => item.priority == priority).length;
}

int _countBySource(
  List<IncomingTalentOperatingInboxItem> items,
  IncomingTalentOperatingInboxSource source,
) {
  return items.where((item) => item.source == source).length;
}

String _nextAction({
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueSoonCount,
  required int riskCouncilCount,
}) {
  if (totalCount == 0) return 'Talent operating inbox is clear.';
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical talent inbox ${_plural(criticalCount, 'item')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent inbox ${_plural(overdueCount, 'item')}.';
  }
  if (riskCouncilCount > 0) {
    return 'Close $riskCouncilCount risk council operating ${_plural(riskCouncilCount, 'item')}.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount talent operating ${_plural(dueSoonCount, 'item')} due soon.';
  }
  return 'Track $totalCount active talent operating ${_plural(totalCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
