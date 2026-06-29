class StatisticalAnalysis {
  final double mean;
  final double median;
  final double mode;
  final double standardDeviation;
  final double variance;
  final Map<String, double> percentiles;
  final double skewness;
  final double kurtosis;
  final List<double> confidenceInterval;

  StatisticalAnalysis({
    required this.mean,
    required this.median,
    required this.mode,
    required this.standardDeviation,
    required this.variance,
    required this.percentiles,
    required this.skewness,
    required this.kurtosis,
    required this.confidenceInterval,
  });
}
