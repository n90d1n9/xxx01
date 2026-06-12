import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_cartesian_stories.dart';
import 'package:tenun_showcase/story/chart_catalog_utility_stories.dart';
import 'package:tenun_showcase/story/chart_financial_stories.dart';
import 'package:tenun_showcase/story/chart_matrix_stories.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('matrix stories stay grouped in navigation order', () {
    expect(chartMatrixStories.map((story) => story.name), const [
      'Charts/By Data Shape/Matrix/Heatmap/Basic',
    ]);
  });

  test('financial stories stay grouped in navigation order', () {
    expect(chartFinancialStories.map((story) => story.name), const [
      'Charts/By Data Shape/Financial/Candlestick/Basic',
    ]);
  });

  test('top-level chart stories keep specialized groups after cartesian', () {
    final names = charts.map((story) => story.name).toList();
    final lastCartesianVariantIndex = names.indexOf(
      chartCartesianVariantStories.last.name,
    );
    final firstMatrixIndex = names.indexOf(chartMatrixStories.first.name);
    final lastMatrixIndex = names.indexOf(chartMatrixStories.last.name);
    final firstFinancialIndex = names.indexOf(chartFinancialStories.first.name);
    final lastFinancialIndex = names.indexOf(chartFinancialStories.last.name);
    final firstUtilityIndex = names.indexOf(
      chartCatalogUtilityStories.first.name,
    );

    expect(firstMatrixIndex, lastCartesianVariantIndex + 1);
    expect(lastMatrixIndex, firstMatrixIndex + chartMatrixStories.length - 1);
    expect(firstFinancialIndex, lastMatrixIndex + 1);
    expect(
      lastFinancialIndex,
      firstFinancialIndex + chartFinancialStories.length - 1,
    );
    expect(firstUtilityIndex, lastFinancialIndex + 1);
  });
}
