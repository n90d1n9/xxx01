import 'holiday_models.dart';

enum HolidayWorkforceImpactLevel {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const HolidayWorkforceImpactLevel(this.label);
}

class HolidayWorkforceImpactItem {
  final HolidayRecord holiday;
  final int daysUntil;
  final int estimatedEmployees;
  final int coverageRoles;
  final HolidayWorkforceImpactLevel level;
  final String signal;
  final String action;

  const HolidayWorkforceImpactItem({
    required this.holiday,
    required this.daysUntil,
    required this.estimatedEmployees,
    required this.coverageRoles,
    required this.level,
    required this.signal,
    required this.action,
  });
}

class HolidayWorkforceScopeImpact {
  final String scope;
  final List<HolidayWorkforceImpactItem> items;
  final int estimatedEmployees;
  final int coverageRoles;
  final int customCount;
  final HolidayRecord? nextHoliday;
  final HolidayWorkforceImpactLevel level;
  final int daysUntilNext;

  const HolidayWorkforceScopeImpact({
    required this.scope,
    required this.items,
    required this.estimatedEmployees,
    required this.coverageRoles,
    required this.customCount,
    required this.nextHoliday,
    required this.level,
    required this.daysUntilNext,
  });

  factory HolidayWorkforceScopeImpact.fromItems({
    required String scope,
    required List<HolidayWorkforceImpactItem> items,
  }) {
    final sortedItems = [...items]..sort(_compareImpactItems);

    return HolidayWorkforceScopeImpact(
      scope: scope,
      items: sortedItems,
      estimatedEmployees: _highestEstimatedEmployees(sortedItems),
      coverageRoles: sortedItems.fold(
        0,
        (total, item) => total + item.coverageRoles,
      ),
      customCount:
          sortedItems
              .where((item) => item.holiday.type == HolidayType.custom)
              .length,
      nextHoliday: sortedItems.isEmpty ? null : sortedItems.first.holiday,
      level: _highestImpactLevel(sortedItems),
      daysUntilNext: sortedItems.isEmpty ? 0 : sortedItems.first.daysUntil,
    );
  }
}

class HolidayWorkforceImpact {
  final List<HolidayWorkforceScopeImpact> scopes;
  final int horizonDays;

  const HolidayWorkforceImpact({
    required this.scopes,
    required this.horizonDays,
  });

  factory HolidayWorkforceImpact.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
    int horizonDays = 90,
  }) {
    final upcoming =
        holidays
            .where((holiday) => holiday.isUpcomingWithin(asOfDate, horizonDays))
            .toList()
          ..sort(_compareByEffectiveDate);

    final groupedItems = <String, List<HolidayWorkforceImpactItem>>{};
    for (final holiday in upcoming) {
      final scope = _normalizedScope(holiday.scope);
      final estimatedEmployees = _estimateEmployees(scope);
      final coverageRoles = _estimateCoverageRoles(
        holiday: holiday,
        estimatedEmployees: estimatedEmployees,
      );

      groupedItems
          .putIfAbsent(scope, () => [])
          .add(
            HolidayWorkforceImpactItem(
              holiday: holiday,
              daysUntil: holiday.daysUntil(asOfDate),
              estimatedEmployees: estimatedEmployees,
              coverageRoles: coverageRoles,
              level: _impactLevel(holiday, holiday.daysUntil(asOfDate)),
              signal: _impactSignal(holiday),
              action: _impactAction(holiday, scope),
            ),
          );
    }

    final scopes =
        groupedItems.entries.map((entry) {
            return HolidayWorkforceScopeImpact.fromItems(
              scope: entry.key,
              items: entry.value,
            );
          }).toList()
          ..sort(_compareScopeImpact);

    return HolidayWorkforceImpact(scopes: scopes, horizonDays: horizonDays);
  }

  int get totalHolidayCount {
    return scopes.fold(0, (total, scope) => total + scope.items.length);
  }

  int get totalEstimatedEmployees {
    return scopes.fold(0, (total, scope) => total + scope.estimatedEmployees);
  }

  int get totalCoverageRoles {
    return scopes.fold(0, (total, scope) => total + scope.coverageRoles);
  }

  int get highImpactCount {
    return scopes.fold(
      0,
      (total, scope) =>
          total +
          scope.items
              .where((item) => item.level == HolidayWorkforceImpactLevel.high)
              .length,
    );
  }

  int get customScopeCount {
    return scopes.where((scope) => scope.customCount > 0).length;
  }

  HolidayWorkforceScopeImpact? get nextScope {
    if (scopes.isEmpty) return null;
    return scopes.first;
  }
}

