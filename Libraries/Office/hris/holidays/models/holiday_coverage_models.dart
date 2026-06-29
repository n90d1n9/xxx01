import 'holiday_models.dart';

enum HolidayCoveragePriority {
  urgent('Urgent'),
  planning('Planning'),
  monitor('Monitor');

  final String label;

  const HolidayCoveragePriority(this.label);
}

class HolidayCoveragePlanItem {
  final HolidayRecord holiday;
  final int daysUntil;
  final HolidayCoveragePriority priority;
  final String signal;
  final String action;

  const HolidayCoveragePlanItem({
    required this.holiday,
    required this.daysUntil,
    required this.priority,
    required this.signal,
    required this.action,
  });

  factory HolidayCoveragePlanItem.fromHoliday({
    required HolidayRecord holiday,
    required DateTime asOfDate,
  }) {
    final daysUntil = holiday.daysUntil(asOfDate);

    return HolidayCoveragePlanItem(
      holiday: holiday,
      daysUntil: daysUntil,
      priority: _priorityFor(holiday, daysUntil),
      signal: _signalFor(holiday),
      action: _actionFor(holiday),
    );
  }
}

class HolidayCoveragePlan {
  final List<HolidayCoveragePlanItem> items;
  final int horizonDays;

  const HolidayCoveragePlan({required this.items, required this.horizonDays});

  factory HolidayCoveragePlan.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
    int horizonDays = 45,
  }) {
    final items =
        holidays
            .where((holiday) => holiday.isUpcomingWithin(asOfDate, horizonDays))
            .where(_needsCoverageReview)
            .map(
              (holiday) => HolidayCoveragePlanItem.fromHoliday(
                holiday: holiday,
                asOfDate: asOfDate,
              ),
            )
            .toList()
          ..sort(_compareCoverageItems);

    return HolidayCoveragePlan(items: items, horizonDays: horizonDays);
  }

  int get urgentCount {
    return items
        .where((item) => item.priority == HolidayCoveragePriority.urgent)
        .length;
  }

  int get coverageRequiredCount {
    return items.where((item) => item.holiday.requiresCoveragePlan).length;
  }

  int get customCount {
    return items
        .where((item) => item.holiday.type == HolidayType.custom)
        .length;
  }

  int get observedShiftCount {
    return items.where((item) => item.holiday.isObservedShifted).length;
  }

  int get unpaidCustomCount {
    return items
        .where(
          (item) =>
              item.holiday.type == HolidayType.custom && !item.holiday.isPaid,
        )
        .length;
  }

  int get readinessScore {
    final planningCount =
        items
            .where((item) => item.priority == HolidayCoveragePriority.planning)
            .length;
    final monitorCount =
        items
            .where((item) => item.priority == HolidayCoveragePriority.monitor)
            .length;
    final score =
        100 - (urgentCount * 30) - (planningCount * 16) - (monitorCount * 8);

    return score.clamp(0, 100).toInt();
  }

  String get readinessLabel {
    if (readinessScore >= 90) return 'Ready';
    if (readinessScore >= 70) return 'Needs review';
    return 'At risk';
  }
}

bool _needsCoverageReview(HolidayRecord holiday) {
  return holiday.requiresCoveragePlan ||
      holiday.type == HolidayType.custom ||
      holiday.isObservedShifted ||
      !holiday.isPaid;
}

HolidayCoveragePriority _priorityFor(HolidayRecord holiday, int daysUntil) {
  if (daysUntil <= 7 || (holiday.requiresCoveragePlan && daysUntil <= 14)) {
    return HolidayCoveragePriority.urgent;
  }
  if (daysUntil <= 30 || holiday.type == HolidayType.custom) {
    return HolidayCoveragePriority.planning;
  }
  return HolidayCoveragePriority.monitor;
}

String _signalFor(HolidayRecord holiday) {
  if (holiday.requiresCoveragePlan) return 'Coverage plan needed';
  if (holiday.type == HolidayType.custom && !holiday.isPaid) {
    return 'Custom unpaid day';
  }
  if (holiday.isObservedShifted) return 'Observed date shifted';
  if (holiday.type == HolidayType.custom) return 'Custom policy day';
  return 'Calendar review';
}

String _actionFor(HolidayRecord holiday) {
  if (holiday.requiresCoveragePlan) return 'Confirm coverage owners';
  if (holiday.type == HolidayType.custom && !holiday.isPaid) {
    return 'Review payroll impact';
  }
  if (holiday.isObservedShifted) return 'Communicate observed date';
  if (holiday.type == HolidayType.custom) return 'Confirm attendance policy';
  return 'Monitor readiness';
}

int _compareCoverageItems(
  HolidayCoveragePlanItem a,
  HolidayCoveragePlanItem b,
) {
  final priorityCompared = _priorityRank(
    a.priority,
  ).compareTo(_priorityRank(b.priority));
  if (priorityCompared != 0) return priorityCompared;

  final daysCompared = a.daysUntil.compareTo(b.daysUntil);
  if (daysCompared != 0) return daysCompared;

  return a.holiday.name.compareTo(b.holiday.name);
}

int _priorityRank(HolidayCoveragePriority priority) {
  return switch (priority) {
    HolidayCoveragePriority.urgent => 0,
    HolidayCoveragePriority.planning => 1,
    HolidayCoveragePriority.monitor => 2,
  };
}
