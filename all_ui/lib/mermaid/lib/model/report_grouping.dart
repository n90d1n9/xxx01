class ReportGrouping {
  final String columnId;
  final bool showSubtotals;
  final bool expandByDefault;

  final int level; // For nested grouping
  final String? customGrouper;

  ReportGrouping({
    required this.columnId,
    this.showSubtotals = true,
    this.expandByDefault = true,

    this.level = 0,
    this.customGrouper,
  });

  Map<String, dynamic> toJson() => {
    'columnId': columnId,
    'showSubtotals': showSubtotals,
    'expandByDefault': expandByDefault,
  };

  factory ReportGrouping.fromJson(Map<String, dynamic> json) => ReportGrouping(
    columnId: json['columnId'],
    showSubtotals: json['showSubtotals'] ?? true,
    expandByDefault: json['expandByDefault'] ?? true,
  );
}
