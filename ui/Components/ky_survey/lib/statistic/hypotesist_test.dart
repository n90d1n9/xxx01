import 'dart:math' as math;
import 'package:stats/stats.dart';

class HypothesisTests {
  /// Performs Shapiro-Wilk test for normality
  /// Returns {statistic, pValue}
  Map<String, double> shapiroWilkTest(List<double> data) {
    data.sort();
    int n = data.length;
    double mean = data.reduce((a, b) => a + b) / n;
    
    // Calculate a[] coefficients
    List<double> a = _calculateShapiroCoefficients(n);
    
    // Calculate W statistic
    double numerator = 0;
    for (int i = 0; i < n ~/ 2; i++) {
      numerator += a[i] * (data[n - 1 - i] - data[i]);
    }
    numerator = numerator * numerator;
    
    double denominator = data.fold(0.0, (sum, x) => sum + math.pow(x - mean, 2));
    
    double w = numerator / denominator;
    double pValue = _calculateShapiroPValue(w, n);
    
    return {'statistic': w, 'pValue': pValue};
  }

  /// Performs Levene's test for homogeneity of variances
  /// Returns {statistic, pValue}
  Map<String, double> leveneTest(List<List<double>> groups) {
    int k = groups.length;
    List<double> allData = groups.expand((x) => x).toList();
    double overallMean = allData.reduce((a, b) => a + b) / allData.length;
    
    // Calculate absolute deviations
    List<List<double>> deviations = groups.map((group) {
      double groupMean = group.reduce((a, b) => a + b) / group.length;
      return group.map((x) => (x - groupMean).abs()).toList();
    }).toList();
    
    // Calculate test statistic
    double numerator = 0;
    double denominator = 0;
    
    for (int i = 0; i < k; i++) {
      double groupMean = deviations[i].reduce((a, b) => a + b) / deviations[i].length;
      numerator += deviations[i].length * math.pow(groupMean - overallMean, 2);
      
      for (double dev in deviations[i]) {
        denominator += math.pow(dev - groupMean, 2);
      }
    }
    
    double w = ((allData.length - k) * numerator) / ((k - 1) * denominator);
    double pValue = _calculateLevenePValue(w, k - 1, allData.length - k);
    
    return {'statistic': w, 'pValue': pValue};
  }
}
