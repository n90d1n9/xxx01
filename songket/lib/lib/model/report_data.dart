class ReportData {
  final List<Map<String, dynamic>> rows;
  final Map<String, dynamic> summary;
  final Map<String, List<Map<String, dynamic>>>? groupedData;
  final int totalCount;
  final DateTime generatedAt;
  final Duration executionTime;
  final Map<String, dynamic>? chartData;

  ReportData({
    required this.rows,
    required this.summary,
    this.groupedData,
    required this.totalCount,
    required this.generatedAt,
    required this.executionTime,
    this.chartData,
  });
}
