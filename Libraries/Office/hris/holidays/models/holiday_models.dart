enum HolidayType {
  national('National'),
  fixed('Fixed'),
  anniversary('Anniversary'),
  custom('Custom');

  final String label;

  const HolidayType(this.label);
}

class HolidayRecord {
  final String id;
  final String name;
  final HolidayType type;
  final DateTime date;
  final DateTime? observedDate;
  final String scope;
  final String description;
  final bool isPaid;
  final bool isRecurring;
  final bool requiresCoveragePlan;

  const HolidayRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    this.observedDate,
    required this.scope,
    this.description = '',
    this.isPaid = true,
    this.isRecurring = true,
    this.requiresCoveragePlan = false,
  });

  DateTime get effectiveDate => observedDate ?? date;

  bool get isObservedShifted {
    final observed = observedDate;
    if (observed == null) return false;

    return !_isSameDate(date, observed);
  }

  int daysUntil(DateTime asOfDate) {
    return _dateOnly(effectiveDate).difference(_dateOnly(asOfDate)).inDays;
  }

  bool isUpcoming(DateTime asOfDate) => daysUntil(asOfDate) >= 0;

  bool isUpcomingWithin(DateTime asOfDate, int days) {
    final remainingDays = daysUntil(asOfDate);
    return remainingDays >= 0 && remainingDays <= days;
  }

  HolidayRecord copyWith({
    String? id,
    String? name,
    HolidayType? type,
    DateTime? date,
    DateTime? observedDate,
    bool clearObservedDate = false,
    String? scope,
    String? description,
    bool? isPaid,
    bool? isRecurring,
    bool? requiresCoveragePlan,
  }) {
    return HolidayRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      observedDate:
          clearObservedDate ? null : observedDate ?? this.observedDate,
      scope: scope ?? this.scope,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      requiresCoveragePlan: requiresCoveragePlan ?? this.requiresCoveragePlan,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HolidayRecord &&
            other.id == id &&
            other.name == name &&
            other.type == type &&
            other.date == date &&
            other.observedDate == observedDate &&
            other.scope == scope &&
            other.description == description &&
            other.isPaid == isPaid &&
            other.isRecurring == isRecurring &&
            other.requiresCoveragePlan == requiresCoveragePlan;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      type,
      date,
      observedDate,
      scope,
      description,
      isPaid,
      isRecurring,
      requiresCoveragePlan,
    );
  }
}

class HolidaySummary {
  final int totalCount;
  final int nationalCount;
  final int fixedCount;
  final int anniversaryCount;
  final int customCount;
  final int paidCount;
  final int recurringCount;
  final int upcomingCount;
  final HolidayRecord? nextHoliday;

  const HolidaySummary({
    required this.totalCount,
    required this.nationalCount,
    required this.fixedCount,
    required this.anniversaryCount,
    required this.customCount,
    required this.paidCount,
    required this.recurringCount,
    required this.upcomingCount,
    this.nextHoliday,
  });

  factory HolidaySummary.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
  }) {
    final items = holidays.toList();
    final upcoming =
        items.where((item) => item.isUpcomingWithin(asOfDate, 60)).toList()
          ..sort(_compareByEffectiveDate);

    return HolidaySummary(
      totalCount: items.length,
      nationalCount: _countType(items, HolidayType.national),
      fixedCount: _countType(items, HolidayType.fixed),
      anniversaryCount: _countType(items, HolidayType.anniversary),
      customCount: _countType(items, HolidayType.custom),
      paidCount: items.where((item) => item.isPaid).length,
      recurringCount: items.where((item) => item.isRecurring).length,
      upcomingCount: upcoming.length,
      nextHoliday: upcoming.isEmpty ? null : upcoming.first,
    );
  }

  int countForType(HolidayType type) {
    return switch (type) {
      HolidayType.national => nationalCount,
      HolidayType.fixed => fixedCount,
      HolidayType.anniversary => anniversaryCount,
      HolidayType.custom => customCount,
    };
  }
}

class HolidayRiskSummary {
  final int upcomingWithinThirtyDays;
  final int coverageGaps;
  final int unpaidCustomDays;

  const HolidayRiskSummary({
    required this.upcomingWithinThirtyDays,
    required this.coverageGaps,
    required this.unpaidCustomDays,
  });

  factory HolidayRiskSummary.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
  }) {
    final upcoming =
        holidays.where((item) => item.isUpcomingWithin(asOfDate, 30)).toList();

    return HolidayRiskSummary(
      upcomingWithinThirtyDays: upcoming.length,
      coverageGaps: upcoming.where((item) => item.requiresCoveragePlan).length,
      unpaidCustomDays:
          upcoming
              .where((item) => item.type == HolidayType.custom && !item.isPaid)
              .length,
    );
  }

  int get totalRisks => coverageGaps + unpaidCustomDays;
}

int _countType(Iterable<HolidayRecord> holidays, HolidayType type) {
  return holidays.where((item) => item.type == type).length;
}

int _compareByEffectiveDate(HolidayRecord a, HolidayRecord b) {
  final compared = a.effectiveDate.compareTo(b.effectiveDate);
  if (compared != 0) return compared;

  return a.name.compareTo(b.name);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
