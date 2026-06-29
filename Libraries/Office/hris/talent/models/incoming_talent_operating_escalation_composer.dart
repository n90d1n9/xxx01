import 'incoming_talent_operating_cadence_forecast.dart';
import 'incoming_talent_operating_escalation.dart';
import 'incoming_talent_operating_inbox_item.dart';
import 'incoming_talent_operating_inbox_owner_rebalance.dart';
import 'incoming_talent_operating_workstream_pressure.dart';

/// Builds cross-module escalation rows for talent operations.
List<IncomingTalentOperatingEscalationItem>
buildIncomingTalentOperatingEscalations({
  required List<IncomingTalentOperatingInboxItem> inboxItems,
  required List<IncomingTalentOperatingCadenceBucket> cadenceBuckets,
  required IncomingTalentOperatingInboxOwnerRebalancePlan rebalancePlan,
  required List<IncomingTalentOperatingWorkstreamPressure> workstreamPressures,
  required DateTime asOfDate,
}) {
  final escalations = <IncomingTalentOperatingEscalationItem>[
    ..._cadenceEscalations(cadenceBuckets),
    ..._ownerReliefEscalations(rebalancePlan),
    ..._workstreamEscalations(workstreamPressures, asOfDate),
    ..._inboxEscalations(inboxItems, asOfDate),
  ]..sort(_compareEscalations);

  return escalations;
}

Iterable<IncomingTalentOperatingEscalationItem> _cadenceEscalations(
  List<IncomingTalentOperatingCadenceBucket> buckets,
) sync* {
  for (final bucket in buckets) {
    if (bucket.totalCount == 0 || !bucket.needsAttention) continue;

    yield IncomingTalentOperatingEscalationItem(
      source: IncomingTalentOperatingEscalationSource.cadence,
      severity: _severityForCadence(bucket),
      title: '${bucket.window.label} talent cadence',
      detail:
          '${bucket.totalCount} ${_plural(bucket.totalCount, 'item')} across '
          '${bucket.ownerCount} ${_plural(bucket.ownerCount, 'owner')} and '
          '${bucket.workstreamCount} ${_plural(bucket.workstreamCount, 'workstream')}',
      nextAction: bucket.nextAction,
      signalCount: _positiveSignalCount(
        bucket.criticalCount +
            bucket.overdueCount +
            bucket.dueTodayCount +
            bucket.watchCount,
      ),
      dueDate: bucket.earliestDueDate,
      overdue: bucket.overdueCount > 0,
      dueToday: bucket.dueTodayCount > 0,
      ownerName: null,
      workstreamLabel: null,
      pressureRatio: bucket.pressureRatio,
      referenceIds: bucket.itemIds,
    );
  }
}

Iterable<IncomingTalentOperatingEscalationItem> _ownerReliefEscalations(
  IncomingTalentOperatingInboxOwnerRebalancePlan plan,
) sync* {
  for (final recommendation in plan.recommendations) {
    yield IncomingTalentOperatingEscalationItem(
      source: IncomingTalentOperatingEscalationSource.ownerRebalance,
      severity:
          recommendation.priority ==
                  IncomingTalentOperatingInboxOwnerRebalancePriority.critical
              ? IncomingTalentOperatingEscalationSeverity.critical
              : IncomingTalentOperatingEscalationSeverity.high,
      title: 'Relieve ${recommendation.sourceOwnerName}',
      detail:
          recommendation.targetOwnerName == null
              ? 'Needs relief capacity for '
                  '${recommendation.sourceItemCount} active '
                  '${_plural(recommendation.sourceItemCount, 'item')}'
              : 'Move ${recommendation.suggestedItemCount} '
                  '${_plural(recommendation.suggestedItemCount, 'item')} to '
                  '${recommendation.targetOwnerName}',
      nextAction: recommendation.nextAction,
      signalCount: _positiveSignalCount(
        recommendation.sourceCriticalCount +
            recommendation.sourceOverdueCount +
            recommendation.sourceDueSoonCount +
            recommendation.suggestedItemCount,
      ),
      dueDate: null,
      overdue: false,
      dueToday: false,
      ownerName: recommendation.sourceOwnerName,
      workstreamLabel: null,
      pressureRatio: recommendation.pressureRatio,
      referenceIds: const [],
    );
  }
}