int _highestEstimatedEmployees(List<HolidayWorkforceImpactItem> items) {
  if (items.isEmpty) return 0;

  return items
      .map((item) => item.estimatedEmployees)
      .reduce((current, next) => next > current ? next : current);
}

HolidayWorkforceImpactLevel _highestImpactLevel(
  List<HolidayWorkforceImpactItem> items,
) {
  if (items.isEmpty) return HolidayWorkforceImpactLevel.low;

  return items.map((item) => item.level).reduce((current, next) {
    if (_levelRank(next) < _levelRank(current)) return next;
    return current;
  });
}

int _estimateEmployees(String scope) {
  final normalized = scope.toLowerCase();
  if (normalized.contains('all employees')) return 128;
  if (normalized.contains('all offices')) return 96;
  if (normalized.contains('people operations') ||
      normalized.contains('people ops')) {
    return 18;
  }
  if (normalized.contains('fulfillment')) return 42;
  return 24;
}

int _estimateCoverageRoles({
  required HolidayRecord holiday,
  required int estimatedEmployees,
}) {
  if (!holiday.requiresCoveragePlan) return 0;

  return (estimatedEmployees / 18).ceil().clamp(2, 12).toInt();
}

HolidayWorkforceImpactLevel _impactLevel(HolidayRecord holiday, int daysUntil) {
  if (!holiday.isPaid) return HolidayWorkforceImpactLevel.high;
  if (holiday.requiresCoveragePlan && daysUntil <= 21) {
    return HolidayWorkforceImpactLevel.high;
  }
  if (holiday.requiresCoveragePlan ||
      holiday.type == HolidayType.custom ||
      holiday.isObservedShifted) {
    return HolidayWorkforceImpactLevel.medium;
  }

  return HolidayWorkforceImpactLevel.low;
}

String _impactSignal(HolidayRecord holiday) {
  if (holiday.requiresCoveragePlan) return 'Coverage owners needed';
  if (!holiday.isPaid) return 'Payroll-sensitive group';
  if (holiday.type == HolidayType.custom) return 'Eligibility confirmation';
  if (holiday.isObservedShifted) return 'Observed date alignment';
  if (holiday.type == HolidayType.anniversary) return 'Engagement moment';
  return 'Published calendar';
}

String _impactAction(HolidayRecord holiday, String scope) {
  if (holiday.requiresCoveragePlan) {
    return 'Assign coverage owners for $scope.';
  }
  if (!holiday.isPaid) return 'Confirm unpaid handling with payroll.';
  if (holiday.type == HolidayType.custom) {
    return 'Confirm custom holiday scope and approvers.';
  }
  if (holiday.isObservedShifted) {
    return 'Confirm observed date in payroll and attendance.';
  }
  if (holiday.type == HolidayType.anniversary) {
    return 'Prepare manager notes for $scope.';
  }
  return 'Keep employee calendar visible.';
}

String _normalizedScope(String scope) {
  final trimmed = scope.trim();
  if (trimmed.isEmpty) return 'Unscoped';
  return trimmed;
}

int _compareScopeImpact(
  HolidayWorkforceScopeImpact a,
  HolidayWorkforceScopeImpact b,
) {
  final levelCompared = _levelRank(a.level).compareTo(_levelRank(b.level));
  if (levelCompared != 0) return levelCompared;

  final daysCompared = a.daysUntilNext.compareTo(b.daysUntilNext);
  if (daysCompared != 0) return daysCompared;

  return a.scope.compareTo(b.scope);
}

int _compareImpactItems(
  HolidayWorkforceImpactItem a,
  HolidayWorkforceImpactItem b,
) {
  final levelCompared = _levelRank(a.level).compareTo(_levelRank(b.level));
  if (levelCompared != 0) return levelCompared;

  final daysCompared = a.daysUntil.compareTo(b.daysUntil);
  if (daysCompared != 0) return daysCompared;

  return a.holiday.name.compareTo(b.holiday.name);
}

int _compareByEffectiveDate(HolidayRecord a, HolidayRecord b) {
  final compared = a.effectiveDate.compareTo(b.effectiveDate);
  if (compared != 0) return compared;

  return a.name.compareTo(b.name);
}

int _levelRank(HolidayWorkforceImpactLevel level) {
  return switch (level) {
    HolidayWorkforceImpactLevel.high => 0,
    HolidayWorkforceImpactLevel.medium => 1,
    HolidayWorkforceImpactLevel.low => 2,
  };
}
