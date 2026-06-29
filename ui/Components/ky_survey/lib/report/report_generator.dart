class ReportGenerator {
  /// Generates a comprehensive statistical report in multiple formats
  Future<void> generateReport({
    required AnalysisResults results,
    required ReportConfig config,
    required String outputPath,
  }) async {
    final report = Report(config);
    
    // Add summary statistics
    await report.addSection(
      title: 'Summary Statistics',
      content: _generateSummaryStats(results.summaryStats),
    );
    
    // Add hypothesis tests results
    await report.addSection(
      title: 'Hypothesis Tests',
      content: _generateTestResults(results.hypothesisTests),
    );
    
    // Add visualizations
    await report.addSection(
      title: 'Visualizations',
      content: await _generateVisualizations(results.plots),
    );
    
    // Add machine learning results if available
    if (results.mlResults != null) {
      await report.addSection(
        title: 'Machine Learning Analysis',
        content: _generateMLResults(results.mlResults!),
      );
    }
    
    // Export in specified formats
    for (var format in config.exportFormats) {
      await report.export(
        format: format,
        path: '$outputPath/${format.name}',
      );
    }
  }
}
