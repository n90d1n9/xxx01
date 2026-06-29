import '../model/ai_insight.dart';
import '../model/data_source.dart';
import '../model/report_column.dart';

class AIService {
  Future<List<AIInsight>> generateInsights(
    List<Map<String, dynamic>> data,
    List<ReportColumn> columns,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      AIInsight(
        id: '1',
        type: 'trend',
        title: 'Upward Trend Detected',
        description: 'Sales have increased by 23% over the last 30 days',
        confidence: 0.89,
        metadata: {'growth_rate': 0.23},
        generatedAt: DateTime.now(),
        affectedColumns: ['amount'],
      ),
      AIInsight(
        id: '2',
        type: 'anomaly',
        title: 'Unusual Activity',
        description:
            'Transaction volume on 2024-01-15 was 3x higher than average',
        confidence: 0.95,
        metadata: {'anomaly_date': '2024-01-15'},
        generatedAt: DateTime.now(),
        affectedColumns: ['quantity'],
      ),
    ];
  }

  Future<List<ReportColumn>> suggestColumns(
    DataSource source,
    List<Map<String, dynamic>> sampleData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // AI-powered column suggestions based on data patterns
    return [];
  }

  Future<String> naturalLanguageToQuery(String nlQuery) async {
    // Convert "Show me sales from last month" to SQL/filters
    await Future.delayed(const Duration(milliseconds: 300));
    return "SELECT * FROM sales WHERE date >= '2024-01-01'";
  }
}
