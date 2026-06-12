import 'simple_charts_showcase_advanced_dashboard_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleAdvancedDashboardSampleSourceKey {
  engagementScores,
  operatingTargets,
  serviceHealth,
  readinessRings,
  capabilityProfile,
  capabilityMatrix,
}

SimpleChartSampleSource? simpleAdvancedDashboardSampleSource(
  SimpleAdvancedDashboardSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleAdvancedDashboardSampleSourceKey.engagementScores =>
      _engagementScoresSource(options),
    SimpleAdvancedDashboardSampleSourceKey.operatingTargets =>
      _operatingTargetsSource(options),
    SimpleAdvancedDashboardSampleSourceKey.serviceHealth =>
      _serviceHealthSource(options),
    SimpleAdvancedDashboardSampleSourceKey.readinessRings =>
      _readinessRingsSource(options),
    SimpleAdvancedDashboardSampleSourceKey.capabilityProfile =>
      _capabilityProfileSource(options),
    SimpleAdvancedDashboardSampleSourceKey.capabilityMatrix =>
      _capabilityMatrixSource(options),
  };
}

SimpleChartSampleSource _engagementScoresSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleLollipopChart',
      title: 'Engagement Scores',
      subtitle: 'Lightweight ranking comparison',
      data: {
        'data': simpleBarDataJson(
          SimpleChartsShowcaseAdvancedDashboardData.engagementScores,
        ),
      },
      options: {
        'style': options.barStyle.name,
        'orientation': 'horizontal',
        'showGrid': options.showGrid,
        'showValues': options.showValues,
        'showTooltip': options.showTooltips,
        'showActivePoint': options.showActiveBars,
        'showReferenceLines': options.showReferenceLines,
        'showReferenceBands': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleLollipopChart(
  data: SimpleChartsShowcaseAdvancedDashboardData.engagementScores,
  orientation: SimpleBarChartOrientation.horizontal,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  referenceLines: const [
    SimpleChartReferenceLine(value: 70, label: 'Benchmark'),
  ],
  referenceBands: const [
    SimpleChartReferenceBand(
      from: 65,
      to: 82,
      label: 'Strong',
      color: Color(0xFF14B8A6),
    ),
  ],
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _operatingTargetsSource(
  SimpleChartsGalleryOptions options,
) {
  final data = options.showReferenceBands
      ? SimpleChartsShowcaseAdvancedDashboardData.operatingTargets
      : SimpleChartsShowcaseAdvancedDashboardData.operatingTargetsPlain;

  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleBulletChart',
      title: 'Operating Targets',
      subtitle: 'Actual vs goal with ranges',
      data: {'data': simpleBulletDataJson(data)},
      options: {
        'style': options.barStyle.name,
        'showValues': options.showValues,
        'showTooltip': options.showTooltips,
        'showActiveBar': options.showActiveBars,
        'showRanges': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleBulletChart(
  data: ${options.showReferenceBands ? 'SimpleChartsShowcaseAdvancedDashboardData.operatingTargets' : 'SimpleChartsShowcaseAdvancedDashboardData.operatingTargetsPlain'},
  style: SimpleBarChartStyle.${options.barStyle.name},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveBar: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _serviceHealthSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleGaugeChart',
      title: 'Service Health',
      subtitle: 'KPI gauge with target bands',
      data: {
        'label': 'Readiness',
        'value': 86,
        'targetValue': options.showReferenceLines ? 90 : null,
        'unit': '%',
        'ranges': options.showReferenceBands
            ? simpleGaugeRangeJson(
                SimpleChartsShowcaseAdvancedDashboardData.readinessRanges,
              )
            : const [],
      },
      options: {
        'style': options.barStyle.name,
        'showTicks': options.showGrid,
        'showValue': options.showValues,
        'showNeedle': options.showTracks,
        'showRanges': options.showReferenceBands,
        'showTarget': options.showReferenceLines,
        'showTooltip': options.showTooltips,
        'showActiveGauge': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleGaugeChart(
  label: 'Readiness',
  value: 86,
  targetValue: ${options.showReferenceLines ? '90' : 'null'},
  unit: '%',
  ranges: ${options.showReferenceBands ? 'SimpleChartsShowcaseAdvancedDashboardData.readinessRanges' : 'const []'},
  style: SimpleBarChartStyle.${options.barStyle.name},
  showTicks: ${options.showGrid},
  showValue: ${options.showValues},
  showNeedle: ${options.showTracks},
  showRanges: ${options.showReferenceBands},
  showTarget: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveGauge: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _readinessRingsSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleRadialBarChart',
      title: 'Readiness Rings',
      subtitle: 'Multi-ring progress against targets',
      data: {
        'data': simpleRadialBarDataJson(
          SimpleChartsShowcaseAdvancedDashboardData.readinessRings,
        ),
        'centerLabel': 'Avg',
      },
      options: {
        'style': options.barStyle.name,
        'showLegend': options.showLegends,
        'showLabels': options.showValues,
        'showValues': options.showValues,
        'showTargets': options.showReferenceLines,
        'showTooltip': options.showTooltips,
        'showActiveRing': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleRadialBarChart(
  data: SimpleChartsShowcaseAdvancedDashboardData.readinessRings,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLegend: ${options.showLegends},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showTargets: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveRing: ${options.showActiveBars},
  centerLabel: 'Avg',
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _capabilityProfileSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleRadarChart',
      title: 'Capability Profile',
      subtitle: 'Multi-dimensional score comparison',
      data: {
        'axes': simpleRadarAxesJson(
          SimpleChartsShowcaseAdvancedDashboardData.capabilityAxes,
        ),
        'series': simpleRadarSeriesJson(
          SimpleChartsShowcaseAdvancedDashboardData.capabilityProfile,
        ),
      },
      options: {
        'style': options.barStyle.name,
        'showGrid': options.showGrid,
        'showLabels': true,
        'showValues': options.showValues,
        'showDots': options.showTracks,
        'showLegend': options.showLegends,
        'showTooltip': options.showTooltips,
        'showActiveAxis': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleRadarChart(
  axes: SimpleChartsShowcaseAdvancedDashboardData.capabilityAxes,
  series: SimpleChartsShowcaseAdvancedDashboardData.capabilityProfile,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showLabels: true,
  showValues: ${options.showValues},
  showDots: ${options.showTracks},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveAxis: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _capabilityMatrixSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleBubbleMatrixChart',
      title: 'Capability Matrix',
      subtitle: 'Categorical magnitude by segment',
      data: {
        'xLabels':
            SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixColumns,
        'yLabels':
            SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixRows,
        'cells': simpleBubbleMatrixCellsJson(
          SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrix,
        ),
        'minValue': 0,
        'maxValue': 100,
      },
      options: {
        'style': options.barStyle.name,
        'showGrid': options.showGrid,
        'showValues': options.showValues,
        'showLegend': options.showLegends,
        'showTooltip': options.showTooltips,
        'showActiveBubble': options.showActiveBars,
        'useColorScale': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleBubbleMatrixChart(
  xLabels: SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixColumns,
  yLabels: SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixRows,
  cells: SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrix,
  minValue: 0,
  maxValue: 100,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveBubble: ${options.showActiveBars},
  useColorScale: ${options.showReferenceBands},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}
