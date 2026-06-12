import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleStatisticalSampleSourceKey {
  activityHeatmap,
  activityPunchCard,
  activityRadialHeatmap,
  metricCorrelation,
  capabilityScatterMatrix,
  regionalTileMap,
  usageDensity,
  usageHeatGrid,
  serviceTerritories,
  performanceContours,
  capabilityParallel,
  learningCalendar,
  scoreDistribution,
  scoreBinnedDots,
  scoreFrequencyPolygon,
  scoreDensity,
  scoreRaincloud,
  responseEcdf,
  scoreQQPlot,
  concentrationLorenz,
  measurementAgreement,
  scoreSpread,
  scoreBoxenPlot,
  scoreShape,
  cohortRidgelines,
  scoreRugPlot,
  responseBarcodePlot,
  sampleStripPlot,
  sampleSinaPlot,
  sampleBeeswarm,
}

SimpleChartSampleSource? simpleStatisticalSampleSource(
  SimpleStatisticalSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleStatisticalSampleSourceKey.activityHeatmap => _activityHeatmapSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.activityPunchCard =>
      _activityPunchCardSource(options),
    SimpleStatisticalSampleSourceKey.activityRadialHeatmap =>
      _activityRadialHeatmapSource(options),
    SimpleStatisticalSampleSourceKey.metricCorrelation =>
      _metricCorrelationSource(options),
    SimpleStatisticalSampleSourceKey.capabilityScatterMatrix =>
      _capabilityScatterMatrixSource(options),
    SimpleStatisticalSampleSourceKey.regionalTileMap => _regionalTileMapSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.usageDensity => _usageDensitySource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.usageHeatGrid => _usageHeatGridSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.serviceTerritories =>
      _serviceTerritoriesSource(options),
    SimpleStatisticalSampleSourceKey.performanceContours =>
      _performanceContoursSource(options),
    SimpleStatisticalSampleSourceKey.capabilityParallel =>
      _capabilityParallelSource(options),
    SimpleStatisticalSampleSourceKey.learningCalendar =>
      _learningCalendarSource(options),
    SimpleStatisticalSampleSourceKey.scoreDistribution =>
      _scoreDistributionSource(options),
    SimpleStatisticalSampleSourceKey.scoreBinnedDots => _scoreBinnedDotsSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.scoreFrequencyPolygon =>
      _scoreFrequencyPolygonSource(options),
    SimpleStatisticalSampleSourceKey.scoreDensity => _scoreDensitySource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.scoreRaincloud => _scoreRaincloudSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.responseEcdf => _responseEcdfSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.scoreQQPlot => _scoreQQPlotSource(options),
    SimpleStatisticalSampleSourceKey.concentrationLorenz =>
      _concentrationLorenzSource(options),
    SimpleStatisticalSampleSourceKey.measurementAgreement =>
      _measurementAgreementSource(options),
    SimpleStatisticalSampleSourceKey.scoreSpread => _scoreSpreadSource(options),
    SimpleStatisticalSampleSourceKey.scoreBoxenPlot => _scoreBoxenPlotSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.scoreShape => _scoreShapeSource(options),
    SimpleStatisticalSampleSourceKey.cohortRidgelines =>
      _cohortRidgelinesSource(options),
    SimpleStatisticalSampleSourceKey.scoreRugPlot => _scoreRugPlotSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.responseBarcodePlot =>
      _responseBarcodePlotSource(options),
    SimpleStatisticalSampleSourceKey.sampleStripPlot => _sampleStripPlotSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.sampleSinaPlot => _sampleSinaPlotSource(
      options,
    ),
    SimpleStatisticalSampleSourceKey.sampleBeeswarm => _sampleBeeswarmSource(
      options,
    ),
  };
}

