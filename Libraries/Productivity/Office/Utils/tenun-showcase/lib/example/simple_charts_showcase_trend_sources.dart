import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleTrendSampleSourceKey {
  revenueTrend,
  regionalSmallMultiples,
  seasonalCyclePlot,
  capacitySteps,
  revenueFan,
  seasonalSpiral,
  marketCandles,
  productTrajectory,
  processControl,
  productAdoption,
  retentionCohorts,
  healthHorizon,
  channelStream,
}

SimpleChartSampleSource? simpleTrendSampleSource(
  SimpleTrendSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleTrendSampleSourceKey.revenueTrend => _revenueTrendSource(options),
    SimpleTrendSampleSourceKey.regionalSmallMultiples =>
      _regionalSmallMultiplesSource(options),
    SimpleTrendSampleSourceKey.seasonalCyclePlot => _seasonalCyclePlotSource(
      options,
    ),
    SimpleTrendSampleSourceKey.capacitySteps => _capacityStepsSource(options),
    SimpleTrendSampleSourceKey.revenueFan => _revenueFanSource(options),
    SimpleTrendSampleSourceKey.seasonalSpiral => _seasonalSpiralSource(options),
    SimpleTrendSampleSourceKey.marketCandles => _marketCandlesSource(options),
    SimpleTrendSampleSourceKey.productTrajectory => _productTrajectorySource(
      options,
    ),
    SimpleTrendSampleSourceKey.processControl => _processControlSource(options),
    SimpleTrendSampleSourceKey.productAdoption => _productAdoptionSource(
      options,
    ),
    SimpleTrendSampleSourceKey.retentionCohorts => _retentionCohortsSource(
      options,
    ),
    SimpleTrendSampleSourceKey.healthHorizon => _healthHorizonSource(options),
    SimpleTrendSampleSourceKey.channelStream => _channelStreamSource(options),
  };
}

SimpleChartSampleSource _revenueTrendSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleLineChart',
    title: 'Revenue Trend',
    subtitle: 'Actual vs target',
    data: {
      'series': simpleTrendSeriesJson(SimpleChartsShowcaseData.revenueTrend),
    },
    options: _trendOptionsJson(options, extra: {'showDots': true}),
    dartCode:
        '''
SimpleLineChart(
  series: SimpleChartsShowcaseData.revenueTrend,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDots: true,
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _regionalSmallMultiplesSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleSmallMultiplesChart',
    title: 'Regional Small Multiples',
    subtitle: 'Repeated mini trends on one scale',
    data: {
      'panels': simpleSmallMultiplePanelsJson(
        SimpleChartsShowcaseData.regionalSmallMultiples,
      ),
      'minValue': 0,
      'maxValue': 80,
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'columns': options.showReferenceBands ? 2 : null,
        'showArea': options.showReferenceBands,
        'showPanelDividers': options.showTracks,
      },
    ),
    dartCode:
        '''
