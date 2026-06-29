import 'package:flutter/material.dart';

import '../../utils/helper.dart';

class VerticalDayLine extends StatelessWidget {
  final DateTimeRange dateRange;
  final double colWidth;
  final int days;
  final int i;
  const VerticalDayLine({
    super.key,
    required this.dateRange,
    required this.colWidth,
    required this.days,
    required this.i,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: i * colWidth,
      child: Container(
        width: 2,
        color:
            isWeekend(dateRange.start.add(Duration(days: i)))
                ? Colors.red.withValues(alpha: 0.5)
                : i % 7 == 0
                ? Theme.of(context).dividerColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.5),
      ),
    );
  }
}
