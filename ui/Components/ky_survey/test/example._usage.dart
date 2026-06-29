// Example usage and integration
void main() async {
  // Initialize core components
  final stats = HypothesisTests();
  final plots = AdvancedPlots();
  final dimReduction = DimensionReduction();
  final reporter = ReportGenerator();
  
  // Configure analysis pipeline
  final pipeline = AnalysisPipeline(
    preprocessing: [
      DataCleaning(),
      Normalization(),
      OutlierDetection(),
    ],
    analysis: [
      DescriptiveStatistics(),
      HypothesisTesting(),
      DimensionalityReduction(),
    ],
    visualization: [
      DistributionPlots(),
      ComparisonPlots(),
      TimePlots(),
    ],
    validation: SchemaValidator(),
    export: ReportGenerator(),
  );
  
  // Process survey data
  final results = await pipeline.process(
    data: surveyData,
    config: AnalysisConfig(
      significance: 0.05,
      crossValidation: true,
      bootstrapIterations: 1000,
    ),
  );
  
  // Generate comprehensive report
  await reporter.generateReport(
    results: results,
    config: ReportConfig(
      formats: [ReportFormat.pdf, ReportFormat.html, ReportFormat.docx],
      includeInteractive: true,
      includeSummary: true,
    ),
    outputPath: 'reports/survey_analysis',
  );
}
