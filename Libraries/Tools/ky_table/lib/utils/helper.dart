import 'dart:math';

import 'package:flutter/material.dart';

import '../model/tabel_item.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Pending':
      return Colors.orange;
    case 'Approved':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    case 'On Hold':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

List<TableItem> dummy() {
  final Random random = Random();
  final categories = ['Hardware', 'Software', 'Services', 'Infrastructure'];
  final statuses = ['Pending', 'Approved', 'Rejected', 'On Hold'];
  return List.generate(100, (index) {
    final categoryIndex = random.nextInt(categories.length);
    return TableItem(
      id: 'ID-${1000 + index}',
      category: categories[categoryIndex],
      name: 'Item ${index + 1}',
      value: double.parse((random.nextDouble() * 1000).toStringAsFixed(2)),
      date: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      active: random.nextBool(),
      status: statuses[random.nextInt(statuses.length)],
      priority: random.nextInt(5) + 1,
    );
  });
}
