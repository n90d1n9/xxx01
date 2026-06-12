import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;
import 'package:tenun_showcase/example/simple_charts_showcase_api_examples.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_advanced_dashboard_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_comparison_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_composition_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_core_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_families.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_flow_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_advanced_dashboard.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_comparison.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_composition.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_flow.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_core.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_options.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_statistical.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_gallery_trends.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_source.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_source_audit.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_statistical_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_trend_sources.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_widgets.dart';

void main() {
  test('simple source converters build copyable JSON payloads', () {
    final source = SimpleChartSampleSource(
      sampleJson: simpleChartSourceJson(
        chartType: 'SimpleBarChart',
        title: 'Growth',
        subtitle: 'Small comparison',
        data: {
          'data': simpleBarDataJson(const [
            SimpleBarChartData(label: 'A', value: 12, color: Color(0xFF2563EB)),
          ]),
        },
        options: const {'showGrid': true},
      ),
      dartCode: 'SimpleBarChart(data: data)',
    );

    expect(source.jsonText, contains('"type": "SimpleBarChart"'));
    expect(source.jsonText, contains('"color": "#FF2563EB"'));
    expect(source.jsonText, contains('"showGrid": true'));
  });

  test('trend source converters include series and nested bands', () {
    final trend = simpleTrendSeriesJson(const [
      SimpleTrendSeries(
        name: 'Target',
        lineStyle: SimpleTrendLineStyle.dashed,
        points: [
          SimpleTrendPoint(label: 'Jan', value: 42),
          SimpleTrendPoint(label: 'Feb', value: 48),
        ],
      ),
    ]);
    final fan = simpleFanChartPointsJson(const [
      SimpleFanChartPoint(
        label: 'Jul',
        value: 78,
        bands: [SimpleFanChartBand(label: '80%', lower: 66, upper: 91)],
      ),
    ]);

    expect(trend.single['lineStyle'], 'dashed');
    expect(trend.single['points'], hasLength(2));
    expect(fan.single['bands'], hasLength(1));
    expect((fan.single['bands'] as List).single, containsPair('upper', 91));
  });

  test('flow source converters include relationship and bar payloads', () {
    final links = simpleSankeyLinksJson(const [
      SimpleSankeyLink(source: 'Visit', target: 'Trial', value: 42),
    ]);
    final series = simpleGroupedBarSeriesJson(const [
      SimpleGroupedBarSeries(name: 'Online', values: [28, 34]),
    ]);
    final waterfall = simpleWaterfallDataJson(const [
      SimpleWaterfallChartData(label: 'Opening', value: 120, isTotal: true),
    ]);

    expect(links.single, containsPair('source', 'Visit'));
    expect(series.single['values'], [28, 34]);
    expect(waterfall.single['isTotal'], isTrue);
  });

  test('comparison source converters include intervals and schedules', () {
    final ranges = simpleRangeDataJson(const [
      SimpleRangeChartData(label: 'North', min: 62, max: 88, value: 76),
    ]);
    final likert = simpleLikertCategoriesJson(const [
      SimpleLikertCategory(
        label: 'Agree',
        sentiment: SimpleLikertSentiment.positive,
      ),
    ]);
    final events = simpleTimelineEventsJson([
      SimpleTimelineEvent(date: DateTime(2026, 1, 8), title: 'Discovery'),
    ]);
    final tasks = simpleGanttTasksJson([
      SimpleGanttTask(
        id: 'discover',
        label: 'Discovery',
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 12),
      ),
    ]);

    expect(ranges.single, containsPair('value', 76));
    expect(likert.single, containsPair('sentiment', 'positive'));
    expect(events.single, containsPair('date', '2026-01-08'));
    expect(tasks.single, containsPair('end', '2026-01-12'));
  });

  test('composition source converters include sets and hierarchies', () {
    final ternary = simpleTernaryPointsJson(const [
      SimpleTernaryPoint(label: 'Balanced', a: 34, b: 33, c: 33, size: 42),
    ]);
    final venn = simpleVennIntersectionsJson(const [
      SimpleVennIntersection(
        setIds: ['growth', 'product'],
        value: 34,
        label: 'Growth + Product',
      ),
    ]);
    final tree = simpleTreemapDataJson(const [
      SimpleTreemapData(
        label: 'Core',
        value: 42,
        children: [SimpleTreemapData(label: 'Product', value: 18)],
      ),
    ]);
    final mosaic = simpleMosaicPlotCellsJson(const [
      SimpleMosaicPlotCell(xLabel: 'SMB', yLabel: 'Online', value: 32),
    ]);

    expect(ternary.single, containsPair('c', 33));
    expect(venn.single['setIds'], ['growth', 'product']);
    expect((tree.single['children'] as List).single, containsPair('value', 18));
    expect(mosaic.single, containsPair('yLabel', 'Online'));
  });

  test('statistical source converters include matrix and date payloads', () {
    final heatmap = simpleHeatmapCellsJson(const [
      SimpleHeatmapCell(xLabel: 'Mon', yLabel: 'Morning', value: 32),
    ]);
    final axes = simpleParallelAxesJson(const [
      SimpleParallelAxis(label: 'Risk', min: 0, max: 100, inverted: true),
    ]);
    final calendar = simpleCalendarHeatmapDataJson([
      SimpleCalendarHeatmapData(date: DateTime(2026, 1, 5), value: 18),
    ]);
    final density = simpleDensitySeriesJson(const [
      SimpleDensitySeries(name: 'Pilot', values: [62, 74, 81]),
    ]);
    final qqPlot = simpleQQPlotSeriesJson(const [
      SimpleQQPlotSeries(
        name: 'Program',
        sampleValues: [58, 76],
        referenceValues: [55, 72],
        referenceName: 'Control',
      ),
    ]);
    final boxPlot = simpleBoxPlotDataJson(const [
      SimpleBoxPlotData(
        label: 'Cohort A',
        min: 42,
        q1: 58,
        median: 72,
        q3: 84,
        max: 95,
        outliers: [99],
      ),
    ]);

    expect(heatmap.single, containsPair('xLabel', 'Mon'));
    expect(axes.single, containsPair('inverted', isTrue));
    expect(calendar.single, containsPair('date', '2026-01-05'));
    expect(density.single['values'], [62, 74, 81]);
    expect(qqPlot.single, containsPair('referenceName', 'Control'));
    expect(boxPlot.single['outliers'], [99]);
  });

  test('core simple panels expose source metadata and honor options', () {
    final panels = simpleChartsCorePanels(
      _options(showSampleJson: true, showSampleCode: false),
    );
    final firstPanel = panels.first as SimpleChartsShowcasePanel;

    expect(firstPanel.source?.jsonText, contains('SimpleBarChart'));
    expect(firstPanel.source?.dartCode, contains('SimpleBarChart('));
    expect(firstPanel.showSampleJson, isTrue);
    expect(firstPanel.showSampleCode, isFalse);
  });

  test('core source factory centralizes lazy source selection', () {
    final disabled = simpleCoreSampleSource(
      SimpleCoreSampleSourceKey.regionalGrowth,
      _options(),
    );
    final enabled = simpleCoreSampleSource(
      SimpleCoreSampleSourceKey.courseOutcomes,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleBarChart'));
    expect(enabled?.dartCode, contains('SimpleBarChart('));
  });

  test(
    'advanced dashboard source factory centralizes lazy source selection',
    () {
      final disabled = simpleAdvancedDashboardSampleSource(
        SimpleAdvancedDashboardSampleSourceKey.operatingTargets,
        _options(),
      );
      final enabled = simpleAdvancedDashboardSampleSource(
        SimpleAdvancedDashboardSampleSourceKey.capabilityMatrix,
        _options(showSampleJson: true),
      );

      expect(disabled, isNull);
      expect(enabled?.jsonText, contains('SimpleBubbleMatrixChart'));
      expect(enabled?.dartCode, contains('SimpleBubbleMatrixChart('));
    },
  );

  test('api behavior panel exposes shared field examples lazily', () {
    final disabled = simpleChartsApiPanels(_options());
    final enabled = simpleChartsApiPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledPanel = disabled.single as SimpleChartsShowcasePanel;
    final enabledPanel = enabled.single as SimpleChartsShowcasePanel;

    expect(disabledPanel.source, isNull);
    expect(enabledPanel.source?.jsonText, contains('emptyBuilder'));
    expect(enabledPanel.source?.jsonText, contains('excludeFromSemantics'));
    expect(enabledPanel.source?.dartCode, contains('semanticLabel:'));
    expect(enabledPanel.source?.dartCode, contains('onBarTap:'));
  });

  test('shared family registry drives audit defaults', () {
    expect(simpleChartsShowcaseFamilies.map((family) => family.id), [
      'api',
      'core',
      'advanced_dashboard',
      'statistical',
      'composition',
      'comparison',
      'flow',
      'trends',
    ]);
    expect(
      simpleChartsShowcaseFamilies.where(
        (family) => family.tier == SimpleChartsShowcaseTier.core,
      ),
      hasLength(2),
    );
    expect(
      simpleChartsShowcaseFamilies.where(
        (family) => family.tier == SimpleChartsShowcaseTier.pro,
      ),
      hasLength(6),
    );
    expect(
      simpleChartsShowcaseFamiliesForTier(
        SimpleChartsShowcaseTierFilter.all,
      ).map((family) => family.id),
      simpleChartsShowcaseFamilies.map((family) => family.id),
    );
    expect(
      simpleChartsShowcaseFamiliesForTier(
        SimpleChartsShowcaseTierFilter.core,
      ).map((family) => family.id),
      ['api', 'core'],
    );
    expect(
      simpleChartsShowcaseFamiliesForTier(
        SimpleChartsShowcaseTierFilter.pro,
      ).map((family) => family.id),
      [
        'advanced_dashboard',
        'statistical',
        'composition',
        'comparison',
        'flow',
        'trends',
      ],
    );
    expect(
      simpleChartSourceAuditDefaultFamilies.map((family) => family.id),
      simpleChartsShowcaseFamilies.map((family) => family.id),
    );
    expect(
      simpleChartSourceAuditDefaultFamilies.map((family) => family.title),
      simpleChartsShowcaseFamilies.map((family) => family.auditTitle),
    );
    expect(
      simpleChartSourceAuditDefaultFamilies.map((family) => family.tier),
      simpleChartsShowcaseFamilies.map((family) => family.tier),
    );
  });

  test('flow source factory centralizes lazy source selection', () {
    final disabled = simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.conversionFunnel,
      _options(),
    );
    final enabled = simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.profitBridge,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleWaterfallChart'));
    expect(enabled?.dartCode, contains('SimpleWaterfallChart('));
  });

  test('comparison source factory centralizes lazy source selection', () {
    final disabled = simpleComparisonSampleSource(
      SimpleComparisonSampleSourceKey.priorityPareto,
      _options(),
    );
    final enabled = simpleComparisonSampleSource(
      SimpleComparisonSampleSourceKey.projectGantt,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleGanttChart'));
    expect(enabled?.dartCode, contains('SimpleGanttChart('));
  });

  test('composition source factory centralizes lazy source selection', () {
    final disabled = simpleCompositionSampleSource(
      SimpleCompositionSampleSourceKey.portfolioShare,
      _options(),
    );
    final enabled = simpleCompositionSampleSource(
      SimpleCompositionSampleSourceKey.portfolioSunburst,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleSunburstChart'));
    expect(enabled?.dartCode, contains('SimpleSunburstChart('));
  });

  test('statistical source factory centralizes lazy source selection', () {
    final disabled = simpleStatisticalSampleSource(
      SimpleStatisticalSampleSourceKey.activityHeatmap,
      _options(),
    );
    final enabled = simpleStatisticalSampleSource(
      SimpleStatisticalSampleSourceKey.sampleBeeswarm,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleBeeswarmChart'));
    expect(enabled?.dartCode, contains('SimpleBeeswarmChart('));
  });

  test('simple chart families build source metadata lazily', () {
    final disabledCore = simpleChartsCorePanels(_options());
    final enabledAdvancedDashboard = simpleChartsAdvancedDashboardPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledAdvancedDashboard = simpleChartsAdvancedDashboardPanels(
      _options(),
    );
    final enabledComparison = simpleChartsComparisonPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledComparison = simpleChartsComparisonPanels(_options());
    final enabledComposition = simpleChartsCompositionPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledComposition = simpleChartsCompositionPanels(_options());
    final enabledFlow = simpleChartsFlowPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledFlow = simpleChartsFlowPanels(_options());
    final enabledStatistical = simpleChartsStatisticalPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledStatistical = simpleChartsStatisticalPanels(_options());
    final enabledTrends = simpleChartsTrendPanels(
      _options(showSampleJson: true, showSampleCode: true),
    );
    final disabledTrends = simpleChartsTrendPanels(_options());

    expect(
      disabledCore.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledAdvancedDashboard.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledAdvancedDashboard.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledComparison.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledComparison.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledComposition.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledComposition.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledFlow.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledFlow.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledStatistical.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledStatistical.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );
    expect(
      enabledTrends.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNotNull),
    );
    expect(
      disabledTrends.cast<SimpleChartsShowcasePanel>().map(
        (panel) => panel.source,
      ),
      everyElement(isNull),
    );

    final revenueTrend = enabledTrends.first as SimpleChartsShowcasePanel;
    final channelStream = enabledTrends.last as SimpleChartsShowcasePanel;
    final priorityPareto = enabledComparison.first as SimpleChartsShowcasePanel;
    final cohortPyramid = enabledComparison.last as SimpleChartsShowcasePanel;
    final portfolioShare =
        enabledComposition.first as SimpleChartsShowcasePanel;
    final channelMosaic = enabledComposition.last as SimpleChartsShowcasePanel;
    final conversionFunnel = enabledFlow.first as SimpleChartsShowcasePanel;
    final profitBridge = enabledFlow.last as SimpleChartsShowcasePanel;
    final activityHeatmap =
        enabledStatistical.first as SimpleChartsShowcasePanel;
    final learningCalendar =
        enabledStatistical[11] as SimpleChartsShowcasePanel;
    final sampleBeeswarm = enabledStatistical.last as SimpleChartsShowcasePanel;
    final engagementScores =
        enabledAdvancedDashboard.first as SimpleChartsShowcasePanel;
    final capabilityMatrix =
        enabledAdvancedDashboard.last as SimpleChartsShowcasePanel;

    expect(revenueTrend.source?.jsonText, contains('SimpleLineChart'));
    expect(revenueTrend.source?.dartCode, contains('SimpleLineChart('));
    expect(channelStream.source?.jsonText, contains('SimpleStreamgraphChart'));
    expect(channelStream.source?.dartCode, contains('SimpleStreamgraphChart('));
    expect(priorityPareto.source?.jsonText, contains('SimpleParetoChart'));
    expect(
      cohortPyramid.source?.dartCode,
      contains('SimplePopulationPyramidChart('),
    );
    expect(portfolioShare.source?.jsonText, contains('SimpleWaffleChart'));
    expect(channelMosaic.source?.dartCode, contains('SimpleMosaicPlotChart('));
    expect(conversionFunnel.source?.jsonText, contains('SimpleFunnelChart'));
    expect(profitBridge.source?.dartCode, contains('SimpleWaterfallChart('));
    expect(activityHeatmap.source?.jsonText, contains('SimpleHeatmapChart'));
    expect(
      learningCalendar.source?.dartCode,
      contains('SimpleCalendarHeatmapChart('),
    );
    expect(sampleBeeswarm.source?.jsonText, contains('SimpleBeeswarmChart'));
    expect(sampleBeeswarm.source?.dartCode, contains('SimpleBeeswarmChart('));
    expect(engagementScores.source?.jsonText, contains('SimpleLollipopChart'));
    expect(engagementScores.source?.dartCode, contains('SimpleLollipopChart('));
    expect(
      capabilityMatrix.source?.jsonText,
      contains('SimpleBubbleMatrixChart'),
    );
    expect(
      capabilityMatrix.source?.dartCode,
      contains('SimpleBubbleMatrixChart('),
    );
  });

  test('trend source factory centralizes lazy source selection', () {
    final disabled = simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.revenueTrend,
      _options(),
    );
    final enabled = simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.channelStream,
      _options(showSampleJson: true),
    );

    expect(disabled, isNull);
    expect(enabled?.jsonText, contains('SimpleStreamgraphChart'));
    expect(enabled?.dartCode, contains('SimpleStreamgraphChart('));
  });

  test('simple source audit covers every simple chart family', () {
    final audit = auditSimpleChartShowcaseSources();
    final json = audit.toJson();

    expect(audit.isValid, isTrue);
    expect(audit.familyCount, 8);
    expect(audit.familyTierCounts, {'core': 2, 'pro': 6});
    expect(audit.caseCount, 5);
    expect(audit.panelCount, greaterThan(0));
    expect(audit.sourceCount, audit.requiredSourceCount);
    expect(audit.requiredSourceCount, greaterThan(audit.panelCount));
    expect(audit.unexpectedSourceCount, 0);
    expect(audit.missingSourceCount, 0);
    expect(audit.caseResults, hasLength(5));
    expect(audit.caseResults.first.sourceCount, audit.panelCount);
    expect(audit.caseResults.first.requiredSourceCount, audit.panelCount);
    expect(audit.caseResults.last.sourceCount, 0);
    expect(audit.caseResults.last.requiredSourceCount, 0);
    expect(audit.caseResults.last.unexpectedSourceCount, 0);
    expect(audit.chartTypes, containsAll(['SimpleBarChart']));
    expect(audit.chartTypes, contains('SimpleStreamgraphChart'));
    expect(audit.chartTypes, contains('SimpleBeeswarmChart'));
    expect(json, containsPair('isValid', true));
    expect(json, containsPair('caseCount', 5));
    expect(json, containsPair('familyTierCounts', {'core': 2, 'pro': 6}));
    expect((json['families'] as List).first, containsPair('id', 'api'));
    expect((json['families'] as List).first, containsPair('tier', 'core'));
    expect((json['cases'] as List).last, containsPair('expectSources', false));
    expect((json['caseResults'] as List).last, containsPair('sourceCount', 0));
  });

  test('simple source audit reports missing source metadata', () {
    final audit = auditSimpleChartShowcaseSources(
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'broken',
          title: 'Broken',
          buildPanels: (options) => const [
            SimpleChartsShowcasePanel(
              width: 320,
              title: 'No Source',
              subtitle: 'Missing sample source',
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.sourceCount, 0);
    expect(audit.panelCount, 1);
    expect(audit.requiredSourceCount, 4);
    expect(audit.caseResults.first.missingSourceCount, 1);
    expect(audit.issueCodes, contains('SOURCE_MISSING'));
  });

  test('simple source audit reports sources left on while disabled', () {
    const source = SimpleChartSampleSource(
      sampleJson: {
        'type': 'SimpleBarChart',
        'data': {
          'data': [
            {'label': 'A', 'value': 12},
          ],
        },
      },
      dartCode: 'SimpleBarChart(data: data)',
    );
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'disabled',
          label: 'Disabled',
          options: simpleChartSourceAuditOptions(
            showSampleJson: false,
            showSampleCode: false,
          ),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'broken',
          title: 'Broken',
          buildPanels: (options) => const [
            SimpleChartsShowcasePanel(
              width: 320,
              title: 'Always On',
              subtitle: 'Source should be lazy',
              source: source,
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.requiredSourceCount, 0);
    expect(audit.unexpectedSourceCount, 1);
    expect(audit.caseResults.single.unexpectedSourceCount, 1);
    expect(audit.families.single.unexpectedSourceCount, 1);
    expect(audit.issueCodes, contains('SOURCE_PRESENT_WHEN_DISABLED'));
    expect(audit.issues.single.caseLabel, 'Disabled');
  });

  test('simple source audit reports panel title drift across cases', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'stable',
          label: 'Stable',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
        SimpleChartSourceAuditCase(
          id: 'drifted',
          label: 'Drifted',
          options: simpleChartSourceAuditOptions(showGrid: false),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'drift',
          title: 'Drift',
          buildPanels: (options) => [
            SimpleChartsShowcasePanel(
              width: 320,
              title: options.showGrid ? 'Stable Title' : 'Changed Title',
              subtitle: 'Title should not depend on knobs',
              child: const SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.issueCodes, contains('PANEL_TITLE_CHANGED'));
    expect(audit.issues.single.caseLabel, 'Drifted');
  });

  test('simple source audit reports source type drift across cases', () {
    SimpleChartSampleSource sourceFor(String chartType) {
      return SimpleChartSampleSource(
        sampleJson: {
          'type': chartType,
          'data': {
            'data': [
              {'label': 'A', 'value': 12},
            ],
          },
        },
        dartCode: '$chartType(data: data)',
      );
    }

    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'bar',
          label: 'Bar',
          options: simpleChartSourceAuditOptions(),
        ),
        SimpleChartSourceAuditCase(
          id: 'line',
          label: 'Line',
          options: simpleChartSourceAuditOptions(showGrid: false),
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'drift',
          title: 'Drift',
          buildPanels: (options) {
            final chartType = options.showGrid
                ? 'SimpleBarChart'
                : 'SimpleLineChart';
            return [
              SimpleChartsShowcasePanel(
                width: 320,
                title: 'Stable Title',
                subtitle: 'Source type should not depend on knobs',
                source: sourceFor(chartType),
                child: const SizedBox(height: 80),
              ),
            ];
          },
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.issueCodes, contains('SOURCE_TYPE_CHANGED'));
    expect(audit.issues.single.caseLabel, 'Line');
  });

  test('simple source audit reports duplicate case and family ids', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'duplicate',
          label: 'First',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
        SimpleChartSourceAuditCase(
          id: 'duplicate',
          label: 'Second',
          options: simpleChartSourceAuditOptions(showGrid: false),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'duplicate',
          title: 'First Family',
          buildPanels: (options) => const [],
        ),
        SimpleChartSourceAuditFamilySpec(
          id: 'duplicate',
          title: 'Second Family',
          buildPanels: (options) => const [],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.caseResults, hasLength(2));
    expect(audit.caseResults.map((result) => result.label), [
      'First',
      'Second',
    ]);
    expect(audit.issueCodes, contains('DUPLICATE_CASE_ID'));
    expect(audit.issueCodes, contains('DUPLICATE_FAMILY_ID'));
  });

  test('simple source audit reports blank case and family metadata', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: '',
          label: '',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: '',
          title: '',
          buildPanels: (options) => const [],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.issueCodes, contains('CASE_ID_EMPTY'));
    expect(audit.issueCodes, contains('CASE_LABEL_EMPTY'));
    expect(audit.issueCodes, contains('FAMILY_ID_EMPTY'));
    expect(audit.issueCodes, contains('FAMILY_TITLE_EMPTY'));
  });

  test('simple source audit reports blank panel metadata', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'baseline',
          label: 'Baseline',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'panels',
          title: 'Panels',
          buildPanels: (options) => const [
            SimpleChartsShowcasePanel(
              width: 320,
              title: '',
              subtitle: '',
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.issueCodes, contains('PANEL_TITLE_EMPTY'));
    expect(audit.issueCodes, contains('PANEL_SUBTITLE_EMPTY'));
  });

  test('simple source audit summarizes issue code counts', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'baseline',
          label: 'Baseline',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'panels',
          title: 'Panels',
          buildPanels: (options) => const [
            SimpleChartsShowcasePanel(
              width: 320,
              title: '',
              subtitle: '',
              child: SizedBox(height: 80),
            ),
            SimpleChartsShowcasePanel(
              width: 320,
              title: '',
              subtitle: '',
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );
    final json = audit.toJson();

    expect(audit.isValid, isFalse);
    expect(audit.issueCodeCounts, {
      'PANEL_SUBTITLE_EMPTY': 2,
      'PANEL_TITLE_EMPTY': 2,
    });
    expect(json, containsPair('issueCodeCounts', audit.issueCodeCounts));
  });

  test('simple source audit reports duplicate panel titles', () {
    final audit = auditSimpleChartShowcaseSources(
      cases: [
        SimpleChartSourceAuditCase(
          id: 'baseline',
          label: 'Baseline',
          options: simpleChartSourceAuditOptions(),
          expectSources: false,
        ),
      ],
      families: [
        SimpleChartSourceAuditFamilySpec(
          id: 'panels',
          title: 'Panels',
          buildPanels: (options) => const [
            SimpleChartsShowcasePanel(
              width: 320,
              title: 'Repeated',
              subtitle: 'First panel',
              child: SizedBox(height: 80),
            ),
            SimpleChartsShowcasePanel(
              width: 320,
              title: 'Repeated',
              subtitle: 'Second panel',
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ],
    );

    expect(audit.isValid, isFalse);
    expect(audit.issueCodes, contains('DUPLICATE_PANEL_TITLE'));
  });

  testWidgets('simple source panel renders and hides sample sections', (
    WidgetTester tester,
  ) async {
    const source = SimpleChartSampleSource(
      sampleJson: {
        'type': 'SimpleBarChart',
        'data': {
          'data': [
            {'label': 'A', 'value': 12},
          ],
        },
      },
      dartCode: 'SimpleBarChart(data: data)',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SimpleChartsShowcasePanel(
              width: 220,
              title: 'Compact Source',
              subtitle: 'Narrow layout',
              source: source,
              child: SizedBox(height: 80),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sample JSON'), findsOneWidget);
    expect(find.text('Dart Code'), findsOneWidget);
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SimpleChartsShowcasePanel(
              width: 220,
              title: 'Compact Source',
              subtitle: 'Narrow layout',
              source: source,
              showSampleJson: false,
              showSampleCode: false,
              child: SizedBox(height: 80),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sample JSON'), findsNothing);
    expect(find.text('Dart Code'), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api behavior demo renders shared widget states', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 520,
              height: 280,
              child: SimpleChartsApiBehaviorDemo(
                barStyle: SimpleBarChartStyle.elegant,
                trendStyle: SimpleTrendChartStyle.modern,
                showTooltips: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No rows ready'), findsOneWidget);
      expect(
        find.bySemanticsLabel('API behavior empty state chart.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Tap callback demo chart.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}

SimpleChartsGalleryOptions _options({
  bool showSampleJson = false,
  bool showSampleCode = false,
}) {
  return SimpleChartsGalleryOptions(
    panelWidth: 360,
    barStyle: SimpleBarChartStyle.elegant,
    trendStyle: SimpleTrendChartStyle.modern,
    showGrid: true,
    showValues: true,
    showTracks: true,
    showTooltips: true,
    showLegends: true,
    showReferenceLines: true,
    showReferenceBands: true,
    showActiveBars: true,
    stackAsPercent: false,
    showSampleJson: showSampleJson,
    showSampleCode: showSampleCode,
  );
}
