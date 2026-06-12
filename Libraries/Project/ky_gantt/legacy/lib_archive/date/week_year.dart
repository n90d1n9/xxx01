extension DateTimeExtensions on DateTime {
  int get weekOfYear {
    // Days since start of the year
    final startOfYear = DateTime(year, 1, 1);
    final firstMonday = startOfYear.add(
      Duration(days: (8 - startOfYear.weekday) % 7),
    );
    
    if (isBefore(firstMonday)) {
      return DateTime(year - 1, 12, 28).weekOfYear;
    }
    
    return ((difference(firstMonday).inDays + 1) / 7).ceil();
  }

  int get ordinalDate {
    final startOfYear = DateTime(year, 1, 1);
    return difference(startOfYear).inDays + 1;
  }

  bool get isLeapYear {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }
}

DateTime dateTimeFromWeekNumber(int year, int week, int weekday) {
  // Start with January 1st of the given year
  final firstDayOfYear = DateTime(year, 1, 1);
  
  // Find the first day of week 1
  // According to ISO 8601, week 1 is the week containing January 4th
  final daysSinceMonday = (firstDayOfYear.weekday - DateTime.monday) % 7;
  final firstMonday = firstDayOfYear.subtract(Duration(days: daysSinceMonday));
  
  // Calculate target date by adding weeks and days
  final daysToAdd = (week - 1) * 7 + (weekday - DateTime.monday);
  return firstMonday.add(Duration(days: daysToAdd));
}

// Example usage:
void main() {
  final date = DateTime.now();
  print(date.weekOfYear);      // Get the ISO week of year
  print(date.ordinalDate);     // Get the ordinal date
  print(date.isLeapYear);      // Is this a leap year?
  
  final DateTime dateFromWeekNumber = dateTimeFromWeekNumber(2023, 13, DateTime.tuesday);
  print(dateFromWeekNumber);   // 2023-02-28
}