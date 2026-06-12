import 'incoming_talent_operating_inbox_item.dart';
import 'incoming_talent_operating_inbox_owner_digest.dart';

/// Builds owner workload digests from active talent operating inbox items.
List<IncomingTalentOperatingInboxOwnerDigest>
buildIncomingTalentOperatingInboxOwnerDigests({
  required List<IncomingTalentOperatingInboxItem> items,
  required DateTime asOfDate,
}) {
  final byOwner = <String, List<IncomingTalentOperatingInboxItem>>{};

  for (final item in items) {
    final ownerName =
        item.ownerName.trim().isEmpty
            ? 'Unassigned owner'
            : item.ownerName.trim();
    byOwner.putIfAbsent(ownerName, () => []).add(item);
  }

  final digests =
      byOwner.entries.map((entry) {
          return _digestForOwner(
            ownerName: entry.key,
            items: entry.value,
            asOfDate: asOfDate,
          );
        }).toList()
        ..sort(_compareDigests);

  return digests;
}

IncomingTalentOperatingInboxOwnerDigest _digestForOwner({
  required String ownerName,
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
  final load = _loadFor(
    totalCount: items.length,
    criticalCount: criticalCount,
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
  );

  return IncomingTalentOperatingInboxOwnerDigest(
    ownerName: ownerName,
    load: load,
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
    earliestDueDate: _earliestDueDate(items, asOfDate),
    nextAction: _nextAction(
      ownerName: ownerName,
      totalCount: items.length,
      criticalCount: criticalCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      riskCouncilCount: riskCouncilCount,
    ),
    itemIds: items.map((item) => item.id).toList(),
  );
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

DateTime _earliestDueDate(
  List<IncomingTalentOperatingInboxItem> items,
  DateTime asOfDate,
) {
  final dueDates = items.map((item) => item.dueDate).toList()..sort();
  if (dueDates.isEmpty) return asOfDate;
  return dueDates.first;
}

IncomingTalentOperatingInboxOwnerLoad _loadFor({
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return IncomingTalentOperatingInboxOwnerLoad.clear;
  if (overdueCount > 0 || criticalCount >= 2) {
    return IncomingTalentOperatingInboxOwnerLoad.critical;
  }
  if (criticalCount == 1 || dueSoonCount >= 2 || totalCount >= 4) {
    return IncomingTalentOperatingInboxOwnerLoad.stretched;
  }
  return IncomingTalentOperatingInboxOwnerLoad.balanced;
}

String _nextAction({
  required String ownerName,
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueSoonCount,
  required int riskCouncilCount,
}) {
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent inbox ${_plural(overdueCount, 'item')} with $ownerName.';
  }
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical talent inbox ${_plural(criticalCount, 'item')} with $ownerName.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount talent inbox ${_plural(dueSoonCount, 'item')} due soon with $ownerName.';
  }
  if (riskCouncilCount > 0) {
    return 'Coordinate $riskCouncilCount risk council talent ${_plural(riskCouncilCount, 'item')} with $ownerName.';
  }
  if (totalCount > 0) {
    return 'Track $totalCount assigned talent inbox ${_plural(totalCount, 'item')} with $ownerName.';
  }
  return '$ownerName has no active talent inbox items.';
}

int _compareDigests(
  IncomingTalentOperatingInboxOwnerDigest left,
  IncomingTalentOperatingInboxOwnerDigest right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final critical = right.criticalCount.compareTo(left.criticalCount);
  if (critical != 0) return critical;

  final overdue = right.overdueCount.compareTo(left.overdueCount);
  if (overdue != 0) return overdue;

  final dueSoon = right.dueSoonCount.compareTo(left.dueSoonCount);
  if (dueSoon != 0) return dueSoon;

  final total = right.totalCount.compareTo(left.totalCount);
  if (total != 0) return total;

  final dueDate = left.earliestDueDate.compareTo(right.earliestDueDate);
  if (dueDate != 0) return dueDate;

  return left.ownerName.compareTo(right.ownerName);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
