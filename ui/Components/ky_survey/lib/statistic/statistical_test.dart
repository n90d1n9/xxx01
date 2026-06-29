class StatisticalTest {
  final String name;
  final double statistic;
  final double pValue;
  final bool isSignificant;
  final Map<String, dynamic> additionalMetrics;

  StatisticalTest({
    required this.name,
    required this.statistic,
    required this.pValue,
    required this.isSignificant,
    this.additionalMetrics = const {},
  });
}


class AdvancedStatistics {
  static StatisticalTest performTTest(List<double> group1, List<double> group2) {
    final tTest = TTest(group1, group2);
    return StatisticalTest(
      name: 'Student\'s t-test',
      statistic: tTest.tStatistic,
      pValue: tTest.pValue,
      isSignificant: tTest.pValue < 0.05,
      additionalMetrics: {
        'degreesOfFreedom': tTest.degreesOfFreedom,
        'cohensD': tTest.effectSize,
      },
    );
  }

  static StatisticalTest performChiSquareTest(
    Map<String, int> observed,
    Map<String, int> expected,
  ) {
    final chiSquare = ChiSquareTest(observed, expected);
    return StatisticalTest(
      name: 'Chi-square test',
      statistic: chiSquare.statistic,
      pValue: chiSquare.pValue,
      isSignificant: chiSquare.pValue < 0.05,
      additionalMetrics: {
        'degreesOfFreedom': chiSquare.degreesOfFreedom,
        'cramersV': chiSquare.cramersV,
      },
    );
  }

  static StatisticalTest performANOVA(List<List<double>> groups) {
    final anova = ANOVA(groups);
    return StatisticalTest(
      name: 'One-way ANOVA',
      statistic: anova.fStatistic,
      pValue: anova.pValue,
      isSignificant: anova.pValue < 0.05,
      additionalMetrics: {
        'etaSquared': anova.etaSquared,
        'betweenGroupVariance': anova.betweenGroupVariance,
        'withinGroupVariance': anova.withinGroupVariance,
      },
    );
  }

  static double calculateCorrelation(List<double> x, List<double> y) {
    final correlation = PearsonCorrelation(x, y);
    return correlation.coefficient;
  }
}
