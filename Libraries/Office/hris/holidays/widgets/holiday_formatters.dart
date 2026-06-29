import '../models/holiday_models.dart';

String formatHolidayDate(DateTime value) {
  return '${_months[value.month - 1]} ${value.day}, ${value.year}';
}

String formatHolidayRecurrence(HolidayRecord holiday) {
  if (!holiday.isRecurring) return 'One-time';
  if (holiday.type == HolidayType.fixed) return 'Fixed yearly';
  if (holiday.type == HolidayType.anniversary) return 'Annual anniversary';
  return 'Recurring';
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
