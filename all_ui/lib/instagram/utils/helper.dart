import 'package:flutter/material.dart';

import '../models/event_collection.dart';

Color getStatusColor(EventStatus status) {
  switch (status) {
    case EventStatus.upcoming:
      return Colors.orange;
    case EventStatus.ongoing:
      return Colors.green;
    case EventStatus.completed:
      return Colors.blue;
  }
}

String formatDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
