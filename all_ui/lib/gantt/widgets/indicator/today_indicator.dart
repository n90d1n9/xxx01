import 'package:flutter/material.dart';

import '../../utils/helper.dart';

class TodayIndicator extends StatelessWidget {
  final DateTimeRange dateRange;
  final double colWidth;
  const TodayIndicator({
    super.key,
    required this.dateRange,
    required this.colWidth,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Positioned(
      top: 0,
      bottom: 0,
      left: getDayPosition(today, dateRange.start) * colWidth,
      child: Tooltip(
        message: '$today',
        child: Container(
          width: 4,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
