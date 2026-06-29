import 'holiday_models.dart';

enum HolidayPolicyIssueSeverity {
  critical('Critical'),
  warning('Warning'),
  advisory('Advisory');

  final String label;

  const HolidayPolicyIssueSeverity(this.label);
}

class HolidayPolicyIssue {
  final String id;
  final String title;
  final String detail;
  final String action;
  final HolidayPolicyIssueSeverity severity;
  final List<HolidayRecord> affectedHolidays;

  const HolidayPolicyIssue({
    required this.id,
    required this.title,
    required this.detail,
    required this.action,
    required this.severity,
    required this.affectedHolidays,
  });
}

class HolidayPolicyReview {
  final List<HolidayPolicyIssue> issues;
  final int checkedRules;

  const HolidayPolicyReview({required this.issues, required this.checkedRules});

  factory HolidayPolicyReview.fromHolidays({
    required Iterable<HolidayRecord> holidays,
  }) {
    final items = holidays.toList();
    final issues = <HolidayPolicyIssue>[
      ..._duplicateEffectiveDateIssues(items),
      ..._missingScopeIssues(items),
      ..._observedBeforeOfficialIssues(items),
      ..._customCoverageDecisionIssues(items),
      ..._unpaidCustomDocumentationIssues(items),
      ..._nonRecurringStatutoryIssues(items),
      ..._observedShiftIssues(items),
    ]..sort(_compareIssues);

    return HolidayPolicyReview(issues: issues, checkedRules: 7);
  }

  int get criticalCount => _countSeverity(HolidayPolicyIssueSeverity.critical);

  int get warningCount => _countSeverity(HolidayPolicyIssueSeverity.warning);

  int get advisoryCount => _countSeverity(HolidayPolicyIssueSeverity.advisory);

  int get policyScore {
    final score =
        100 - (criticalCount * 28) - (warningCount * 14) - (advisoryCount * 6);

    return score.clamp(0, 100).toInt();
  }

  String get policyLabel {
    if (criticalCount > 0 || policyScore < 70) return 'At risk';
    if (issues.isNotEmpty) return 'Needs review';
    return 'Clear';
  }

  int _countSeverity(HolidayPolicyIssueSeverity severity) {
    return issues.where((issue) => issue.severity == severity).length;
  }
}

Iterable<HolidayPolicyIssue> _duplicateEffectiveDateIssues(
  List<HolidayRecord> holidays,
) {
  final byEffectiveDate = <String, List<HolidayRecord>>{};
  for (final holiday in holidays) {
    byEffectiveDate
        .putIfAbsent(_dateKey(holiday.effectiveDate), () => [])
        .add(holiday);
  }

  return byEffectiveDate.entries.where((entry) => entry.value.length > 1).map((
    entry,
  ) {
    final affected = _sortByName(entry.value);
    return HolidayPolicyIssue(
      id: 'duplicate-effective-${entry.key}',
      title: 'Duplicate observed date',
      detail: '${_names(affected)} share ${entry.key}.',
      action: 'Merge the rules or confirm they intentionally stack.',
      severity: HolidayPolicyIssueSeverity.critical,
      affectedHolidays: affected,
    );
  });
}

Iterable<HolidayPolicyIssue> _missingScopeIssues(List<HolidayRecord> holidays) {
  return holidays.where((holiday) => holiday.scope.trim().isEmpty).map((
    holiday,
  ) {
    return HolidayPolicyIssue(
      id: 'missing-scope-${holiday.id}',
      title: 'Missing eligibility scope',
      detail: '${holiday.name} does not define who receives the holiday.',
      action: 'Add a scope such as all employees, region, team, or location.',
      severity: HolidayPolicyIssueSeverity.critical,
      affectedHolidays: [holiday],
    );
  });
}

Iterable<HolidayPolicyIssue> _observedBeforeOfficialIssues(
  List<HolidayRecord> holidays,
) {
  return holidays
      .where((holiday) {
        final observedDate = holiday.observedDate;
        return observedDate != null &&
            _dateOnly(observedDate).isBefore(_dateOnly(holiday.date));
      })
      .map((holiday) {
        return HolidayPolicyIssue(
          id: 'observed-before-official-${holiday.id}',
          title: 'Observed date precedes official date',
          detail: '${holiday.name} is observed before its source date.',
          action: 'Confirm the observed date with HR policy before publishing.',
          severity: HolidayPolicyIssueSeverity.warning,
          affectedHolidays: [holiday],
        );
      });
}

