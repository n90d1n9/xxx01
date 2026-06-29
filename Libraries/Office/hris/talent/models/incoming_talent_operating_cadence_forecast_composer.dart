import 'incoming_talent_operating_cadence_forecast.dart';
import 'incoming_talent_operating_inbox_item.dart';

/// Builds due-date cadence buckets from active talent operating inbox work.
List<IncomingTalentOperatingCadenceBucket>
buildIncomingTalentOperatingCadenceBuckets({
  required List<IncomingTalentOperatingInboxItem> items,
  required DateTime asOfDate,
}) {
  final byWindow = <
    IncomingTalentOperatingCadenceWindow,
    List<IncomingTalentOperatingInboxItem>
  >{
    for (final window in IncomingTalentOperatingCadenceWindow.values)
      window: <IncomingTalentOperatingInboxItem>[],
  };

  for (final item in items) {
    byWindow[_windowFor(item, asOfDate)]!.add(item);
  }

  final buckets =
      IncomingTalentOperatingCadenceWindow.values.map((window) {
          return _bucketForWindow(
            window: window,
            items: byWindow[window] ?? const [],
            asOfDate: asOfDate,
          );
        }).toList()
        ..sort(_compareBuckets);

  return buckets;
}

IncomingTalentOperatingCadenceBucket _bucketForWindow({
  required IncomingTalentOperatingCadenceWindow window,
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
  final dueTodayCount =
      items.where((item) => item.daysUntilDue(asOfDate) == 0).length;
  final ownerCount =
      items.map((item) => _ownerName(item.ownerName)).toSet().length;
  final workstreamCount = items.map(_workstreamKeyFor).toSet().length;
  final risk = _riskFor(
    totalCount: items.length,
    criticalCount: criticalCount,
    watchCount: watchCount,
    overdueCount: overdueCount,
    dueTodayCount: dueTodayCount,
    window: window,
  );

  return IncomingTalentOperatingCadenceBucket(
    window: window,
    risk: risk,
    totalCount: items.length,
    criticalCount: criticalCount,
    watchCount: watchCount,
    routineCount: routineCount,
    overdueCount: overdueCount,
    dueTodayCount: dueTodayCount,
    ownerCount: ownerCount,
    workstreamCount: workstreamCount,
    earliestDueDate: _earliestDueDate(items, asOfDate),
    nextAction: _nextAction(
      window: window,
      totalCount: items.length,
      criticalCount: criticalCount,
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
    ),
    itemIds: items.map((item) => item.id).toList(),
  );
}

IncomingTalentOperatingCadenceWindow _windowFor(
  IncomingTalentOperatingInboxItem item,
  DateTime asOfDate,
) {
  final days = item.daysUntilDue(asOfDate);
  if (days < 0) return IncomingTalentOperatingCadenceWindow.overdue;
  if (days == 0) return IncomingTalentOperatingCadenceWindow.dueToday;
  if (days <= 7) return IncomingTalentOperatingCadenceWindow.next7Days;
  if (days <= 14) return IncomingTalentOperatingCadenceWindow.next14Days;
  return IncomingTalentOperatingCadenceWindow.later;
}

String _ownerName(String value) {
  final ownerName = value.trim();
  return ownerName.isEmpty ? 'Unassigned owner' : ownerName;
}

String _workstreamKeyFor(IncomingTalentOperatingInboxItem item) {
  return switch (item.source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp => 'risk-council',
    IncomingTalentOperatingInboxSource.trainingSession ||
    IncomingTalentOperatingInboxSource.careerPathReview => 'development',
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      'succession',
    IncomingTalentOperatingInboxSource.promotionStabilization => 'promotion',
  };
}

int _countByPriority(
  List<IncomingTalentOperatingInboxItem> items,
  IncomingTalentOperatingInboxPriority priority,
) {
  return items.where((item) => item.priority == priority).length;
}

DateTime _earliestDueDate(
  List<IncomingTalentOperatingInboxItem> items,
  DateTime asOfDate,
) {
  final dueDates = items.map((item) => item.dueDate).toList()..sort();
  if (dueDates.isEmpty) return asOfDate;
  return dueDates.first;
}

IncomingTalentOperatingCadenceRisk _riskFor({
  required int totalCount,
  required int criticalCount,
  required int watchCount,
  required int overdueCount,
  required int dueTodayCount,
  required IncomingTalentOperatingCadenceWindow window,
}) {
  if (totalCount == 0) return IncomingTalentOperatingCadenceRisk.steady;
  if (overdueCount > 0 || criticalCount > 0) {
    return IncomingTalentOperatingCadenceRisk.critical;
  }
  if (dueTodayCount > 0 ||
      watchCount > 0 ||
      window == IncomingTalentOperatingCadenceWindow.next7Days) {
    return IncomingTalentOperatingCadenceRisk.watch;
  }
  return IncomingTalentOperatingCadenceRisk.steady;
}

String _nextAction({
  required IncomingTalentOperatingCadenceWindow window,
  required int totalCount,
  required int criticalCount,
  required int overdueCount,
  required int dueTodayCount,
}) {
  if (totalCount == 0) return '${window.label} cadence is clear.';
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent cadence ${_plural(overdueCount, 'item')}.';
  }
  if (dueTodayCount > 0) {
    return 'Close $dueTodayCount talent cadence ${_plural(dueTodayCount, 'item')} due today.';
  }
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical talent cadence ${_plural(criticalCount, 'item')} in ${window.label.toLowerCase()}.';
  }
  if (window == IncomingTalentOperatingCadenceWindow.next7Days) {
    return 'Close $totalCount talent cadence ${_plural(totalCount, 'item')} due this week.';
  }
  if (window == IncomingTalentOperatingCadenceWindow.next14Days) {
    return 'Prepare $totalCount talent cadence ${_plural(totalCount, 'item')} due within 14 days.';
  }
  return 'Track $totalCount later talent cadence ${_plural(totalCount, 'item')}.';
}

int _compareBuckets(
  IncomingTalentOperatingCadenceBucket left,
  IncomingTalentOperatingCadenceBucket right,
) {
  final window = left.window.sortRank.compareTo(right.window.sortRank);
  if (window != 0) return window;

  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final total = right.totalCount.compareTo(left.totalCount);
  if (total != 0) return total;

  return left.window.label.compareTo(right.window.label);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
