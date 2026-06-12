import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_showcase/example/chart_sample_manifest_coverage.dart';
import 'package:tenun_showcase/example/chart_sample_registry_audit.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/chart_sample_test_fixtures.dart';
import 'support/showcase_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  test('registry centralizes non-simple showcase sample families', () {
    expect(ChartSamplesRegistry.aiML.map((sample) => sample.json['type']), [
      'confusionMatrix',
      'rocCurve',
    ]);
    expect(
      ChartSamplesRegistry.businessProject.map((sample) => sample.json['type']),
      ['sCurve', 'pareto', 'indicator', 'indicator'],
    );
    expect(
      ChartSamplesRegistry.statTradingGraph.map(
        (sample) => sample.json['type'],
      ),
      [
        'combo',
        'bullet',
        'histogram',
        'lollipop',
        'sparkline',
        'kagi',
        'renko',
        'macd',
        'ridgeline',
        'strip',
        'errorbar',
        'network',
        'radial',
        'timeline',
        'wordcloud',
        'calendar',
        'parallel',
        'violin',
      ],
    );
    expect(
      ChartSamplesRegistry.v3Variant.map((sample) => sample.json['type']),
      [
        'choropleth',
        'slope',
        'dumbbell',
        'areaBump',
        'barRace',
        'lineGradient',
        'halfDonut',
        'rainfall',
      ],
    );
    expect(
      [
        ...ChartSamplesRegistry.aiML,
        ...ChartSamplesRegistry.businessProject,
        ...ChartSamplesRegistry.statTradingGraph,
        ...ChartSamplesRegistry.v3Variant,
      ],
      everyElement(
        isA<ChartShowcaseSample>()
            .having((sample) => sample.title, 'title', isNotEmpty)
            .having((sample) => sample.height, 'height', greaterThan(0)),
      ),
    );
  });

  test('registry exposes named sample family catalog', () {
    expect(ChartSamplesRegistry.focusedFamilies.map((family) => family.id), [
      'ai_ml',
      'business_project',
      'hierarchy',
      'flow',
      'radial',
      'geo',
      'text_timeline',
      'canonical_mixed',
      'stat_trading_graph',
      'v3_variant',
    ]);
    expect(
      ChartSamplesRegistry.familyById('stat_trading_graph')?.samples,
      ChartSamplesRegistry.statTradingGraph,
    );
    expect(
      ChartSamplesRegistry.familyById('stat_trading_graph')?.tier,
      ChartShowcaseTier.pro,
    );
    expect(ChartSamplesRegistry.focusedFamilyTierCounts, {'pro': 10});
    expect(
      ChartSamplesRegistry.focusedFamiliesForTier(ChartShowcaseTierFilter.all),
      ChartSamplesRegistry.focusedFamilies,
    );
    expect(
      ChartSamplesRegistry.focusedFamiliesForTier(ChartShowcaseTierFilter.pro),
      ChartSamplesRegistry.focusedFamilies,
    );
    expect(
      ChartSamplesRegistry.focusedFamiliesForTier(ChartShowcaseTierFilter.core),
      isEmpty,
    );
    expect(ChartSamplesRegistry.familyById('missing'), isNull);
    expect(
      ChartSamplesRegistry.focusedSamples.length,
      ChartSamplesRegistry.focusedFamilies.fold<int>(
        0,
        (count, family) => count + family.sampleCount,
      ),
    );
    expect(
      ChartSamplesRegistry.focusedFamilies,
      everyElement(
        isA<ChartShowcaseFamily>()
            .having((family) => family.title, 'title', isNotEmpty)
            .having((family) => family.description, 'description', isNotEmpty)
            .having(
              (family) => family.sampleCount,
              'sampleCount',
              greaterThan(0),
            )
            .having(
              (family) => family.chartTypes.length,
              'chartTypes length',
              greaterThan(0),
            ),
      ),
    );
  });

  test('registry can audit focused samples against chart family manifest', () {
    final uniqueTypes = uniqueShowcaseChartTypesForFamilies(
      ChartSamplesRegistry.focusedFamilies,
    );

    expect(
      uniqueTypes,
      containsAll([
        'confusionMatrix',
        'rocCurve',
        'sCurve',
        'pareto',
        'indicator',
        'treemap',
        'sankey',
        'gauge',
        'combo',
        'barRace',
      ]),
    );
    expect(uniqueTypes, isNot(contains('')));

    final coverage = focusedChartSampleCoverage();

    expect(coverage.providedExampleKeys, uniqueTypes);
    expect(coverage.providedCount, uniqueTypes.length);
    expect(coverage.coveredCount, uniqueTypes.length);
    expect(coverage.missingCount, greaterThan(0));
    expect(coverage.unknownExampleKeys, isEmpty);
    expect(coverage.duplicateExampleKeys, isEmpty);
    expect(
      coverage.coveredEntries.map((entry) => entry.type),
      containsAll([
        ChartType.confusionMatrix,
        ChartType.rocCurve,
        ChartType.sCurve,
        ChartType.pareto,
        ChartType.indicator,
        ChartType.treemap,
        ChartType.sankey,
        ChartType.gauge,
        ChartType.combo,
        ChartType.barRace,
      ]),
    );

    final rawCoverage = focusedChartSampleCoverage(unique: false);

    expect(
      rawCoverage.providedCount,
      ChartSamplesRegistry.focusedSamples.length,
    );
    expect(rawCoverage.unknownExampleKeys, isEmpty);
    expect(
      rawCoverage.duplicateExampleKeys,
      containsAll([
        'indicator',
        'gauge',
        'radar',
        'funnel',
        'waterfall',
        'sankey',
        'sunburst',
        'treemap',
        'gantt',
        'polarBar',
        'radial',
        'timeline',
        'wordcloud',
        'calendar',
        'choropleth',
      ]),
    );
  });

  test('focused registry passes structural sample audit', () {
    final report = auditFocusedChartSamples(
      requireRegisteredTypes: true,
      includeValidationWarnings: false,
    );

    expect(
      report.errors,
      isEmpty,
      reason: report.errors
          .map(
            (issue) =>
                '${issue.familyId}/${issue.sampleTitle}: '
                '${issue.code} ${issue.message}',
          )
          .join('\n'),
    );
    expect(report.isValid, isTrue);
    expect(report.familyCount, ChartSamplesRegistry.focusedFamilies.length);
    expect(report.sampleCount, ChartSamplesRegistry.focusedSamples.length);
  });

  test('audit respects optional-series manifest contracts', () {
    const family = ChartShowcaseFamily(
      id: 'value_cards',
      title: 'Value Cards',
      description: 'Value-based samples without a series list.',
      samples: [
        ChartShowcaseSample(
          'Revenue Indicator',
          180,
          ChartSamplesRegistry.revenueIndicator,
        ),
        ChartShowcaseSample('Half Donut', 180, ChartSamplesRegistry.halfDonut),
      ],
    );

    final report = auditChartSampleFamilies(
      [family],
      requireRegisteredTypes: true,
      includeValidationWarnings: false,
    );

    expect(report.isValid, isTrue);
    expect(report.errorCodes, isNot(contains('MISSING_SERIES')));
  });

  test('audit catches duplicate family and sample identity problems', () {
    const families = [
      ChartShowcaseFamily(
        id: 'duplicate',
        title: 'Repeated Family',
        description: 'Original family.',
        samples: [
          ChartShowcaseSample('Repeated Sample', 180, testBarSampleJson),
          ChartShowcaseSample('Repeated Sample', 180, testLineSampleJson),
        ],
      ),
      ChartShowcaseFamily(
        id: 'Duplicate',
        title: 'Repeated Family',
        description: 'Duplicate family.',
        samples: [],
      ),
    ];

    final report = auditChartSampleFamilies(families);

    expect(
      report.errorCodes,
      containsAll([
        'DUPLICATE_SAMPLE_TITLE',
        'DUPLICATE_FAMILY_ID',
        'DUPLICATE_FAMILY_TITLE',
        'EMPTY_FAMILY_SAMPLES',
      ]),
    );
    expect(
      report.errors.firstWhere(
        (issue) => issue.code == 'DUPLICATE_SAMPLE_TITLE',
      ),
      isA<ChartSampleRegistryAuditIssue>()
          .having((issue) => issue.familyId, 'familyId', 'duplicate')
          .having((issue) => issue.sampleIndex, 'sampleIndex', 1)
          .having(
            (issue) => issue.sampleTitle,
            'sampleTitle',
            'Repeated Sample',
          ),
    );
  });

  test(
    'audit catches missing, invalid, unsupported, and unregistered types',
    () {
      ChartRegistry.clear();

      const family = ChartShowcaseFamily(
        id: 'broken_types',
        title: 'Broken Types',
        description: 'Samples with intentionally invalid type declarations.',
        samples: [
          ChartShowcaseSample('Missing Type', 180, {'series': []}),
          ChartShowcaseSample('Blank Type', 180, {'type': ' ', 'series': []}),
          ChartShowcaseSample('Numeric Type', 180, {'type': 42, 'series': []}),
          ChartShowcaseSample('Unknown Type', 180, {
            'type': 'mysteryChart',
            'series': [],
          }),
          ChartShowcaseSample('Known But Unregistered', 180, testBarSampleJson),
        ],
      );

      final report = auditChartSampleFamilies([
        family,
      ], requireRegisteredTypes: true);

      expect(
        report.errorCodes,
        containsAll([
          'MISSING_TYPE',
          'INVALID_TYPE_FIELD',
          'UNKNOWN_TYPE',
          'UNSUPPORTED_TYPE',
          'UNREGISTERED_TYPE',
        ]),
      );
      expect(
        report.errors
            .where((issue) => issue.code == 'UNREGISTERED_TYPE')
            .map((issue) => issue.sampleTitle),
        contains('Known But Unregistered'),
      );
      expect(
        report.errors.firstWhere((issue) => issue.code == 'UNSUPPORTED_TYPE'),
        isA<ChartSampleRegistryAuditIssue>()
            .having((issue) => issue.sampleTitle, 'sampleTitle', 'Unknown Type')
            .having((issue) => issue.chartType, 'chartType', 'mysteryChart'),
      );
    },
  );

  test('audit forwards payload validation errors with sample context', () {
    const family = ChartShowcaseFamily(
      id: 'malformed_payloads',
      title: 'Malformed Payloads',
      description: 'Samples with intentionally malformed payload fields.',
      samples: [
        ChartShowcaseSample('Malformed Bar', 180, {
          'type': 'bar',
          'dataMode': 99,
          'sampling': {'enabled': 'yes', 'threshold': 0},
          'series': [
            {'name': 'Bad', 'data': 'not-a-list'},
          ],
        }),
      ],
    );

    final report = auditChartSampleFamilies([
      family,
    ], includeValidationWarnings: false);

    expect(
      report.errorCodes,
      containsAll([
        'INVALID_DATA_MODE_TYPE',
        'INVALID_SAMPLING_ENABLED_TYPE',
        'INVALID_SAMPLING_THRESHOLD_VALUE',
        'INVALID_DATA_TYPE',
      ]),
    );
    expect(
      report.errors.firstWhere((issue) => issue.code == 'INVALID_DATA_TYPE'),
      isA<ChartSampleRegistryAuditIssue>()
          .having((issue) => issue.familyId, 'familyId', 'malformed_payloads')
          .having((issue) => issue.sampleTitle, 'sampleTitle', 'Malformed Bar')
          .having((issue) => issue.field, 'field', 'series[0].data'),
    );
  });
}
