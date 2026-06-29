import 'schema_issue.dart';
import 'schema_recommendation.dart';

class SchemaHealthReport {
  final List<SchemaIssue> issues;
  final List<SchemaRecommendation> recommendations;
  final double healthScore;
  const SchemaHealthReport({
    required this.issues,
    required this.recommendations,
    required this.healthScore,
  });
}
