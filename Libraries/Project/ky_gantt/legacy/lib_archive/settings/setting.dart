import '../gantt/week_day.dart';

class TimelineSettings {
  /// a set of [WeekDay]s which are considered holidays that occur every week
  ///
  /// by default are [WeekDay.friday], [WeekDay.saturday]
  final Set<WeekDay> weekEnds;

  /// First workday of the week, by default [WeekDay.sunday]
  final WeekDay startOfTheWeek;

  /// Day column width (in pixels)
  final double dayWidth;

  /// Event row height (in pixels)
  final double eventHeight;

  /// Week header row height (in pixels)
  final double weekHeaderHeight;

  /// Day header row height (in pixels)
  final double dayHeaderHeight;

  TimelineSettings(
      {required this.weekEnds,
      required this.startOfTheWeek,
      required this.dayWidth,
      required this.eventHeight,
      required this.weekHeaderHeight,
      required this.dayHeaderHeight});
}


/* 

  TimelineSettings({
    this.dayWidth = 30,
    this.eventHeight = 30,
    this.weekHeaderHeight = 30,
    this.dayHeaderHeight = 40,
    this.weekEnds = const {WeekDay.friday, WeekDay.saturday},
    this.startOfTheWeek = WeekDay.sunday,
  });
   */
