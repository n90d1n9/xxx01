import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayIndicator extends StatelessWidget {
  final int days;
  final double colWidth;
  final DateTimeRange dateRange;
  final DateFormat weekdayFormat;
  const DayIndicator({
    super.key,
    required this.days,
    required this.colWidth,
    required this.dateRange,
    required this.weekdayFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      height: 30,
      child: Row(
        children: [
          for (int i = 0; i < days; i++)
            Tooltip(
              message:
                  '${weekdayFormat.format(dateRange.start.add(Duration(days: i)))} \n ${dateRange.start.add(Duration(days: i))}',
              child: SizedBox(
                width: colWidth,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        weekdayFormat.format(
                          dateRange.start.add(Duration(days: i)),
                        ),
                      ),
                      // Text('$i'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
