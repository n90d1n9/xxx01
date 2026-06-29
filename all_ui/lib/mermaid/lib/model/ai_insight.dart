/// AI-powered insights
class AIInsight {
  final String id;
  final String type; // 'trend', 'anomaly', 'correlation', 'prediction'
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final List<String> affectedColumns;

  AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.metadata,
    required this.generatedAt,
    this.affectedColumns = const [],
  });
}
