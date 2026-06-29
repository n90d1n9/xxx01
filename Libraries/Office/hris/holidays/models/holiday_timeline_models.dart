import 'holiday_models.dart';

class HolidayTimelineBucket {
  final int year;
  final int month;
  final List<HolidayRecord> holidays;
  final DateTime asOfDate;

  const HolidayTimelineBucket({
    required this.year,
    required this.month,
    required this.holidays,
    required this.asOfDate,
  });

  String get label => '${_months[month - 1]} $year';

  int get holidayCount => holidays.length;

  int get coverageCount {
    return holidays.where((holiday) => holiday.requiresCoveragePlan).length;
  }

  int get customCount {
    return holidays
        .where((holiday) => holiday.type == HolidayType.custom)
        .length;
  }

  int get observedShiftCount {
    return holidays.where((holiday) => holiday.isObservedShifted).length;
  }

  int get paidCount {
    return holidays.where((holiday) => holiday.isPaid).length;
  }

  int get daysUntilFirstHoliday {
    if (holidays.isEmpty) return 0;
    return holidays.first.daysUntil(asOfDate);
  }

  bool get hasPlanningPressure {
    return coverageCount > 0 || customCount > 0 || observedShiftCount > 0;
  }

  String get impactLabel {
    if (coverageCount > 0) return 'Coverage focus';
    if (customCount > 0) return 'Custom review';
    if (observedShiftCount > 0) return 'Observed shift';
    return 'Standard';
  }
}

class HolidayTimeline {
  final List<HolidayTimelineBucket> buckets;
  final int horizonDays;

  const HolidayTimeline({required this.buckets, required this.horizonDays});

  factory HolidayTimeline.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
    int horizonDays = 180,
  }) {
    final upcoming =
        holidays
            .where((holiday) => holiday.isUpcomingWithin(asOfDate, horizonDays))
            .toList()
          ..sort(_compareByEffectiveDate);

    final grouped = <String, List<HolidayRecord>>{};
    for (final holiday in upcoming) {
      final key = _monthKey(holiday.effectiveDate);
      grouped.putIfAbsent(key, () => []).add(holiday);
    }

    final buckets =
        grouped.entries.map((entry) {
            final dateParts = entry.key.split('-');
            return HolidayTimelineBucket(
              year: int.parse(dateParts.first),
              month: int.parse(dateParts.last),
              holidays: entry.value,
              asOfDate: asOfDate,
            );
          }).toList()
          ..sort((a, b) {
            final compared = a.year.compareTo(b.year);
            if (compared != 0) return compared;

            return a.month.compareTo(b.month);
          });

    return HolidayTimeline(buckets: buckets, horizonDays: horizonDays);
  }

  int get totalUpcomingCount {
    return buckets.fold(0, (total, bucket) => total + bucket.holidayCount);
  }

  int get coverageHolidayCount {
    return buckets.fold(0, (total, bucket) => total + bucket.coverageCount);
  }

  int get customHolidayCount {
    return buckets.fold(0, (total, bucket) => total + bucket.customCount);
  }

  int get observedShiftCount {
    return buckets.fold(
      0,
      (total, bucket) => total + bucket.observedShiftCount,
    );
  }

  HolidayTimelineBucket? get busiestBucket {
    if (buckets.isEmpty) return null;

    return buckets.reduce((current, next) {
      if (next.holidayCount > current.holidayCount) return next;
      return current;
    });
  }
}

int _compareByEffectiveDate(HolidayRecord a, HolidayRecord b) {
  final compared = a.effectiveDate.compareTo(b.effectiveDate);
  if (compared != 0) return compared;

  return a.name.compareTo(b.name);
}

String _monthKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
