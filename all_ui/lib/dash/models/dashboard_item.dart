enum DashboardItemType { lineChart, barChart, pieChart, statCard }

class DashboardItem {
  final String id;
  final String title;
  final DashboardItemType type;
  final Map<String, dynamic> data;
  final int gridWidth;
  final int gridHeight;

  DashboardItem({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
    this.gridWidth = 1,
    this.gridHeight = 1,
  });

  DashboardItem copyWith({
    String? id,
    String? title,
    DashboardItemType? type,
    Map<String, dynamic>? data,
    int? gridWidth,
    int? gridHeight,
  }) {
    return DashboardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      data: data ?? this.data,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
    );
  }
}
