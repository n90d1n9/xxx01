import '../models/holiday_models.dart';

List<HolidayRecord> buildInitialHolidayRecords(DateTime asOfDate) {
  final year = asOfDate.year;

  return [
    HolidayRecord(
      id: 'national-labor-day',
      name: 'National Labor Day',
      type: HolidayType.national,
      date: DateTime(year, 5, 1),
      scope: 'All employees',
      description: 'Published national holiday calendar',
      isPaid: true,
      isRecurring: true,
      requiresCoveragePlan: true,
    ),
    HolidayRecord(
      id: 'fixed-new-year',
      name: 'New Year Closure',
      type: HolidayType.fixed,
      date: DateTime(year, 1, 1),
      scope: 'All offices',
      description: 'Fixed annual office closure',
      isPaid: true,
      isRecurring: true,
    ),
    HolidayRecord(
      id: 'company-anniversary',
      name: 'Company Anniversary',
      type: HolidayType.anniversary,
      date: DateTime(year, 8, 12),
      scope: 'All employees',
      description: 'Annual recognition day for company founding',
      isPaid: true,
      isRecurring: true,
    ),
    HolidayRecord(
      id: 'custom-wellness-day',
      name: 'Quarterly Wellness Day',
      type: HolidayType.custom,
      date: DateTime(year, 6, 12),
      observedDate: DateTime(year, 6, 13),
      scope: 'People Operations',
      description: 'Custom recovery day coordinated with People Ops',
      isPaid: true,
      isRecurring: false,
      requiresCoveragePlan: true,
    ),
  ];
}
