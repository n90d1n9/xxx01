import 'package:flutter/material.dart';
// import 'package:gantt_chart/src/dateweek_ext.dart';

class WeekHeader extends StatelessWidget {
  static const defaultColor = Colors.white;
  static final defaultBackgroundColor = Colors.blue.shade900;

  final Color? color;
  final Color? backgroundColor;
  final BoxBorder? border;
  final WidgetBuilder? widgetBuilder;

  const WeekHeader({
    super.key,
    required this.weekDate,
    this.color,
    this.backgroundColor,
    this.border,
    this.widgetBuilder,
  });
  final DateTime weekDate;

  int get weekNumberWithinThisYear => weekDate.weekOfYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 8, top: 1, bottom: 1),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        border: border ?? _defaultBorder,
      ),
      child: widgetBuilder?.call(context) ?? _defaultChild(context),
    );
  }

  BoxBorder get _defaultBorder => const BorderDirectional(
        start: BorderSide(),
        bottom: BorderSide(),
      );

  Widget _defaultChild(BuildContext context) => Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            String txt;
            if (constraints.maxWidth < 50) {
              txt = weekDate.month.toString();
            } else if (constraints.maxWidth < 7 * 20) {
              txt = '${weekDate.month}-${weekDate.year % 100}';
            } else {
              txt =
                  '${weekDate.day}-${weekDate.month}-${weekDate.year}  #$weekNumberWithinThisYear';
            }

            return Text(
              txt,
              style: TextStyle(color: color ?? defaultColor),
            );
          },
        ),
      );
}

extension on DateTime {
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
