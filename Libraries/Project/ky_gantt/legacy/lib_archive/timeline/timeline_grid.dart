
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineGrid extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double cellWidth;
  final double headerHeight;

  const TimelineGrid({
    super.key,
    required this.startDate,
    required this.endDate,
    this.cellWidth = 50.0,
    this.headerHeight = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final daysBetween = endDate.difference(startDate).inDays;
    
    return Container(
      height: headerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysBetween + 1,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          return Container(
            width: cellWidth,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(date),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('E').format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}