import 'package:stats/stats.dart';
import 'dart:math' as math;

class AdvancedStatistics {
  // Previous statistical methods remain...

  // New Advanced Statistical Tests
  double calculateFriedmanTest(List<List<double>> relatedGroups) {
    int n = relatedGroups[0].length;  // number of subjects
    int k = relatedGroups.length;     // number of treatments
    
    // Calculate ranks within each subject
    List<List<double>> ranks = List.generate(n, (_) => List<double>.filled(k, 0));
    
    for (int i = 0; i < n; i++) {
      List<double> subjectScores = List.generate(k, (j) => relatedGroups[j][i]);
      List<double> sortedScores = [...subjectScores]..sort();
      
      for (int j = 0; j < k; j++) {
        ranks[i][j] = sortedScores.indexOf(subjectScores[j]) + 1;
      }
    }
    
    // Calculate rank sums
    List<double> rankSums = List.generate(k, (j) =>
      ranks.fold(0.0, (sum, subject) => sum + subject[j]));
    
    // Calculate test statistic
    double sumSquaredRanks = rankSums.fold(0.0, (sum, r) => sum + r * r);
    double friedmanStatistic = (12 / (n * k * (k + 1))) * sumSquaredRanks - 3 * n * (k + 1);
    
    return friedmanStatistic;
  }

  Map<String, double> calculateRegressionDiagnostics(
    List<double> x,
    List<double> y,
    List<double> predictedY
  ) {
    double meanY = y.reduce((a, b) => a + b) / y.length;
    
    // Calculate R-squared
    double ssTotal = y.fold(0.0, (sum, yi) => sum + math.pow(yi - meanY, 2));
    double ssResidual = List.generate(y.length, (i) => math.pow(y[i] - predictedY[i], 2))
        .reduce((a, b) => a + b);
    double rSquared = 1 - (ssResidual / ssTotal);
    
    // Calculate Adjusted R-squared
    int n = x.length;
    int p = 1; // number of predictors
    double adjustedRSquared = 1 - ((1 - rSquared) * (n - 1) / (n - p - 1));
    
    // Calculate Durbin-Watson statistic
    double durbinWatson = 0.0;
    for (int i = 1; i < n; i++) {
      durbinWatson += math.pow(predictedY[i] - predictedY[i - 1], 2);
    }
    durbinWatson /= ssResidual;
    
    return {
      'r_squared': rSquared,
      'adjusted_r_squared': adjustedRSquared,
      'durbin_watson': durbinWatson,
    };
  }
}
