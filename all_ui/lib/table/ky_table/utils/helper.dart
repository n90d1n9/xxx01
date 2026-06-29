import 'dart:math';

import 'package:flutter/material.dart';

import '../model/ky_data.dart';
import '../model/tabel_item.dart';
import '../widgets/rating.dart';

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

List<KyRow> dummy() {
  final Random random = Random();
  final categories = ['Hardware', 'Software', 'Services', 'Infrastructure'];
  final statuses = ['Pending', 'Approved', 'Rejected', 'On Hold'];
  return List.generate(100, (index) {
    final categoryIndex = random.nextInt(categories.length);
    return KyRow(
      id: index,
      cells: [
        KyCell(value: 'ID-${1000 + index}'),
        KyCell(value: categories[categoryIndex]),
        KyCell(value: 'Item ${index + 1}'),
        KyCell(
          value: double.parse((random.nextDouble() * 1000).toStringAsFixed(2)),
        ),
        KyCell(
          value: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        ),

        KyCell(
          value: statuses[random.nextInt(statuses.length)],
          widget: status(statuses[random.nextInt(statuses.length)]),
        ),
        KyCell(
          value: random.nextInt(5) + 1,
          widget: Rating(rate: random.nextInt(5) + 1),
        ),
        KyCell(value: random.nextBool()),
      ],
    );
  });
}

Widget status(String status) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: getStatusColor(status),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(status, style: const TextStyle(color: Colors.white)),
);
