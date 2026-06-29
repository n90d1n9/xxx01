import 'dart:math';

import 'ky_table/model/tabel_item.dart';

final Random random = Random();
final categories = ['Hardware', 'Software', 'Services', 'Infrastructure'];
final statuses = ['Pending', 'Approved', 'Rejected', 'On Hold'];
final dummy = List.generate(100, (index) {
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
