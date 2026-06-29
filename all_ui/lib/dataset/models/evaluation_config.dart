import 'evaluation_metric.dart';

class EvaluationConfig {
  final List<EvaluationMetric> metrics;
  final bool enableHumanEval;
  final int? humanEvalSamples;
  final bool generateReport;
  final bool compareWithBaseline;
  final String? baselineModelPath;
  final List<String> testDatasets;
  final bool enableBiasDetection;
  final bool enableToxicityCheck;
  EvaluationConfig({
    this.metrics = const [
      EvaluationMetric.perplexity,
      EvaluationMetric.accuracy,
    ],
    this.enableHumanEval = false,
    this.humanEvalSamples,
    this.generateReport = true,
    this.compareWithBaseline = false,
    this.baselineModelPath,
    this.testDatasets = const [],
    this.enableBiasDetection = true,
    this.enableToxicityCheck = true,
  });
  Map<String, dynamic> toJson() => {
    'metrics': metrics.map((m) => m.name).toList(),
    'enableHumanEval': enableHumanEval,
    'humanEvalSamples': humanEvalSamples,
    'generateReport': generateReport,
    'compareWithBaseline': compareWithBaseline,
    'baselineModelPath': baselineModelPath,
    'testDatasets': testDatasets,
    'enableBiasDetection': enableBiasDetection,
    'enableToxicityCheck': enableToxicityCheck,
  };
}
