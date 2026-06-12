class SchemaRecommendation {
  final String title;
  final String description;
  final String benefit;
  final bool autoFixable;
  const SchemaRecommendation({
    required this.title,
    required this.description,
    required this.benefit,
    this.autoFixable = false,
  });
}
