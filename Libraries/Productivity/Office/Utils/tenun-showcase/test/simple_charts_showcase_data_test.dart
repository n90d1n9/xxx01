import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_data.dart';

void main() {
  test('aggregate showcase data forwards to family datasets', () {
    expect(
      SimpleChartsShowcaseData.regionalGrowth,
      same(SimpleChartsShowcaseCoreData.regionalGrowth),
    );
    expect(
      SimpleChartsShowcaseData.engagementScores,
      same(SimpleChartsShowcaseAdvancedDashboardData.engagementScores),
    );
    expect(
      SimpleChartsShowcaseData.operatingTargets,
      same(SimpleChartsShowcaseAdvancedDashboardData.operatingTargets),
    );
    expect(
      SimpleChartsShowcaseData.capabilityMatrix,
      same(SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrix),
    );
    expect(
      SimpleChartsShowcaseData.scoreDistribution,
      same(SimpleChartsShowcaseStatisticalData.scoreDistribution),
    );
    expect(
      SimpleChartsShowcaseData.learningCalendar,
      same(SimpleChartsShowcaseStatisticalData.learningCalendar),
    );
    expect(
      SimpleChartsShowcaseData.portfolioShare,
      same(SimpleChartsShowcaseCompositionData.portfolioShare),
    );
    expect(
      SimpleChartsShowcaseData.priorityPareto,
      same(SimpleChartsShowcaseComparisonData.priorityPareto),
    );
    expect(
      SimpleChartsShowcaseData.journeyFlow,
      same(SimpleChartsShowcaseFlowData.journeyFlow),
    );
    expect(
      SimpleChartsShowcaseData.revenueTrend,
      same(SimpleChartsShowcaseTrendsData.revenueTrend),
    );
  });
}
