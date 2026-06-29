import 'incoming_talent_operating_inbox_item.dart';
import 'incoming_talent_operating_inbox_owner_digest.dart';
import 'incoming_talent_operating_workstream_pressure.dart';

/// Builds pressure rows for talent workstreams from inbox and owner data.
List<IncomingTalentOperatingWorkstreamPressure>
buildIncomingTalentOperatingWorkstreamPressures({
  required List<IncomingTalentOperatingInboxItem> items,
  required List<IncomingTalentOperatingInboxOwnerDigest> ownerDigests,
  required DateTime asOfDate,
}) {
  final pressures =
      IncomingTalentOperatingWorkstream.values.map((workstream) {
          return _pressureForWorkstream(
            workstream: workstream,
            items: items.where((item) => _workstreamFor(item) == workstream),
            ownerDigests: ownerDigests,
            asOfDate: asOfDate,
          );
        }).toList()
        ..sort(_comparePressures);

  return pressures;
}

IncomingTalentOperatingWorkstreamPressure _pressureForWorkstream({
  required IncomingTalentOperatingWorkstream workstream,
  required Iterable<IncomingTalentOperatingInboxItem> items,
  required List<IncomingTalentOperatingInboxOwnerDigest> ownerDigests,
  required DateTime asOfDate,
}) {
  final workstreamItems = items.toList();
  final criticalCount = _countByPriority(
    workstreamItems,
    IncomingTalentOperatingInboxPriority.critical,
  );
  final watchCount = _countByPriority(
    workstreamItems,
    IncomingTalentOperatingInboxPriority.watch,
  );
  final routineCount = _countByPriority(
    workstreamItems,
    IncomingTalentOperatingInboxPriority.routine,
  );
  final overdueCount =
      workstreamItems.where((item) => item.isOverdue(asOfDate)).length;
  final dueSoonCount =
      workstreamItems.where((item) => item.isDueSoon(asOfDate)).length;
  final ownerCount =
      workstreamItems.map((item) => _ownerName(item.ownerName)).toSet().length;
  final overloadedOwnerCount =
      ownerDigests
          .where(
            (owner) =>
                owner.needsAttention &&
                _ownerWorkstreamCount(owner, workstream) > 0,
          )
          .length;
  final level = _levelFor(
    totalCount: workstreamItems.length,
    criticalCount: criticalCount,
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
    overloadedOwnerCount: overloadedOwnerCount,
  );

  return IncomingTalentOperatingWorkstreamPressure(
    workstream: workstream,
    level: level,
    totalCount: workstreamItems.length,
    criticalCount: criticalCount,
    watchCount: watchCount,
    routineCount: routineCount,
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
    ownerCount: ownerCount,
    overloadedOwnerCount: overloadedOwnerCount,
    earliestDueDate: _earliestDueDate(workstreamItems, asOfDate),
    nextAction: _nextAction(
      workstream: workstream,
      totalCount: workstreamItems.length,
      criticalCount: criticalCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      overloadedOwnerCount: overloadedOwnerCount,
    ),
    itemIds: workstreamItems.map((item) => item.id).toList(),
  );
}

IncomingTalentOperatingWorkstream _workstreamFor(
  IncomingTalentOperatingInboxItem item,
) {
  return switch (item.source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource
        .riskCouncilFollowUp => IncomingTalentOperatingWorkstream.riskCouncil,
    IncomingTalentOperatingInboxSource.trainingSession ||
    IncomingTalentOperatingInboxSource
        .careerPathReview => IncomingTalentOperatingWorkstream.development,
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      IncomingTalentOperatingWorkstream.succession,
    IncomingTalentOperatingInboxSource.promotionStabilization =>
      IncomingTalentOperatingWorkstream.promotion,
  };
}

String _ownerName(String value) {
  final ownerName = value.trim();
  return ownerName.isEmpty ? 'Unassigned owner' : ownerName;
}

int _countByPriority(
  List<IncomingTalentOperatingInboxItem> items,
  IncomingTalentOperatingInboxPriority priority,
) {
  return items.where((item) => item.priority == priority).length;
}

int _ownerWorkstreamCount(
  IncomingTalentOperatingInboxOwnerDigest owner,
  IncomingTalentOperatingWorkstream workstream,
) {
  return switch (workstream) {
    IncomingTalentOperatingWorkstream.riskCouncil => owner.riskCouncilCount,
    IncomingTalentOperatingWorkstream.development => owner.developmentCount,
    IncomingTalentOperatingWorkstream.succession => owner.successionCount,
    IncomingTalentOperatingWorkstream.promotion => owner.promotionCount,
  };
}

DateTime _earliestDueDate(
  List<IncomingTalentOperatingInboxItem> items,
  DateTime asOfDate,
) {
  final dueDates = items.map((item) => item.dueDate).toList()..sort();
  if (dueDates.isEmpty) return asOfDate;
  return dueDates.first;
}

IncomingTalentOperatingWorkstreamPressureLevel _levelFor({
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueSoonCount,
  required int overloadedOwnerCount,
}) {
  if (totalCount == 0) {
    return IncomingTalentOperatingWorkstreamPressureLevel.steady;
  }
  if (overdueCount > 0 || criticalCount >= 2) {
    return IncomingTalentOperatingWorkstreamPressureLevel.critical;
  }
  if (criticalCount == 1 ||
      dueSoonCount >= 2 ||
      overloadedOwnerCount > 0 ||
      totalCount >= 4) {
    return IncomingTalentOperatingWorkstreamPressureLevel.elevated;
  }
  return IncomingTalentOperatingWorkstreamPressureLevel.steady;
}

String _nextAction({
  required IncomingTalentOperatingWorkstream workstream,
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueSoonCount,
  required int overloadedOwnerCount,
}) {
  if (totalCount == 0) return '${workstream.label} operating work is clear.';
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue ${workstream.label.toLowerCase()} ${_plural(overdueCount, 'item')}.';
  }
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical ${workstream.label.toLowerCase()} ${_plural(criticalCount, 'item')}.';
  }
  if (overloadedOwnerCount > 0) {
    return 'Rebalance $overloadedOwnerCount overloaded ${workstream.label.toLowerCase()} ${_plural(overloadedOwnerCount, 'owner')}.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount ${workstream.label.toLowerCase()} ${_plural(dueSoonCount, 'item')} due soon.';
  }
  return 'Track $totalCount active ${workstream.label.toLowerCase()} ${_plural(totalCount, 'item')}.';
}

int _comparePressures(
  IncomingTalentOperatingWorkstreamPressure left,
  IncomingTalentOperatingWorkstreamPressure right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = right.overdueCount.compareTo(left.overdueCount);
  if (overdue != 0) return overdue;

  final critical = right.criticalCount.compareTo(left.criticalCount);
  if (critical != 0) return critical;

  final overloaded = right.overloadedOwnerCount.compareTo(
    left.overloadedOwnerCount,
  );
  if (overloaded != 0) return overloaded;

  final total = right.totalCount.compareTo(left.totalCount);
  if (total != 0) return total;

  return left.workstream.label.compareTo(right.workstream.label);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
