import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../states/task_state.dart';

class MonthIndicator extends StatelessWidget {
  final DateTimeRange dateRange;
  final double colWidth;
  final int days;
  final ViewMode viewMode;
  final DateFormat dateFormat;

  MonthIndicator({
    super.key,
    required this.dateRange,
    required this.colWidth,
    required this.days,
    required this.viewMode,
    DateFormat? dateFormat,
  }) : dateFormat = dateFormat ?? DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 30,
      child: Row(
        children: [
          for (int i = 0; i < days; i += viewMode == ViewMode.day ? 1 : 7)
            Flexible(
              child: SizedBox(
                width: viewMode == ViewMode.day ? colWidth : colWidth * 7,
                child: Center(
                  child: Text(
                    dateFormat.format(dateRange.start.add(Duration(days: i))),

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