SimpleSmallMultiplesChart(
  panels: SimpleChartsShowcaseData.regionalSmallMultiples,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 80,
  columns: ${options.showReferenceBands ? '2' : 'null'},
  showGrid: ${options.showGrid},
  showDots: ${options.showTracks},
  showValues: ${options.showValues},
  showArea: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _seasonalCyclePlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleCyclePlotChart',
    title: 'Seasonal Cycle Plot',
    subtitle: 'Repeated periods across cycles',
    data: {
      'points': simpleCyclePlotPointsJson(
        SimpleChartsShowcaseData.seasonalCyclePlot,
      ),
      'periodLabels': SimpleChartsShowcaseData.seasonalPeriods,
      'cycleLabels': SimpleChartsShowcaseData.seasonalCycles,
      'minValue': 0,
      'maxValue': 100,
    },
    options: _trendOptionsJson(
      options,
      extra: {'showAverageLine': options.showReferenceLines},
    ),
    dartCode:
        '''
SimpleCyclePlotChart(
  points: SimpleChartsShowcaseData.seasonalCyclePlot,
  periodLabels: SimpleChartsShowcaseData.seasonalPeriods,
  cycleLabels: SimpleChartsShowcaseData.seasonalCycles,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showDots: ${options.showTracks},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _capacityStepsSource(
  SimpleChartsGalleryOptions options,
) {
  final mode = options.showReferenceBands
      ? SimpleStepChartMode.middle
      : SimpleStepChartMode.after;

  return _trendSampleSource(
    chartType: 'SimpleStepChart',
    title: 'Capacity Steps',
    subtitle: 'Held values and scheduled changes',
    data: {
      'series': simpleTrendSeriesJson(SimpleChartsShowcaseData.capacitySteps),
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'mode': mode.name,
        'showArea': options.showReferenceBands,
        'showActiveStep': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleStepChart(
  series: SimpleChartsShowcaseData.capacitySteps,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  mode: SimpleStepChartMode.${mode.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDots: ${options.showTracks},
  showArea: ${options.showReferenceBands},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveStep: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _revenueFanSource(SimpleChartsGalleryOptions options) {
  return _trendSampleSource(
    chartType: 'SimpleFanChart',
    title: 'Revenue Fan',
    subtitle: 'Forecast with uncertainty bands',
    data: {
      'points': simpleFanChartPointsJson(
        SimpleChartsShowcaseData.revenueForecastFan,
      ),
      'valueLabel': 'Revenue',
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showBands': options.showReferenceBands,
        'showLine': true,
        'showActivePoint': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleFanChart(
  points: SimpleChartsShowcaseData.revenueForecastFan,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  valueLabel: 'Revenue',
  showGrid: ${options.showGrid},
  showBands: ${options.showReferenceBands},
  showLine: true,
  showDots: ${options.showTracks},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _seasonalSpiralSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleSpiralChart',
    title: 'Seasonal Spiral',
    subtitle: 'Cyclical demand path',
    data: {
      'points': simpleSpiralChartPointsJson(
        SimpleChartsShowcaseData.seasonalDemandSpiral,
      ),
      'centerLabel': 'Demand',
      'cycleLength': 12,
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showLine': true,
        'showLabels': options.showValues,
        'showValues': options.showReferenceBands,
        'showCycleGuides': options.showReferenceLines,
        'showActivePoint': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleSpiralChart(
  points: SimpleChartsShowcaseData.seasonalDemandSpiral,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  centerLabel: 'Demand',
  cycleLength: 12,
  showGrid: ${options.showGrid},
  showLine: true,
  showDots: ${options.showTracks},
  showLabels: ${options.showValues},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _marketCandlesSource(
  SimpleChartsGalleryOptions options,
) {
  final mode = options.showReferenceBands
      ? SimpleCandlestickChartMode.ohlc
      : SimpleCandlestickChartMode.candlestick;

  return _trendSampleSource(
    chartType: 'SimpleCandlestickChart',
    title: 'Market Candles',
    subtitle: 'Open, high, low, close with volume',
    data: {
      'data': simpleCandlestickDataJson(SimpleChartsShowcaseData.marketCandles),
    },
    options: {
      'style': options.barStyle.name,
      'mode': mode.name,
      'showGrid': options.showGrid,
      'showValues': options.showValues,
      'showVolume': options.showTracks,
      'showTooltip': options.showTooltips,
      'showActiveCandle': options.showActiveBars,
    },
    dartCode:
        '''
SimpleCandlestickChart(
  data: SimpleChartsShowcaseData.marketCandles,
  style: SimpleBarChartStyle.${options.barStyle.name},
  mode: SimpleCandlestickChartMode.${mode.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showVolume: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveCandle: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _productTrajectorySource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleConnectedScatterChart',
    title: 'Product Trajectory',
    subtitle: 'Movement through two business metrics',
    data: {
      'series': simpleConnectedScatterSeriesJson(
        SimpleChartsShowcaseData.productTrajectory,
      ),
      'minX': 0,
      'maxX': 100,
      'minY': 0,
      'maxY': 100,
      'xAxisLabel': 'Reach',
      'yAxisLabel': 'Quality',
    },
    options: {
      'style': options.barStyle.name,
      'showGrid': options.showGrid,
      'showLabels': options.showValues,
      'showValues': options.showReferenceBands,
      'showLegend': options.showLegends,
      'showTooltip': options.showTooltips,
      'showActivePoint': options.showActiveBars,
      'showArrows': options.showReferenceLines,
      'showEndpointLabels': !options.showReferenceBands,
    },
    dartCode:
        '''
SimpleConnectedScatterChart(
  series: SimpleChartsShowcaseData.productTrajectory,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xAxisLabel: 'Reach',
  yAxisLabel: 'Quality',
  showGrid: ${options.showGrid},
  showLabels: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _processControlSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleControlChart',
    title: 'Process Control',
    subtitle: 'Mean, limits, and stability signals',
    data: {
      'points': simpleControlChartPointsJson(
        SimpleChartsShowcaseData.processControl,
      ),
      'minValue': 76,
      'maxValue': 98,
      'centerValue': 87,
      'lowerControlLimit': 80,
      'upperControlLimit': 94,
      'lowerWarningLimit': 83,
      'upperWarningLimit': 91,
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showCenterLine': options.showReferenceLines,
        'showControlLimits': options.showReferenceLines,
        'showWarningBand': options.showReferenceBands,
        'showActivePoint': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleControlChart(
  points: SimpleChartsShowcaseData.processControl,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 76,
  maxValue: 98,
  centerValue: 87,
  lowerControlLimit: 80,
  upperControlLimit: 94,
  lowerWarningLimit: 83,
  upperWarningLimit: 91,
  showGrid: ${options.showGrid},
  showDots: ${options.showTracks},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _productAdoptionSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleAreaChart',
    title: 'Product Adoption',
    subtitle: 'Activation and retention',
    data: {
      'series': simpleTrendSeriesJson(SimpleChartsShowcaseData.productAdoption),
      'fillOpacity': 0.24,
    },
    options: _trendOptionsJson(options, extra: {'showDots': true}),
    dartCode:
        '''
SimpleAreaChart(
  series: SimpleChartsShowcaseData.productAdoption,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDots: true,
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  fillOpacity: 0.24,
)''',
  );
}

SimpleChartSampleSource _retentionCohortsSource(
  SimpleChartsGalleryOptions options,
) {
  return _trendSampleSource(
    chartType: 'SimpleCohortRetentionChart',
    title: 'Retention Cohorts',
    subtitle: 'Period-by-period cohort decay',
    data: {
      'rows': simpleCohortRowsJson(SimpleChartsShowcaseData.retentionCohorts),
      'periodLabels': SimpleChartsShowcaseData.retentionPeriods,
      'minValue': 0,
      'maxValue': 1,
    },
    options: {
      'style': options.barStyle.name,
      'showGrid': options.showGrid,
      'showValues': options.showValues,
      'showLegend': options.showLegends,
      'showCohortSize': options.showReferenceLines,
      'showEmptyCells': options.showReferenceBands,
      'showTooltip': options.showTooltips,
      'showActiveCell': options.showActiveBars,
    },
    dartCode:
        '''
SimpleCohortRetentionChart(
  rows: SimpleChartsShowcaseData.retentionCohorts,
  periodLabels: SimpleChartsShowcaseData.retentionPeriods,
  minValue: 0,
  maxValue: 1,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _healthHorizonSource(
  SimpleChartsGalleryOptions options,
) {
  final bandCount = options.showReferenceLines ? 3 : 2;

  return _trendSampleSource(
    chartType: 'SimpleHorizonChart',
    title: 'Health Horizon',
    subtitle: 'Compact positive and negative signals',
    data: {
      'series': simpleTrendSeriesJson(SimpleChartsShowcaseData.healthHorizon),
      'bandCount': bandCount,
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showLabels': options.showValues,
        'showActivePoint': options.showActiveBars,
        'smooth': options.showReferenceBands,
        'bandCount': bandCount,
      },
    ),
    dartCode:
        '''
SimpleHorizonChart(
  series: SimpleChartsShowcaseData.healthHorizon,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  showGrid: ${options.showGrid},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  smooth: ${options.showReferenceBands},
  bandCount: $bandCount,
)''',
  );
}

SimpleChartSampleSource _channelStreamSource(
  SimpleChartsGalleryOptions options,
) {
  final mode = options.stackAsPercent
      ? SimpleStreamgraphMode.percent
      : SimpleStreamgraphMode.absolute;

  return _trendSampleSource(
    chartType: 'SimpleStreamgraphChart',
    title: 'Channel Stream',
    subtitle: 'Composition shift over time',
    data: {
      'series': simpleTrendSeriesJson(SimpleChartsShowcaseData.channelStream),
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'mode': mode.name,
        'showLabels': options.showValues,
        'showActiveLayer': options.showActiveBars,
        'smooth': options.showReferenceBands,
      },
    ),
    dartCode:
        '''
SimpleStreamgraphChart(
  series: SimpleChartsShowcaseData.channelStream,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  mode: SimpleStreamgraphMode.${mode.name},
  showGrid: ${options.showGrid},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  smooth: ${options.showReferenceBands},
)''',
  );
}

SimpleChartSampleSource _trendSampleSource({
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

Map<String, dynamic> _trendOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.trendStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showDots': options.showTracks,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    ...extra,
  };
}