Iterable<IncomingTalentOperatingEscalationItem> _workstreamEscalations(
  List<IncomingTalentOperatingWorkstreamPressure> pressures,
  DateTime asOfDate,
) sync* {
  for (final pressure in pressures) {
    if (pressure.totalCount == 0 || !pressure.needsAttention) continue;

    yield IncomingTalentOperatingEscalationItem(
      source: IncomingTalentOperatingEscalationSource.workstreamPressure,
      severity:
          pressure.level ==
                  IncomingTalentOperatingWorkstreamPressureLevel.critical
              ? IncomingTalentOperatingEscalationSeverity.critical
              : IncomingTalentOperatingEscalationSeverity.high,
      title: '${pressure.workstream.label} pressure',
      detail:
          '${pressure.totalCount} active '
          '${_plural(pressure.totalCount, 'item')} across '
          '${pressure.ownerCount} ${_plural(pressure.ownerCount, 'owner')}',
      nextAction: pressure.nextAction,
      signalCount: _positiveSignalCount(
        pressure.criticalCount +
            pressure.overdueCount +
            pressure.dueSoonCount +
            pressure.overloadedOwnerCount,
      ),
      dueDate: pressure.earliestDueDate,
      overdue: pressure.overdueCount > 0,
      dueToday: _isSameDay(pressure.earliestDueDate, asOfDate),
      ownerName: null,
      workstreamLabel: pressure.workstream.label,
      pressureRatio: pressure.pressureRatio,
      referenceIds: pressure.itemIds,
    );
  }
}

Iterable<IncomingTalentOperatingEscalationItem> _inboxEscalations(
  List<IncomingTalentOperatingInboxItem> items,
  DateTime asOfDate,
) sync* {
  final urgentItems =
      items.where((item) {
          if (item.priority != IncomingTalentOperatingInboxPriority.critical) {
            return false;
          }
          return item.daysUntilDue(asOfDate) <= 7;
        }).toList()
        ..sort(_compareInboxItems);

  for (final item in urgentItems) {
    yield IncomingTalentOperatingEscalationItem(
      source: IncomingTalentOperatingEscalationSource.inbox,
      severity:
          item.isOverdue(asOfDate) || item.daysUntilDue(asOfDate) == 0
              ? IncomingTalentOperatingEscalationSeverity.critical
              : IncomingTalentOperatingEscalationSeverity.high,
      title: item.title,
      detail:
          '${item.subjectName} - ${item.source.label} - ${item.statusLabel}',
      nextAction: item.nextAction,
      signalCount: item.isOverdue(asOfDate) ? 3 : 2,
      dueDate: item.dueDate,
      overdue: item.isOverdue(asOfDate),
      dueToday: item.daysUntilDue(asOfDate) == 0,
      ownerName: item.ownerName,
      workstreamLabel: _workstreamLabelFor(item.source),
      pressureRatio: _inboxPressureRatio(item, asOfDate),
      referenceIds: [item.id],
    );
  }
}

IncomingTalentOperatingEscalationSeverity _severityForCadence(
  IncomingTalentOperatingCadenceBucket bucket,
) {
  if (bucket.risk == IncomingTalentOperatingCadenceRisk.critical ||
      bucket.overdueCount > 0) {
    return IncomingTalentOperatingEscalationSeverity.critical;
  }
  if (bucket.dueTodayCount > 0 || bucket.criticalCount > 0) {
    return IncomingTalentOperatingEscalationSeverity.high;
  }
  return IncomingTalentOperatingEscalationSeverity.watch;
}

String _workstreamLabelFor(IncomingTalentOperatingInboxSource source) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp => 'Risk council',
    IncomingTalentOperatingInboxSource.trainingSession ||
    IncomingTalentOperatingInboxSource.careerPathReview => 'Development',
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      'Succession',
    IncomingTalentOperatingInboxSource.promotionStabilization => 'Promotion',
  };
}

double _inboxPressureRatio(
  IncomingTalentOperatingInboxItem item,
  DateTime asOfDate,
) {
  if (item.isOverdue(asOfDate)) return 1;
  final daysUntilDue = item.daysUntilDue(asOfDate);
  if (daysUntilDue == 0) return 0.9;
  if (daysUntilDue <= 3) return 0.8;
  return 0.65;
}

int _positiveSignalCount(int count) {
  return count <= 0 ? 1 : count;
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

int _compareInboxItems(
  IncomingTalentOperatingInboxItem left,
  IncomingTalentOperatingInboxItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final due = left.dueDate.compareTo(right.dueDate);
  if (due != 0) return due;

  return left.title.compareTo(right.title);
}

int _compareEscalations(
  IncomingTalentOperatingEscalationItem left,
  IncomingTalentOperatingEscalationItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = _boolRank(right.overdue).compareTo(_boolRank(left.overdue));
  if (overdue != 0) return overdue;

  final dueToday = _boolRank(
    right.dueToday,
  ).compareTo(_boolRank(left.dueToday));
  if (dueToday != 0) return dueToday;

  final dueDate = _compareNullableDueDate(left.dueDate, right.dueDate);
  if (dueDate != 0) return dueDate;

  final signalCount = right.signalCount.compareTo(left.signalCount);
  if (signalCount != 0) return signalCount;

  final pressure = right.normalizedPressureRatio.compareTo(
    left.normalizedPressureRatio,
  );
  if (pressure != 0) return pressure;

  return left.title.compareTo(right.title);
}

int _boolRank(bool value) => value ? 1 : 0;

int _compareNullableDueDate(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
