import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:queue_ui/gantt/widgets/indicator/month_indicator.dart';
import 'package:queue_ui/gantt/widgets/indicator/today_indicator.dart';

import '../../states/task_state.dart';
import '../../utils/helper.dart';
import '../indicator/day_indicator.dart';
import '../indicator/vertical_day_line.dart';

class TimelineHeader extends StatelessWidget {
  final DateTimeRange dateRange;
  final double colWidth;
  final ViewMode viewMode;
  final double height;
  const TimelineHeader({
    super.key,
    required this.dateRange,
    required this.colWidth,
    required this.viewMode,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final days = dateRange.end.difference(dateRange.start).inDays;
    final dateFormat = DateFormat('MMM d');
    final weekdayFormat = DateFormat('E');

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: days * colWidth,
            child: Stack(
              children: [
                // Month indicators
                MonthIndicator(
                  dateRange: dateRange,
                  colWidth: colWidth,
                  days: days,
                  viewMode: viewMode,
                  dateFormat: dateFormat,
                ),

                // Day indicators
                DayIndicator(
                  days: days,
                  colWidth: colWidth,
                  dateRange: dateRange,
                  weekdayFormat: weekdayFormat,
                ),

                // Vertical day lines
                for (int i = 0; i < days; i++)
                  VerticalDayLine(
                    dateRange: dateRange,
                    colWidth: colWidth,
                    days: days,
                    i: i,
                  ),

                // Today indicator
                if (isDateInRange(DateTime.now(), dateRange))
                  TodayIndicator(dateRange: dateRange, colWidth: colWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
