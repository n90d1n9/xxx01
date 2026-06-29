import 'dart:math';
import 'package:collection/collection.dart';

import 'statistical_analysis.dart';

class StatisticalCalculator {
  static StatisticalAnalysis calculateStatistics(List<num> data) {
    final sortedData = List<double>.from(data)..sort();
    final n = data.length.toDouble();
    
    // Calculate mean
    final mean = data.average;
    
    // Calculate median
    final median = _calculateMedian(sortedData);
    
    // Calculate mode
    final mode = _calculateMode(data);
    
    // Calculate variance and standard deviation
    final variance = _calculateVariance(data, mean);
    final standardDeviation = sqrt(variance);
    
    // Calculate percentiles
    final percentiles = {
      '25th': _calculatePercentile(sortedData, 25),
      '50th': _calculatePercentile(sortedData, 50),
      '75th': _calculatePercentile(sortedData, 75),
      '90th': _calculatePercentile(sortedData, 90),
    };
    
    // Calculate skewness
    final skewness = _calculateSkewness(data, mean, standardDeviation);
    
    // Calculate kurtosis
    final kurtosis = _calculateKurtosis(data, mean, standardDeviation);
    
    // Calculate 95% confidence interval
    final confidenceInterval = _calculateConfidenceInterval(mean, standardDeviation, n);
    
    return StatisticalAnalysis(
      mean: mean,
      median: median,
      mode: mode,
      standardDeviation: standardDeviation,
      variance: variance,
      percentiles: percentiles,
      skewness: skewness,
      kurtosis: kurtosis,
      confidenceInterval: confidenceInterval,
    );
  }

  static double _calculateMedian(List<double> sortedData) {
    final middle = sortedData.length ~/ 2;
    if (sortedData.length.isOdd) {
      return sortedData[middle];
    }
    return (sortedData[middle - 1] + sortedData[middle]) / 2;
  }

  static double _calculateMode(List<num> data) {
    final frequency = <num, int>{};
    for (final value in data) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .toDouble();
  }

  static double _calculateVariance(List<num> data, double mean) {
    final squaredDifferences = data.map((x) => pow(x - mean, 2));
    return squaredDifferences.average;
  }

  static double _calculatePercentile(List<double> sortedData, int percentile) {
    final index = (percentile / 100) * (sortedData.length - 1);
    if (index.floor() == index) {
      return sortedData[index.toInt()];
    }
    final lower = sortedData[index.floor()];
    final upper = sortedData[index.ceil()];
    return lower + (upper - lower) * (index - index.floor());
  }

  static double _calculateSkewness(List<num> data, double mean, double standardDeviation) {
    final n = data.length.toDouble();
    final cubedDifferences = data.map((x) => pow(x - mean, 3));
    return (cubedDifferences.sum / n) / pow(standardDeviation, 3);
  }

  static double _calculateKurtosis(List<num> data, double mean, double standardDeviation) {
    final n = data.length.toDouble();
    final fourthPowerDifferences = data.map((x) => pow(x - mean, 4));
    return (fourthPowerDifferences.sum / n) / pow(standardDeviation, 4) - 3;
  }

  static List<double> _calculateConfidenceInterval(
    double mean,
    double standardDeviation,
    double n,
  ) {
    final standardError = standardDeviation / sqrt(n);
    final marginOfError = 1.96 * standardError; // 95% confidence level
    return [mean - marginOfError, mean + marginOfError];
  }
}
