import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineHeader extends StatelessWidget {
  final DateTime date;
  final int days;
  const TimelineHeader({super.key, required this.date, required this.days});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(DateFormat('d').format(date)),
                Text(DateFormat('MMM').format(date)),
              ],
            ),
          );
        },
      ),
    );
  }
}