Iterable<HolidayPolicyIssue> _customCoverageDecisionIssues(
  List<HolidayRecord> holidays,
) {
  return holidays
      .where((holiday) {
        return holiday.type == HolidayType.custom &&
            holiday.isPaid &&
            !holiday.isRecurring &&
            !holiday.requiresCoveragePlan;
      })
      .map((holiday) {
        return HolidayPolicyIssue(
          id: 'custom-coverage-decision-${holiday.id}',
          title: 'Custom day needs coverage decision',
          detail: '${holiday.name} is a one-time paid custom holiday.',
          action: 'Mark whether coverage planning is required for this event.',
          severity: HolidayPolicyIssueSeverity.warning,
          affectedHolidays: [holiday],
        );
      });
}

Iterable<HolidayPolicyIssue> _unpaidCustomDocumentationIssues(
  List<HolidayRecord> holidays,
) {
  return holidays
      .where((holiday) {
        return holiday.type == HolidayType.custom &&
            !holiday.isPaid &&
            holiday.description.trim().isEmpty;
      })
      .map((holiday) {
        return HolidayPolicyIssue(
          id: 'unpaid-custom-documentation-${holiday.id}',
          title: 'Unpaid custom day needs rationale',
          detail: '${holiday.name} is unpaid but has no policy note.',
          action:
              'Add a description so payroll and employees see the rationale.',
          severity: HolidayPolicyIssueSeverity.warning,
          affectedHolidays: [holiday],
        );
      });
}

Iterable<HolidayPolicyIssue> _nonRecurringStatutoryIssues(
  List<HolidayRecord> holidays,
) {
  return holidays
      .where((holiday) {
        return !holiday.isRecurring &&
            (holiday.type == HolidayType.national ||
                holiday.type == HolidayType.fixed ||
                holiday.type == HolidayType.anniversary);
      })
      .map((holiday) {
        return HolidayPolicyIssue(
          id: 'non-recurring-statutory-${holiday.id}',
          title: 'Recurring rule expected',
          detail:
              '${holiday.name} is ${holiday.type.label.toLowerCase()} but one-time.',
          action: 'Confirm whether this should repeat in future years.',
          severity: HolidayPolicyIssueSeverity.advisory,
          affectedHolidays: [holiday],
        );
      });
}

Iterable<HolidayPolicyIssue> _observedShiftIssues(
  List<HolidayRecord> holidays,
) {
  return holidays.where((holiday) => holiday.isObservedShifted).map((holiday) {
    return HolidayPolicyIssue(
      id: 'observed-shift-${holiday.id}',
      title: 'Observed date shifted',
      detail: '${holiday.name} differs from its official date.',
      action: 'Publish the observed date in the employee calendar.',
      severity: HolidayPolicyIssueSeverity.advisory,
      affectedHolidays: [holiday],
    );
  });
}

int _compareIssues(HolidayPolicyIssue a, HolidayPolicyIssue b) {
  final severityCompared = _severityRank(
    a.severity,
  ).compareTo(_severityRank(b.severity));
  if (severityCompared != 0) return severityCompared;

  return a.title.compareTo(b.title);
}

int _severityRank(HolidayPolicyIssueSeverity severity) {
  return switch (severity) {
    HolidayPolicyIssueSeverity.critical => 0,
    HolidayPolicyIssueSeverity.warning => 1,
    HolidayPolicyIssueSeverity.advisory => 2,
  };
}

List<HolidayRecord> _sortByName(Iterable<HolidayRecord> holidays) {
  return holidays.toList()..sort((a, b) => a.name.compareTo(b.name));
}

String _names(Iterable<HolidayRecord> holidays) {
  return holidays.map((holiday) => holiday.name).join(', ');
}

String _dateKey(DateTime value) {
  final normalized = _dateOnly(value);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
