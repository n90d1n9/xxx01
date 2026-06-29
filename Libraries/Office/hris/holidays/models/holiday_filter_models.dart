import 'holiday_models.dart';

enum HolidayCalendarQuickView {
  all('All'),
  upcoming('Upcoming'),
  coverage('Coverage'),
  policyIssues('Policy issues'),
  unpaidCustom('Unpaid custom');

  final String label;

  const HolidayCalendarQuickView(this.label);
}

class HolidayCalendarViewCounts {
  final int allCount;
  final int upcomingCount;
  final int coverageCount;
  final int policyIssueCount;
  final int unpaidCustomCount;

  const HolidayCalendarViewCounts({
    required this.allCount,
    required this.upcomingCount,
    required this.coverageCount,
    required this.policyIssueCount,
    required this.unpaidCustomCount,
  });

  factory HolidayCalendarViewCounts.fromHolidays({
    required Iterable<HolidayRecord> holidays,
    required DateTime asOfDate,
    required Set<String> policyIssueHolidayIds,
  }) {
    final items = holidays.toList();

    return HolidayCalendarViewCounts(
      allCount: items.length,
      upcomingCount:
          items
              .where((holiday) => holiday.isUpcomingWithin(asOfDate, 60))
              .length,
      coverageCount:
          items.where((holiday) => holiday.requiresCoveragePlan).length,
      policyIssueCount:
          items
              .where((holiday) => policyIssueHolidayIds.contains(holiday.id))
              .length,
      unpaidCustomCount:
          items
              .where(
                (holiday) =>
                    holiday.type == HolidayType.custom && !holiday.isPaid,
              )
              .length,
    );
  }

  int countFor(HolidayCalendarQuickView view) {
    return switch (view) {
      HolidayCalendarQuickView.all => allCount,
      HolidayCalendarQuickView.upcoming => upcomingCount,
      HolidayCalendarQuickView.coverage => coverageCount,
      HolidayCalendarQuickView.policyIssues => policyIssueCount,
      HolidayCalendarQuickView.unpaidCustom => unpaidCustomCount,
    };
  }
}