SimpleChartSampleSource _activityHeatmapSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleHeatmapChart',
    title: 'Activity Heatmap',
    subtitle: 'Intensity by time and day',
    data: {
      'xLabels': SimpleChartsShowcaseData.activityDays,
      'yLabels': SimpleChartsShowcaseData.activitySegments,
      'cells': simpleHeatmapCellsJson(SimpleChartsShowcaseData.activityHeatmap),
    },
    options: _matrixOptionsJson(
      options,
      extra: {'showActiveCell': options.showActiveBars},
    ),
    dartCode:
        '''
SimpleHeatmapChart(
  xLabels: SimpleChartsShowcaseData.activityDays,
  yLabels: SimpleChartsShowcaseData.activitySegments,
  cells: SimpleChartsShowcaseData.activityHeatmap,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _activityPunchCardSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimplePunchCardChart',
    title: 'Activity Punch Card',
    subtitle: 'Dot intensity by time and day',
    data: {
      'xLabels': SimpleChartsShowcaseData.activityDays,
      'yLabels': SimpleChartsShowcaseData.activitySegments,
      'cells': simplePunchCardCellsJson(
        SimpleChartsShowcaseData.activityPunchCards,
      ),
      'minValue': 0,
      'maxValue': 100,
    },
    options: _matrixOptionsJson(
      options,
      extra: {
        'useColorScale': options.showReferenceBands,
        'showActiveDot': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimplePunchCardChart(
  xLabels: SimpleChartsShowcaseData.activityDays,
  yLabels: SimpleChartsShowcaseData.activitySegments,
  cells: SimpleChartsShowcaseData.activityPunchCards,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveDot: ${options.showActiveBars},
  useColorScale: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _activityRadialHeatmapSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleRadialHeatmapChart',
    title: 'Activity Radial Heatmap',
    subtitle: 'Cyclical intensity by ring and segment',
    data: {
      'ringLabels': SimpleChartsShowcaseData.activitySegments,
      'segmentLabels': SimpleChartsShowcaseData.activityDays,
      'cells': simpleRadialHeatmapCellsJson(
        SimpleChartsShowcaseData.activityRadialHeatmap,
      ),
    },
    options: _matrixOptionsJson(
      options,
      extra: {
        'showRingLabels': options.showValues,
        'showSegmentLabels': options.showReferenceLines,
        'showValues': options.showReferenceBands,
        'showCenterHole': options.showTracks,
        'innerRadiusFactor': options.showReferenceBands ? 0.28 : 0.2,
      },
    ),
    dartCode:
        '''
SimpleRadialHeatmapChart(
  ringLabels: SimpleChartsShowcaseData.activitySegments,
  segmentLabels: SimpleChartsShowcaseData.activityDays,
  cells: SimpleChartsShowcaseData.activityRadialHeatmap,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showRingLabels: ${options.showValues},
  showSegmentLabels: ${options.showReferenceLines},
  showValues: ${options.showReferenceBands},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
  showCenterHole: ${options.showTracks},
)''',
  );
}

SimpleChartSampleSource _metricCorrelationSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleCorrelationMatrixChart',
    title: 'Metric Correlation',
    subtitle: 'Pairwise relationship matrix',
    data: {
      'variables': SimpleChartsShowcaseData.capabilityCorrelationVariables,
      'correlations': simpleCorrelationCellsJson(
        SimpleChartsShowcaseData.capabilityCorrelations,
      ),
    },
    options: _matrixOptionsJson(
      options,
      extra: {
        'showDiagonal': options.showTracks,
        'showUpperTriangleOnly': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleCorrelationMatrixChart(
  variables: SimpleChartsShowcaseData.capabilityCorrelationVariables,
  correlations: SimpleChartsShowcaseData.capabilityCorrelations,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
  showDiagonal: ${options.showTracks},
  showUpperTriangleOnly: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _capabilityScatterMatrixSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleScatterPlotMatrixChart',
    title: 'Capability Scatter Matrix',
    subtitle: 'Pairwise numeric relationships',
    data: {
      'variableLabels': const ['Speed', 'Quality', 'Cost', 'Risk'],
      'points': simpleScatterMatrixPointsJson(
        SimpleChartsShowcaseData.capabilityScatterMatrix,
      ),
      'minValues': const [0, 0, 0, 0],
      'maxValues': const [100, 100, 100, 100],
    },
    options: {
      ..._axisOptionsJson(options),
      'showDiagonalHistograms': options.showReferenceBands,
      'showVariableLabels': true,
      'pointRadius': options.showReferenceBands ? 3.8 : 3.2,
    },
    dartCode:
        '''
