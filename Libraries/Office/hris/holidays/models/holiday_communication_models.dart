import 'holiday_models.dart';

enum HolidayCommunicationPriority {
  urgent('Urgent'),
  review('Review'),
  scheduled('Scheduled');

  final String label;

  const HolidayCommunicationPriority(this.label);
}

class HolidayCommunicationBrief {
  final HolidayRecord holiday;
  final int daysUntil;
  final HolidayCommunicationPriority priority;
  final List<String> audiences;
  final String subject;
  final String employeeMessage;
  final String managerAction;
  final String payrollAction;

  const HolidayCommunicationBrief({
    required this.holiday,
    required this.daysUntil,
    required this.priority,
    required this.audiences,
    required this.subject,
    required this.employeeMessage,
    required this.managerAction,
    required this.payrollAction,
  });

  factory HolidayCommunicationBrief.fromHoliday({
    required HolidayRecord holiday,
    required DateTime asOfDate,
    required bool hasPolicyIssue,
  }) {
    final daysUntil = holiday.daysUntil(asOfDate);

    return HolidayCommunicationBrief(
      holiday: holiday,
      daysUntil: daysUntil,
      priority: _priorityFor(holiday, daysUntil, hasPolicyIssue),
      audiences: _audiencesFor(holiday, hasPolicyIssue),
      subject: _subjectFor(holiday),
      employeeMessage: _employeeMessageFor(holiday),
      managerAction: _managerActionFor(holiday),
      payrollAction: _payrollActionFor(holiday),
    );
  }
}

class HolidayCommunicationPlan {
  final List<HolidayCommunicationBrief> briefs;
  final int horizonDays;

  const HolidayCommunicationPlan({
    required this.briefs,
    required this.horizonDays,
  });

  factory HolidayCommunicationPlan.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
    required Set<String> policyIssueHolidayIds,
    int horizonDays = 45,
  }) {
    final briefs =
        holidays
            .where((holiday) => holiday.isUpcomingWithin(asOfDate, horizonDays))
            .where(
              (holiday) =>
                  _needsCommunicationBrief(holiday) ||
                  policyIssueHolidayIds.contains(holiday.id),
            )
            .map(
              (holiday) => HolidayCommunicationBrief.fromHoliday(
                holiday: holiday,
                asOfDate: asOfDate,
                hasPolicyIssue: policyIssueHolidayIds.contains(holiday.id),
              ),
            )
            .toList()
          ..sort(_compareBriefs);

    return HolidayCommunicationPlan(briefs: briefs, horizonDays: horizonDays);
  }

  int get urgentCount {
    return briefs
        .where((brief) => brief.priority == HolidayCommunicationPriority.urgent)
        .length;
  }

  int get reviewCount {
    return briefs
        .where((brief) => brief.priority == HolidayCommunicationPriority.review)
        .length;
  }

  int get scheduledCount {
    return briefs
        .where(
          (brief) => brief.priority == HolidayCommunicationPriority.scheduled,
        )
        .length;
  }

  int get audienceCount {
    return {
      for (final brief in briefs)
        for (final audience in brief.audiences) audience,
    }.length;
  }

  int get readinessScore {
    final score =
        100 - (urgentCount * 32) - (reviewCount * 18) - (scheduledCount * 4);

    return score.clamp(0, 100).toInt();
  }

  String get readinessLabel {
    if (urgentCount > 0 || readinessScore < 70) return 'Needs action';
    if (reviewCount > 0 || readinessScore < 92) return 'Needs review';
    return 'Ready';
  }
}

bool _needsCommunicationBrief(HolidayRecord holiday) {
  return holiday.requiresCoveragePlan ||
      holiday.type == HolidayType.custom ||
      holiday.isObservedShifted ||
      !holiday.isPaid;
}

HolidayCommunicationPriority _priorityFor(
  HolidayRecord holiday,
  int daysUntil,
  bool hasPolicyIssue,
) {
  if (daysUntil <= 7 || !holiday.isPaid) {
    return HolidayCommunicationPriority.urgent;
  }
  if (hasPolicyIssue ||
      holiday.requiresCoveragePlan ||
      holiday.isObservedShifted ||
      holiday.type == HolidayType.custom) {
    return HolidayCommunicationPriority.review;
  }
  return HolidayCommunicationPriority.scheduled;
}

List<String> _audiencesFor(HolidayRecord holiday, bool hasPolicyIssue) {
  final audiences = <String>['Employees'];

  if (holiday.requiresCoveragePlan) {
    audiences.addAll(['Managers', 'Operations']);
  }
  if (holiday.type == HolidayType.custom || hasPolicyIssue) {
    audiences.add('People Ops');
  }
  if (holiday.isObservedShifted) {
    audiences.add('HR Comms');
  }
  if (!holiday.isPaid) {
    audiences.add('Payroll');
  }

  return audiences;
}

String _subjectFor(HolidayRecord holiday) {
  return 'Holiday notice: ${holiday.name} on ${_formatDate(holiday.effectiveDate)}';
}

String _employeeMessageFor(HolidayRecord holiday) {
  final date = _formatDate(holiday.effectiveDate);
  final payStatus = holiday.isPaid ? 'paid holiday' : 'unpaid calendar day';
  final observed =
      holiday.isObservedShifted
          ? ' The observed date differs from ${_formatDate(holiday.date)}.'
          : '';

  return '${holiday.name} is scheduled for $date as a $payStatus for ${holiday.scope}.$observed';
}

String _managerActionFor(HolidayRecord holiday) {
  if (holiday.requiresCoveragePlan) {
    return 'Confirm staffing coverage before ${_formatDate(holiday.effectiveDate)}.';
  }
  if (holiday.type == HolidayType.custom) {
    return 'Confirm team attendance expectations before publishing.';
  }
  return 'Share the holiday notice with affected teams.';
}

String _payrollActionFor(HolidayRecord holiday) {
  if (!holiday.isPaid) {
    return 'Confirm unpaid treatment and employee acknowledgement.';
  }
  if (holiday.type == HolidayType.custom) {
    return 'Confirm paid custom holiday treatment for payroll.';
  }
  return 'No special payroll action required.';
}

int _compareBriefs(HolidayCommunicationBrief a, HolidayCommunicationBrief b) {
  final priorityCompared = _priorityRank(
    a.priority,
  ).compareTo(_priorityRank(b.priority));
  if (priorityCompared != 0) return priorityCompared;

  final daysCompared = a.daysUntil.compareTo(b.daysUntil);
  if (daysCompared != 0) return daysCompared;

  return a.holiday.name.compareTo(b.holiday.name);
}

int _priorityRank(HolidayCommunicationPriority priority) {
  return switch (priority) {
    HolidayCommunicationPriority.urgent => 0,
    HolidayCommunicationPriority.review => 1,
    HolidayCommunicationPriority.scheduled => 2,
  };
}

String _formatDate(DateTime value) {
  return '${_months[value.month - 1]} ${value.day}, ${value.year}';
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
