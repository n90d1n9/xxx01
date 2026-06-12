class TableItem {
  final String id;
  final String category;
  final String name;
  final double value;
  final DateTime date;
  final bool active;
  final String status;
  final int priority;

  TableItem({
    required this.id,
    required this.category,
    required this.name,
    required this.value,
    required this.date,
    required this.active,
    required this.status,
    required this.priority,
  });

  TableItem copyWith({
    String? id,
    String? category,
    String? name,
    double? value,
    DateTime? date,
    bool? active,
    String? status,
    int? priority,
  }) {
    return TableItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      value: value ?? this.value,
      date: date ?? this.date,
      active: active ?? this.active,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}