SimpleScatterPlotMatrixChart(
  variableLabels: const ['Speed', 'Quality', 'Cost', 'Risk'],
  points: SimpleChartsShowcaseData.capabilityScatterMatrix,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValues: const [0, 0, 0, 0],
  maxValues: const [100, 100, 100, 100],
  showGrid: ${options.showGrid},
  showDiagonalHistograms: ${options.showReferenceBands},
  showVariableLabels: true,
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _regionalTileMapSource(
  SimpleChartsGalleryOptions options,
) {
  final shape = options.showReferenceBands
      ? SimpleTileMapShape.hexagon
      : SimpleTileMapShape.rounded;

  return _statisticalSampleSource(
    chartType: 'SimpleTileMapChart',
    title: 'Regional Tile Map',
    subtitle: 'Map-like comparison without polygons',
    data: {
      'data': simpleTileMapDataJson(SimpleChartsShowcaseData.regionalTileMap),
      'rows': 3,
      'columns': 4,
    },
    options: {
      ..._partOptionsJson(options),
      'shape': shape.name,
      'showLabels': true,
      'showActiveTile': options.showActiveBars,
      'showEmptyTiles': options.showTracks,
    },
    dartCode:
        '''
SimpleTileMapChart(
  data: SimpleChartsShowcaseData.regionalTileMap,
  style: SimpleBarChartStyle.${options.barStyle.name},
  rows: 3,
  columns: 4,
  shape: SimpleTileMapShape.${shape.name},
  showLabels: true,
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveTile: ${options.showActiveBars},
  showEmptyTiles: ${options.showTracks},
)''',
  );
}

SimpleChartSampleSource _usageDensitySource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleHexbinChart',
    title: 'Usage Density',
    subtitle: 'Dense observations binned by hex cells',
    data: {
      'points': simpleHexbinPointsJson(
        SimpleChartsShowcaseData.usageDensityPoints,
      ),
      ..._xyBoundsJson(),
      'xAxisLabel': 'Activity',
      'yAxisLabel': 'Outcome',
    },
    options: {
      ..._axisOptionsJson(options),
      'cellRadius': options.showReferenceBands ? 15 : 17,
      'showAxisLabels': options.showReferenceLines,
      'showEmptyBins': options.showTracks,
      'useLogScale': options.showReferenceBands,
      'showActiveBin': options.showActiveBars,
    },
    dartCode:
        '''
SimpleHexbinChart(
  points: SimpleChartsShowcaseData.usageDensityPoints,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xAxisLabel: 'Activity',
  yAxisLabel: 'Outcome',
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showAxisLabels: ${options.showReferenceLines},
  showEmptyBins: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveBin: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _usageHeatGridSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleContinuousHeatmapChart',
    title: 'Usage Heat Grid',
    subtitle: 'Continuous observations in rectangular bins',
    data: {
      'points': simpleContinuousHeatmapPointsJson(
        SimpleChartsShowcaseData.usageHeatmapPoints,
      ),
      ..._xyBoundsJson(),
      'xBins': options.showReferenceBands ? 7 : 6,
      'yBins': options.showReferenceBands ? 6 : 5,
    },
    options: _matrixOptionsJson(
      options,
      extra: {'showActiveCell': options.showActiveBars},
    ),
    dartCode:
        '''
SimpleContinuousHeatmapChart(
  points: SimpleChartsShowcaseData.usageHeatmapPoints,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xBins: ${options.showReferenceBands ? 7 : 6},
  yBins: ${options.showReferenceBands ? 6 : 5},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _serviceTerritoriesSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleVoronoiChart',
    title: 'Service Territories',
    subtitle: 'Nearest-site coverage regions',
    data: {
      'sites': simpleVoronoiSitesJson(
        SimpleChartsShowcaseData.serviceTerritories,
      ),
      ..._xyBoundsJson(),
      'xAxisLabel': 'Reach',
      'yAxisLabel': 'Demand',
    },
    options: {
      ..._axisOptionsJson(options),
      'showLabels': options.showValues,
      'showAxisLabels': options.showReferenceLines,
      'showBoundaries': options.showTracks,
      'regionOpacity': options.showReferenceBands ? 0.34 : 0.24,
    },
    dartCode:
        '''
SimpleVoronoiChart(
  sites: SimpleChartsShowcaseData.serviceTerritories,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xAxisLabel: 'Reach',
  yAxisLabel: 'Demand',
  showGrid: ${options.showGrid},
  showLabels: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _performanceContoursSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleContourChart',
    title: 'Performance Contours',
    subtitle: 'Interpolated surface and isolines',
    data: {
      'points': simpleContourPointsJson(
        SimpleChartsShowcaseData.performanceSurface,
      ),
      ..._xyBoundsJson(),
      'xAxisLabel': 'Reach',
      'yAxisLabel': 'Demand',
    },
    options: {
      ..._axisOptionsJson(options),
      'gridResolution': options.showReferenceBands ? 30 : 24,
      'levelCount': options.showReferenceLines ? 7 : 6,
      'showFilledBands': true,
      'showContourLines': options.showReferenceLines,
      'showSamplePoints': options.showTracks,
      'showLabels': options.showValues,
      'showValues': options.showReferenceBands,
      'showActiveSelection': options.showActiveBars,
    },
    dartCode:
        '''
SimpleContourChart(
  points: SimpleChartsShowcaseData.performanceSurface,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xAxisLabel: 'Reach',
  yAxisLabel: 'Demand',
  showGrid: ${options.showGrid},
  showContourLines: ${options.showReferenceLines},
  showSamplePoints: ${options.showTracks},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _capabilityParallelSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleParallelCoordinatesChart',
    title: 'Capability Parallel',
    subtitle: 'Multivariate profile comparison',
    data: {
      'axes': simpleParallelAxesJson(
        SimpleChartsShowcaseData.capabilityParallelAxes,
      ),
      'series': simpleParallelSeriesJson(
        SimpleChartsShowcaseData.capabilityParallel,
      ),
    },
    options: {
      ..._axisOptionsJson(options),
      'showLabels': true,
      'showAxisRangeLabels': options.showReferenceLines,
      'showActiveSeries': options.showActiveBars,
      'lineOpacity': options.showReferenceBands ? 0.5 : 0.36,
    },
    dartCode:
        '''
SimpleParallelCoordinatesChart(
  axes: SimpleChartsShowcaseData.capabilityParallelAxes,
  series: SimpleChartsShowcaseData.capabilityParallel,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showLabels: true,
  showValues: ${options.showValues},
  showAxisRangeLabels: ${options.showReferenceLines},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveSeries: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _learningCalendarSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleCalendarHeatmapChart',
    title: 'Learning Calendar',
    subtitle: 'Daily intensity across a quarter',
    data: {
      'data': simpleCalendarHeatmapDataJson(
        SimpleChartsShowcaseData.learningCalendar,
      ),
      'startDate': simpleDateJson(DateTime(2026, 1)),
      'endDate': simpleDateJson(DateTime(2026, 3, 31)),
    },
    options: {
      'style': options.barStyle.name,
      'showMonthLabels': true,
      'showWeekdayLabels': options.showReferenceLines,
      'showValues': false,
      'showLegend': options.showLegends,
      'showTooltip': options.showTooltips,
      'showActiveDay': options.showActiveBars,
    },
    dartCode:
        '''
SimpleCalendarHeatmapChart(
  data: SimpleChartsShowcaseData.learningCalendar,
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 3, 31),
  style: SimpleBarChartStyle.${options.barStyle.name},
  showMonthLabels: true,
  showWeekdayLabels: ${options.showReferenceLines},
  showValues: false,
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveDay: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _scoreDistributionSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleHistogramChart',
    title: 'Score Distribution',
    subtitle: 'Frequency buckets and spread',
    data: {'values': SimpleChartsShowcaseData.scoreDistribution, 'binCount': 8},
    options: _distributionOptionsJson(
      options,
      extra: {
        'showAxisLabels': true,
        'showMean': options.showReferenceLines,
        'showMedian': options.showReferenceLines,
        'showDistributionCurve': options.showReferenceBands,
        'showActiveBin': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleHistogramChart(
  values: SimpleChartsShowcaseData.scoreDistribution,
  binCount: 8,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMean: ${options.showReferenceLines},
  showMedian: ${options.showReferenceLines},
  showDistributionCurve: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveBin: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _scoreBinnedDotsSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleBinnedDotPlotChart',
    title: 'Score Binned Dots',
    subtitle: 'Distribution as stacked observations',
    data: {
      'values': SimpleChartsShowcaseData.scoreDistribution,
      'binCount': 8,
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showAxisLabels': true,
        'showActiveBin': options.showActiveBars,
        'dotValue': options.showReferenceBands ? 1 : 2,
      },
    ),
    dartCode:
        '''
SimpleBinnedDotPlotChart(
  values: SimpleChartsShowcaseData.scoreDistribution,
  binCount: 8,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showAxisLabels: true,
  showTooltip: ${options.showTooltips},
  showActiveBin: ${options.showActiveBars},
  dotValue: ${options.showReferenceBands ? 1 : 2},
)''',
  );
}

SimpleChartSampleSource _scoreFrequencyPolygonSource(
  SimpleChartsGalleryOptions options,
) {
  final scale = options.showReferenceBands
      ? SimpleFrequencyPolygonScale.percent
      : SimpleFrequencyPolygonScale.count;

  return _statisticalSampleSource(
    chartType: 'SimpleFrequencyPolygonChart',
    title: 'Score Frequency Polygon',
    subtitle: 'Connected frequency buckets',
    data: {
      'values': SimpleChartsShowcaseData.scoreDistribution,
      'binCount': 8,
      ..._valueBoundsJson(),
      'minFrequency': 0,
    },
    options: _trendDistributionOptionsJson(
      options,
      extra: {
        'scale': scale.name,
        'showDots': options.showTracks,
        'showArea': options.showReferenceBands,
        'referenceLineCount': options.showReferenceLines ? 1 : 0,
      },
    ),
    dartCode:
        '''
SimpleFrequencyPolygonChart(
  values: SimpleChartsShowcaseData.scoreDistribution,
  binCount: 8,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 100,
  minFrequency: 0,
  scale: SimpleFrequencyPolygonScale.${scale.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDots: ${options.showTracks},
  showArea: ${options.showReferenceBands},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _scoreDensitySource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleDensityChart',
    title: 'Score Density',
    subtitle: 'Smoothed distribution comparison',
    data: {
      'series': simpleDensitySeriesJson(SimpleChartsShowcaseData.scoreDensity),
      ..._valueBoundsJson(),
    },
    options: _trendDistributionOptionsJson(
      options,
      extra: {
        'showArea': options.showReferenceBands,
        'showRug': options.showTracks,
        'showActiveSeries': options.showActiveBars,
        'showMean': options.showReferenceLines,
        'showMedian': options.showReferenceLines,
      },
    ),
    dartCode:
        '''
SimpleDensityChart(
  series: SimpleChartsShowcaseData.scoreDensity,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showArea: ${options.showReferenceBands},
  showRug: ${options.showTracks},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveSeries: ${options.showActiveBars},
  showMean: ${options.showReferenceLines},
  showMedian: ${options.showReferenceLines},
)''',
  );
}

SimpleChartSampleSource _scoreRaincloudSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleRaincloudChart',
    title: 'Score Raincloud',
    subtitle: 'Density, box summary, and samples',
    data: {
      'data': simpleRaincloudDataJson(SimpleChartsShowcaseData.scoreRaincloud),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showCloud': options.showReferenceBands,
        'showBox': options.showTracks,
        'showDots': options.showTracks,
        'showMean': options.showReferenceLines,
        'showOutliers': options.showReferenceBands,
        'showActiveGroup': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleRaincloudChart(
  data: SimpleChartsShowcaseData.scoreRaincloud,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showCloud: ${options.showReferenceBands},
  showBox: ${options.showTracks},
  showDots: ${options.showTracks},
  showMean: ${options.showReferenceLines},
  showOutliers: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveGroup: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _responseEcdfSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleEcdfChart',
    title: 'Response ECDF',
    subtitle: 'Cumulative share under threshold',
    data: {
      'series': simpleEcdfSeriesJson(SimpleChartsShowcaseData.responseEcdf),
      'minValue': 0,
      'maxValue': 120,
    },
    options: _trendDistributionOptionsJson(
      options,
      extra: {
        'showDots': options.showTracks,
        'showArea': options.showReferenceBands,
        'showActivePoint': options.showActiveBars,
        'showMedianLine': options.showReferenceLines,
        'showP90Line': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleEcdfChart(
  series: SimpleChartsShowcaseData.responseEcdf,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 120,
  showGrid: ${options.showGrid},
  showDots: ${options.showTracks},
  showValues: ${options.showValues},
  showArea: ${options.showReferenceBands},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  showMedianLine: ${options.showReferenceLines},
  showP90Line: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _scoreQQPlotSource(SimpleChartsGalleryOptions options) {
  return _statisticalSampleSource(
    chartType: 'SimpleQQPlotChart',
    title: 'Score QQ Plot',
    subtitle: 'Quantile comparison against baseline',
    data: {
      'series': simpleQQPlotSeriesJson(SimpleChartsShowcaseData.scoreQQPlot),
      'minX': 30,
      'maxX': 100,
      'minY': 30,
      'maxY': 100,
      'xAxisLabel': 'Control quantile',
      'yAxisLabel': 'Program quantile',
    },
    options: {
      ..._axisOptionsJson(options),
      'showActivePoint': options.showActiveBars,
      'showReferenceLine': options.showReferenceLines,
      'showFitLine': options.showReferenceBands,
      'showAxisLabels': true,
    },
    dartCode:
        '''
SimpleQQPlotChart(
  series: SimpleChartsShowcaseData.scoreQQPlot,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 30,
  maxX: 100,
  minY: 30,
  maxY: 100,
  xAxisLabel: 'Control quantile',
  yAxisLabel: 'Program quantile',
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  showReferenceLine: ${options.showReferenceLines},
  showFitLine: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _concentrationLorenzSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleLorenzCurveChart',
    title: 'Concentration Lorenz',
    subtitle: 'Cumulative share and Gini balance',
    data: {
      'series': simpleLorenzSeriesJson(
        SimpleChartsShowcaseData.concentrationLorenz,
      ),
    },
    options: {
      ..._axisOptionsJson(options),
      'showActivePoint': options.showActiveBars,
      'showEqualityLine': options.showReferenceLines,
      'showArea': options.showReferenceBands,
      'showGini': options.showReferenceLines,
      'showAxisLabels': true,
    },
    dartCode:
        '''
SimpleLorenzCurveChart(
  series: SimpleChartsShowcaseData.concentrationLorenz,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  showEqualityLine: ${options.showReferenceLines},
  showArea: ${options.showReferenceBands},
  showGini: ${options.showReferenceLines},
)''',
  );
}

SimpleChartSampleSource _measurementAgreementSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleBlandAltmanChart',
    title: 'Measurement Agreement',
    subtitle: 'Bias and limits between two methods',
    data: {
      'points': simpleBlandAltmanPointsJson(
        SimpleChartsShowcaseData.measurementAgreement,
      ),
      'minMean': 60,
      'maxMean': 95,
      'minDifference': -4,
      'maxDifference': 6,
      'methodALabel': 'Baseline',
      'methodBLabel': 'Review',
    },
    options: {
      ..._axisOptionsJson(options),
      'showActivePoint': options.showActiveBars,
      'showBiasLine': options.showReferenceLines,
      'showAgreementLimits': options.showReferenceLines,
      'showAgreementBand': options.showReferenceBands,
      'showZeroLine': options.showTracks,
      'highlightOutliers': options.showReferenceBands,
    },
    dartCode:
        '''
SimpleBlandAltmanChart(
  points: SimpleChartsShowcaseData.measurementAgreement,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minMean: 60,
  maxMean: 95,
  minDifference: -4,
  maxDifference: 6,
  methodALabel: 'Baseline',
  methodBLabel: 'Review',
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  showBiasLine: ${options.showReferenceLines},
  showAgreementLimits: ${options.showReferenceLines},
  showAgreementBand: ${options.showReferenceBands},
  showZeroLine: ${options.showTracks},
  highlightOutliers: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _scoreSpreadSource(SimpleChartsGalleryOptions options) {
  return _statisticalSampleSource(
    chartType: 'SimpleBoxPlotChart',
    title: 'Score Spread',
    subtitle: 'Median, quartiles, and outliers',
    data: {
      'data': simpleBoxPlotDataJson(SimpleChartsShowcaseData.scoreSpread),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showMean': options.showReferenceLines,
        'showOutliers': options.showReferenceBands,
        'showActiveBox': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleBoxPlotChart(
  data: SimpleChartsShowcaseData.scoreSpread,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMean: ${options.showReferenceLines},
  showOutliers: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveBox: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _scoreBoxenPlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleBoxenPlotChart',
    title: 'Score Boxen Plot',
    subtitle: 'Nested quantile bands and tails',
    data: {
      'data': simpleBoxenPlotDataJson(SimpleChartsShowcaseData.scoreBoxen),
      ..._valueBoundsJson(),
      'maxDepth': options.showReferenceBands ? 4 : 3,
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showMedian': true,
        'showWhiskers': options.showTracks,
        'showActiveBox': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleBoxenPlotChart(
  data: SimpleChartsShowcaseData.scoreBoxen,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  maxDepth: ${options.showReferenceBands ? 4 : 3},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMedian: true,
  showWhiskers: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveBox: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _scoreShapeSource(SimpleChartsGalleryOptions options) {
  return _statisticalSampleSource(
    chartType: 'SimpleViolinChart',
    title: 'Score Shape',
    subtitle: 'Distribution density by cohort',
    data: {
      'data': simpleViolinDataJson(SimpleChartsShowcaseData.scoreShape),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showBoxPlot': options.showTracks,
        'showMean': options.showReferenceLines,
        'showOutliers': options.showReferenceBands,
        'showActiveViolin': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleViolinChart(
  data: SimpleChartsShowcaseData.scoreShape,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showBoxPlot: ${options.showTracks},
  showMean: ${options.showReferenceLines},
  showOutliers: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveViolin: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _cohortRidgelinesSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleRidgelineChart',
    title: 'Cohort Ridgelines',
    subtitle: 'Stacked distribution shape',
    data: {
      'data': simpleRidgelineDataJson(SimpleChartsShowcaseData.cohortRidges),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showBaseline': options.showTracks,
        'showMedian': options.showReferenceLines,
        'showMean': options.showReferenceBands,
        'showActiveRidge': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleRidgelineChart(
  data: SimpleChartsShowcaseData.cohortRidges,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showBaseline: ${options.showTracks},
  showMedian: ${options.showReferenceLines},
  showMean: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveRidge: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _scoreRugPlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleRugPlotChart',
    title: 'Score Rug Plot',
    subtitle: 'Raw observations along an axis',
    data: {
      'series': simpleRugPlotSeriesJson(SimpleChartsShowcaseData.scoreRugs),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showLabels': true,
        'showBaseline': options.showTracks,
        'showMedian': options.showReferenceLines,
        'showActiveTick': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleRugPlotChart(
  series: SimpleChartsShowcaseData.scoreRugs,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLabels: true,
  showLegend: ${options.showLegends},
  showBaseline: ${options.showTracks},
  showMedian: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveTick: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _responseBarcodePlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleBarcodePlotChart',
    title: 'Response Barcode Plot',
    subtitle: 'Event density along a scale',
    data: {
      'series': simpleBarcodePlotSeriesJson(
        SimpleChartsShowcaseData.responseBarcode,
      ),
      'minValue': 0,
      'maxValue': 120,
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showLabels': true,
        'showBaseline': options.showTracks,
        'showMedian': options.showReferenceLines,
        'showActiveTick': options.showActiveBars,
        'tickLength': options.showReferenceBands ? 30 : 24,
      },
    ),
    dartCode:
        '''
SimpleBarcodePlotChart(
  series: SimpleChartsShowcaseData.responseBarcode,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 120,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLabels: true,
  showLegend: ${options.showLegends},
  showBaseline: ${options.showTracks},
  showMedian: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveTick: ${options.showActiveBars},
  tickLength: ${options.showReferenceBands ? 30 : 24},
)''',
  );
}

SimpleChartSampleSource _sampleStripPlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleStripPlotChart',
    title: 'Sample Strip Plot',
    subtitle: 'Every observation by cohort',
    data: {
      'data': simpleStripPlotDataJson(SimpleChartsShowcaseData.sampleStrips),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showLabels': true,
        'showMean': options.showReferenceLines,
        'showMedian': options.showReferenceBands,
        'showActiveDot': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleStripPlotChart(
  data: SimpleChartsShowcaseData.sampleStrips,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMean: ${options.showReferenceLines},
  showMedian: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveDot: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _sampleSinaPlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleSinaPlotChart',
    title: 'Sample Sina Plot',
    subtitle: 'Density-shaped observations',
    data: {
      'data': simpleSinaPlotDataJson(SimpleChartsShowcaseData.sampleSina),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showLabels': true,
        'showMean': options.showReferenceLines,
        'showMedian': options.showReferenceBands,
        'showActiveDot': options.showActiveBars,
        'densitySpreadFactor': options.showReferenceBands ? 0.88 : 0.72,
      },
    ),
    dartCode:
        '''
SimpleSinaPlotChart(
  data: SimpleChartsShowcaseData.sampleSina,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMean: ${options.showReferenceLines},
  showMedian: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveDot: ${options.showActiveBars},
  densitySpreadFactor: ${options.showReferenceBands ? 0.88 : 0.72},
)''',
  );
}

SimpleChartSampleSource _sampleBeeswarmSource(
  SimpleChartsGalleryOptions options,
) {
  return _statisticalSampleSource(
    chartType: 'SimpleBeeswarmChart',
    title: 'Sample Beeswarm',
    subtitle: 'Packed observations without overlap',
    data: {
      'data': simpleBeeswarmDataJson(SimpleChartsShowcaseData.sampleBeeswarm),
      ..._valueBoundsJson(),
    },
    options: _distributionOptionsJson(
      options,
      extra: {
        'showLabels': true,
        'showMean': options.showReferenceLines,
        'showMedian': options.showReferenceBands,
        'showActiveDot': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleBeeswarmChart(
  data: SimpleChartsShowcaseData.sampleBeeswarm,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showMean: ${options.showReferenceLines},
  showMedian: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveDot: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _statisticalSampleSource({
  required String chartType,
  required String title,
  required String subtitle,
  required Map<String, dynamic> data,
  required Map<String, dynamic> options,
  required String dartCode,
}) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: chartType,
      title: title,
      subtitle: subtitle,
      data: data,
      options: options,
    ),
    dartCode: dartCode,
  );
}

Map<String, dynamic> _matrixOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    ...extra,
  };
}

Map<String, dynamic> _axisOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    'showTracks': options.showTracks,
    'showActive': options.showActiveBars,
  };
}

Map<String, dynamic> _partOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showTracks': options.showTracks,
    'showReferenceBands': options.showReferenceBands,
  };
}

Map<String, dynamic> _distributionOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {..._axisOptionsJson(options), ...extra};
}

Map<String, dynamic> _trendDistributionOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.trendStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    'showTracks': options.showTracks,
    'showActive': options.showActiveBars,
    ...extra,
  };
}

Map<String, dynamic> _xyBoundsJson() {
  return const {'minX': 0, 'maxX': 100, 'minY': 0, 'maxY': 100};
}

Map<String, dynamic> _valueBoundsJson() {
  return const {'minValue': 0, 'maxValue': 100};
}
