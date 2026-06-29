class DataQualityAnalyzer {
  Future<QualityReport> analyzeDataQuality(
    List<Map<String, dynamic>> data,
    QualityConfig config,
  ) async {
    final analyzer = QualityAnalyzer(config);
    
    final completenessScore = await analyzer.checkCompleteness(data);
    final consistencyScore = await analyzer.checkConsistency(data);
    final validityScore = await analyzer.checkValidity(data);
    
    return QualityReport(
      completenessScore: completenessScore,
      consistencyScore: consistencyScore,
      validityScore: validityScore,
      recommendations: await analyzer.generateRecommendations(),
    );
  }
}
