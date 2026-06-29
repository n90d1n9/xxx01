import 'package:stats/stats.dart';
import 'dart:math' as math;

class AdvancedStatistics {
  // New Advanced Statistical Tests
  double calculateMannWhitneyU(List<double> group1, List<double> group2) {
    // Mann-Whitney U test for non-parametric comparison
    List<double> combined = [...group1, ...group2];
    combined.sort();
    
    Map<double, int> ranks = {};
    for (int i = 0; i < combined.length; i++) {
      ranks[combined[i]] = i + 1;
    }
    
    double r1 = group1.fold(0, (sum, x) => sum + ranks[x]!);
    int n1 = group1.length;
    int n2 = group2.length;
    
    double u1 = r1 - (n1 * (n1 + 1)) / 2;
    return u1;
  }

  double calculateKruskalWallis(List<List<double>> groups) {
    // Kruskal-Wallis H-test for multiple group comparison
    List<double> allValues = groups.expand((x) => x).toList();
    allValues.sort();
    
    // Calculate ranks
    Map<double, double> ranks = {};
    for (int i = 0; i < allValues.length; i++) {
      ranks[allValues[i]] = i + 1.0;
    }
    
    double h = 0;
    int totalN = allValues.length;
    
    for (var group in groups) {
      double groupRankSum = group.fold(0, (sum, x) => sum + ranks[x]!);
      h += math.pow(groupRankSum, 2) / group.length;
    }
    
    h = 12 / (totalN * (totalN + 1)) * h - 3 * (totalN + 1);
    return h;
  }

  Map<String, double> calculateDescriptiveStats(List<double> data) {
    data.sort();
    int n = data.length;
    
    return {
      'mean': data.reduce((a, b) => a + b) / n,
      'median': n.isOdd ? data[n ~/ 2] : (data[n ~/ 2 - 1] + data[n ~/ 2]) / 2,
      'q1': data[n ~/ 4],
      'q3': data[3 * n ~/ 4],
      'iqr': data[3 * n ~/ 4] - data[n ~/ 4],
      'skewness': calculateSkewness(data),
      'kurtosis': calculateKurtosis(data)
    };
  }
}
