import 'package:flutter/material.dart';

double getDayPosition(DateTime date, DateTime startDate) {
  return date.difference(startDate).inDays.toDouble();
}

bool isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

bool isDateInRange(DateTime date, DateTimeRange range) {
  return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
      date.isBefore(range.end.add(const Duration(days: 1)));
}

RenderBox getRenderBox(GlobalKey key) {
  if (key.currentContext == null) {
    throw Exception('RenderBox not found');
  }
  final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
  return renderBox;
}

Offset getPosition(GlobalKey key) {
  print(' ${key.currentWidget} getPosition: ${key.currentContext}');

  if (key.currentContext == null) {
    return Offset.zero;
  }
  final RenderBox renderBox = getRenderBox(key);
  final position = renderBox.localToGlobal(Offset.zero);
  return position;
}
