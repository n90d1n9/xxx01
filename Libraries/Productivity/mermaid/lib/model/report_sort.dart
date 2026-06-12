class ReportSort {
  final String columnId;
  final bool ascending;
  final int priority; // For multi-column sort
  final String? customComparator;

  ReportSort({
    required this.columnId,
    this.ascending = true,
    this.priority = 0,
    this.customComparator,
  });

  Map<String, dynamic> toJson() => {
    'columnId': columnId,
    'ascending': ascending,
    'priority': priority,
  };

  factory ReportSort.fromJson(Map<String, dynamic> json) => ReportSort(
    columnId: json['columnId'],
    ascending: json['ascending'] ?? true,
    priority: json['priority'] ?? 0,
  );
}
