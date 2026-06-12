import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_explorer_logic.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/chart_sample_test_fixtures.dart';

void main() {
  test('type filter options count families once per chart type', () {
    const families = [
      ChartShowcaseFamily(
        id: 'cartesian',
        title: 'Cartesian',
        description: 'Cartesian family.',
        samples: [
          ChartShowcaseSample('Revenue Bars', 180, testBarSampleJson),
          ChartShowcaseSample('Cost Bars', 180, testBarSampleJson),
        ],
      ),
      ChartShowcaseFamily(
        id: 'distribution',
        title: 'Distribution',
        description: 'Distribution family.',
        samples: [
          ChartShowcaseSample(
            'Latency Histogram',
            180,
            testHistogramSampleJson,
          ),
          ChartShowcaseSample('Variance Violin', 180, testViolinSampleJson),
        ],
      ),
      ChartShowcaseFamily(
        id: 'mixed',
        title: 'Mixed',
        description: 'Mixed family.',
        samples: [
          ChartShowcaseSample('Mixed Histogram', 180, testHistogramSampleJson),
        ],
      ),
    ];

    final options = chartTypeFilterOptions(families);

    expect(options.map((option) => option.type), [
      'histogram',
      'bar',
      'violin',
    ]);
    expect(options.map((option) => option.familyCount), [2, 1, 1]);
  });

  test('family filtering combines query, type, and sort mode', () {
    expect(
      filterChartFamilies(
        families: testSortFamilies,
        query: 'histogram',
        selectedChartType: null,
        sortMode: ChartFamilySortMode.name,
      ).map((family) => family.id),
      ['alpha', 'beta'],
    );
    expect(
      filterChartFamilies(
        families: testSortFamilies,
        query: '',
        selectedChartType: 'bar',
        sortMode: ChartFamilySortMode.samples,
      ).map((family) => family.id),
      ['beta', 'gamma'],
    );
  });

  test('family filtering can match tier metadata', () {
    expect(
      filterChartFamilies(
        families: testTierFamilies,
        query: 'pro',
        selectedChartType: null,
        sortMode: ChartFamilySortMode.curated,
      ).map((family) => family.id),
      ['advanced'],
    );
    expect(
      filterChartFamilies(
        families: testTierFamilies,
        query: '',
        selectedTierFilter: ChartShowcaseTierFilter.pro,
        selectedChartType: null,
        sortMode: ChartFamilySortMode.curated,
      ).map((family) => family.id),
      ['advanced'],
    );
  });

  test('visible samples narrow by type and sample query', () {
    expect(
      visibleChartSamplesForFamily(
        family: testMixedFamily,
        query: '',
        selectedChartType: 'histogram',
      ).map((sample) => sample.title),
      ['Latency Histogram'],
    );
    expect(
      visibleChartSamplesForFamily(
        family: testMixedFamily,
        query: 'variance',
        selectedChartType: null,
      ).map((sample) => sample.title),
      ['Variance Violin'],
    );
    expect(
      visibleChartSamplesForFamily(
        family: testMixedFamily,
        query: 'family-level-query',
        selectedChartType: null,
      ).map((sample) => sample.title),
      ['Revenue Bars', 'Latency Histogram', 'Variance Violin'],
    );
  });

  test('stats can summarize total families or filtered sample scope', () {
    final total = chartFamilyExplorerStats(
      families: testStatsFamilies,
      query: '',
      selectedChartType: null,
      filterSamples: false,
    );
    final filteredFamilies = filterChartFamilies(
      families: testStatsFamilies,
      query: '',
      selectedChartType: 'histogram',
      sortMode: ChartFamilySortMode.curated,
    );
    final visible = chartFamilyExplorerStats(
      families: filteredFamilies,
      query: '',
      selectedChartType: 'histogram',
      filterSamples: true,
    );

    expect(total.familyCount, 2);
    expect(total.sampleCount, 3);
    expect(total.typeCount, 3);
    expect(visible.familyCount, 1);
    expect(visible.sampleCount, 1);
    expect(visible.typeCount, 1);
    expect(chartExplorerStatValue(visible: 1, total: 3, filtered: true), '1/3');
  });

  test(
    'selection helpers resolve missing family and stale chart type state',
    () {
      expect(
        resolveChartFamilyId(
          families: testBaseFamilies,
          requestedId: 'distribution',
        ),
        'distribution',
      );
      expect(
        resolveChartFamilyId(
          families: testBaseFamilies,
          requestedId: 'missing',
        ),
        'cartesian',
      );
      expect(
        resolveChartFamilyId(families: const [], requestedId: 'missing'),
        isNull,
      );
      expect(
        chartFamilyIdExists(families: testBaseFamilies, familyId: 'cartesian'),
        isTrue,
      );
      expect(
        chartFamilyIdExists(families: testBaseFamilies, familyId: 'missing'),
        isFalse,
      );
      expect(
        sanitizeSelectedTierFilter(
          families: testTierFamilies,
          selectedTierFilter: ChartShowcaseTierFilter.pro,
        ),
        ChartShowcaseTierFilter.pro,
      );
      expect(
        sanitizeSelectedTierFilter(
          families: testBaseFamilies,
          selectedTierFilter: ChartShowcaseTierFilter.pro,
        ),
        ChartShowcaseTierFilter.all,
      );
      expect(
        sanitizeSelectedChartType(
          families: testBaseFamilies,
          selectedChartType: 'histogram',
        ),
        'histogram',
      );
      expect(
        sanitizeSelectedChartType(
          families: testBaseFamilies,
          selectedChartType: 'violin',
        ),
        isNull,
      );
      expect(
        resolveVisibleChartFamilyId(
          families: testBaseFamilies,
          query: '',
          selectedChartType: 'histogram',
          selectedFamilyId: 'cartesian',
          sortMode: ChartFamilySortMode.curated,
        ),
        'distribution',
      );
      expect(
        resolveVisibleChartFamilyId(
          families: testBaseFamilies,
          query: 'missing',
          selectedChartType: null,
          selectedFamilyId: 'cartesian',
          sortMode: ChartFamilySortMode.curated,
        ),
        isNull,
      );
    },
  );

  test(
    'explorer snapshot centralizes filtered families and sample details',
    () {
      final snapshot = chartFamilyExplorerSnapshot(
        families: testStatsFamilies,
        query: '',
        selectedChartType: 'histogram',
        selectedFamilyId: 'cartesian',
        sortMode: ChartFamilySortMode.curated,
      );

      expect(snapshot.hasActiveFilters, isTrue);
      expect(snapshot.typeOptions.map((option) => option.type), [
        'bar',
        'histogram',
        'violin',
      ]);
      expect(snapshot.filteredFamilies.map((family) => family.id), [
        'distribution',
      ]);
      expect(snapshot.selectedFamily?.id, 'distribution');
      expect(snapshot.selectedSamples.map((sample) => sample.title), [
        'Latency Histogram',
      ]);
      expect(snapshot.totalStats.sampleCount, 3);
      expect(snapshot.visibleStats.sampleCount, 1);
    },
  );

  test('explorer snapshot scopes type filters by selected tier', () {
    final snapshot = chartFamilyExplorerSnapshot(
      families: testTierFamilies,
      query: '',
      selectedTierFilter: ChartShowcaseTierFilter.pro,
      selectedChartType: null,
      selectedFamilyId: 'cartesian',
      sortMode: ChartFamilySortMode.curated,
    );

    expect(snapshot.hasActiveFilters, isTrue);
    expect(snapshot.tierOptions.map((option) => option.tierFilter), [
      ChartShowcaseTierFilter.core,
      ChartShowcaseTierFilter.pro,
    ]);
    expect(snapshot.typeOptions.map((option) => option.type), ['histogram']);
    expect(snapshot.filteredFamilies.map((family) => family.id), ['advanced']);
    expect(snapshot.selectedFamily?.id, 'advanced');
    expect(snapshot.selectedSamples.map((sample) => sample.title), [
      'Latency Histogram',
    ]);
  });
}
