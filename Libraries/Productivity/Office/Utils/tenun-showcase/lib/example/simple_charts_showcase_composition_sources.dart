import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleCompositionSampleSourceKey {
  portfolioShare,
  readinessDotDensity,
  packedPortfolio,
  strategyTernary,
  voiceThemes,
  audienceOverlap,
  audienceUpset,
  portfolioTreemap,
  portfolioSunburst,
  portfolioIcicle,
  portfolioTree,
  readinessIcons,
  marketMosaic,
  channelMosaicPlot,
}

SimpleChartSampleSource? simpleCompositionSampleSource(
  SimpleCompositionSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleCompositionSampleSourceKey.portfolioShare => _portfolioShareSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.readinessDotDensity =>
      _readinessDotDensitySource(options),
    SimpleCompositionSampleSourceKey.packedPortfolio => _packedPortfolioSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.strategyTernary => _strategyTernarySource(
      options,
    ),
    SimpleCompositionSampleSourceKey.voiceThemes => _voiceThemesSource(options),
    SimpleCompositionSampleSourceKey.audienceOverlap => _audienceOverlapSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.audienceUpset => _audienceUpsetSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.portfolioTreemap =>
      _portfolioTreemapSource(options),
    SimpleCompositionSampleSourceKey.portfolioSunburst =>
      _portfolioSunburstSource(options),
    SimpleCompositionSampleSourceKey.portfolioIcicle => _portfolioIcicleSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.portfolioTree => _portfolioTreeSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.readinessIcons => _readinessIconsSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.marketMosaic => _marketMosaicSource(
      options,
    ),
    SimpleCompositionSampleSourceKey.channelMosaicPlot =>
      _channelMosaicPlotSource(options),
  };
}

SimpleChartSampleSource _portfolioShareSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleWaffleChart',
    title: 'Portfolio Share',
    subtitle: 'Countable part-to-whole composition',
    data: {
      'data': simpleWaffleDataJson(SimpleChartsShowcaseData.portfolioShare),
    },
    options: {
      ..._unitOptionsJson(options),
      'showActiveCells': options.showActiveBars,
      'showEmptyCells': options.showTracks,
    },
    dartCode:
        '''
SimpleWaffleChart(
  data: SimpleChartsShowcaseData.portfolioShare,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLegend: ${options.showLegends},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveCells: ${options.showActiveBars},
  showEmptyCells: ${options.showTracks},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _readinessDotDensitySource(
  SimpleChartsGalleryOptions options,
) {
  final fillDirection = options.showReferenceBands
      ? SimpleDotDensityFillDirection.leftToRight
      : SimpleDotDensityFillDirection.bottomToTop;

  return _compositionSampleSource(
    chartType: 'SimpleDotDensityChart',
    title: 'Readiness Dot Density',
    subtitle: 'Unit dots for countable status mix',
    data: {
      'data': simpleDotDensityDataJson(SimpleChartsShowcaseData.readinessDots),
      'totalValue': 100,
      'rows': 5,
      'columns': 10,
    },
    options: {
      ..._unitOptionsJson(options),
      'fillDirection': fillDirection.name,
      'showActiveDots': options.showActiveBars,
      'showEmptyDots': options.showTracks,
    },
    dartCode:
        '''
SimpleDotDensityChart(
  data: SimpleChartsShowcaseData.readinessDots,
  totalValue: 100,
  rows: 5,
  columns: 10,
  style: SimpleBarChartStyle.${options.barStyle.name},
  fillDirection: SimpleDotDensityFillDirection.${fillDirection.name},
  showLegend: ${options.showLegends},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveDots: ${options.showActiveBars},
  showEmptyDots: ${options.showTracks},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _packedPortfolioSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimplePackedBubbleChart',
    title: 'Packed Portfolio',
    subtitle: 'Part-to-whole magnitude clusters',
    data: {
      'data': simplePackedBubbleDataJson(
        SimpleChartsShowcaseData.portfolioPackedBubbles,
      ),
    },
    options: {
      ..._partOptionsJson(options),
      'showLabels': options.showValues,
      'showActiveBubble': options.showActiveBars,
    },
    dartCode:
        '''
SimplePackedBubbleChart(
  data: SimpleChartsShowcaseData.portfolioPackedBubbles,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLegend: ${options.showLegends},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveBubble: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _strategyTernarySource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleTernaryChart',
    title: 'Strategy Ternary',
    subtitle: 'Three-way balance and tradeoff map',
    data: {
      'points': simpleTernaryPointsJson(
        SimpleChartsShowcaseData.strategyTernary,
      ),
      'aAxisLabel': 'Speed',
      'bAxisLabel': 'Quality',
      'cAxisLabel': 'Cost',
    },
    options: {
      ..._axisOptionsJson(options),
      'showPointLabels': options.showValues,
      'showValues': options.showReferenceLines,
      'gridLineCount': options.showReferenceBands ? 5 : 4,
    },
    dartCode:
        '''
SimpleTernaryChart(
  points: SimpleChartsShowcaseData.strategyTernary,
  style: SimpleBarChartStyle.${options.barStyle.name},
  aAxisLabel: 'Speed',
  bAxisLabel: 'Quality',
  cAxisLabel: 'Cost',
  showGrid: ${options.showGrid},
  showPointLabels: ${options.showValues},
  showValues: ${options.showReferenceLines},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  gridLineCount: ${options.showReferenceBands ? 5 : 4},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _voiceThemesSource(SimpleChartsGalleryOptions options) {
  final shape = options.showReferenceBands
      ? SimpleWordCloudShape.oval
      : SimpleWordCloudShape.cloud;
  final maxWords = options.showReferenceLines ? 12 : 10;

  return _compositionSampleSource(
    chartType: 'SimpleWordCloudChart',
    title: 'Voice Themes',
    subtitle: 'Qualitative signal frequency',
    data: {
      'words': simpleWordCloudDataJson(SimpleChartsShowcaseData.voiceThemes),
    },
    options: {
      'style': options.barStyle.name,
      'shape': shape.name,
      'showValues': options.showValues,
      'showLegend': options.showLegends,
      'showTooltip': options.showTooltips,
      'showActiveWord': options.showActiveBars,
      'allowRotation': options.showTracks,
      'maxWords': maxWords,
    },
    dartCode:
        '''
SimpleWordCloudChart(
  words: SimpleChartsShowcaseData.voiceThemes,
  style: SimpleBarChartStyle.${options.barStyle.name},
  shape: SimpleWordCloudShape.${shape.name},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveWord: ${options.showActiveBars},
  allowRotation: ${options.showTracks},
  maxWords: $maxWords,
  valueFormatter: (value) => value.toStringAsFixed(0),
)''',
  );
}

SimpleChartSampleSource _audienceOverlapSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleVennChart',
    title: 'Audience Overlap',
    subtitle: 'Set membership and shared segments',
    data: {
      'sets': simpleVennSetsJson(SimpleChartsShowcaseData.audienceVennSets),
      'intersections': simpleVennIntersectionsJson(
        SimpleChartsShowcaseData.audienceVennIntersections,
      ),
    },
    options: {
      ..._partOptionsJson(options),
      'showLabels': true,
      'showIntersectionLabels': options.showReferenceLines,
      'showActiveRegion': options.showActiveBars,
      'fillOpacity': options.showReferenceBands ? 0.28 : 0.2,
    },
    dartCode:
        '''
SimpleVennChart(
  sets: SimpleChartsShowcaseData.audienceVennSets,
  intersections: SimpleChartsShowcaseData.audienceVennIntersections,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLabels: true,
  showValues: ${options.showValues},
  showIntersectionLabels: ${options.showReferenceLines},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveRegion: ${options.showActiveBars},
  fillOpacity: ${options.showReferenceBands ? 0.28 : 0.2},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _audienceUpsetSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleUpsetChart',
    title: 'Audience UpSet',
    subtitle: 'Ranked set intersections',
    data: {
      'sets': simpleUpsetSetsJson(SimpleChartsShowcaseData.audienceUpsetSets),
      'intersections': simpleUpsetIntersectionsJson(
        SimpleChartsShowcaseData.audienceUpsetIntersections,
      ),
    },
    options: {
      ..._axisOptionsJson(options),
      'showSetTotals': options.showValues,
      'showIntersectionLabels': options.showReferenceLines,
      'showActiveIntersection': options.showActiveBars,
      'maxIntersections': options.showReferenceBands ? null : 6,
    },
    dartCode:
        '''
SimpleUpsetChart(
  sets: SimpleChartsShowcaseData.audienceUpsetSets,
  intersections: SimpleChartsShowcaseData.audienceUpsetIntersections,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showSetTotals: ${options.showValues},
  showIntersectionLabels: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveIntersection: ${options.showActiveBars},
  maxIntersections: ${options.showReferenceBands ? 'null' : '6'},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _portfolioTreemapSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleTreemapChart',
    title: 'Portfolio Treemap',
    subtitle: 'Nested part-to-whole allocation',
    data: {
      'data': simpleTreemapDataJson(SimpleChartsShowcaseData.portfolioTreemap),
    },
    options: _hierarchyOptionsJson(
      options,
      extra: {
        'showActiveTile': options.showActiveBars,
        'maxDepth': options.showReferenceBands ? 3 : 2,
      },
    ),
    dartCode:
        '''
SimpleTreemapChart(
  data: SimpleChartsShowcaseData.portfolioTreemap,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showParentLabels: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveTile: ${options.showActiveBars},
  maxDepth: ${options.showReferenceBands ? 3 : 2},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _portfolioSunburstSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleSunburstChart',
    title: 'Portfolio Sunburst',
    subtitle: 'Radial nested allocation',
    data: {
      'data': simpleSunburstDataJson(
        SimpleChartsShowcaseData.portfolioSunburst,
      ),
      'centerLabel': 'Portfolio',
    },
    options: _hierarchyOptionsJson(
      options,
      extra: {
        'showActiveSegment': options.showActiveBars,
        'maxDepth': options.showReferenceBands ? 3 : 2,
      },
    ),
    dartCode:
        '''
SimpleSunburstChart(
  data: SimpleChartsShowcaseData.portfolioSunburst,
  style: SimpleBarChartStyle.${options.barStyle.name},
  centerLabel: 'Portfolio',
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showParentLabels: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveSegment: ${options.showActiveBars},
  maxDepth: ${options.showReferenceBands ? 3 : 2},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _portfolioIcicleSource(
  SimpleChartsGalleryOptions options,
) {
  final orientation = options.showReferenceBands
      ? SimpleIcicleOrientation.horizontal
      : SimpleIcicleOrientation.vertical;

  return _compositionSampleSource(
    chartType: 'SimpleIcicleChart',
    title: 'Portfolio Icicle',
    subtitle: 'Hierarchy depth bands',
    data: {
      'data': simpleIcicleDataJson(SimpleChartsShowcaseData.portfolioIcicle),
    },
    options: _hierarchyOptionsJson(
      options,
      extra: {
        'orientation': orientation.name,
        'showActiveSegment': options.showActiveBars,
        'maxDepth': options.showTracks ? 4 : 3,
      },
    ),
    dartCode:
        '''
SimpleIcicleChart(
  data: SimpleChartsShowcaseData.portfolioIcicle,
  style: SimpleBarChartStyle.${options.barStyle.name},
  orientation: SimpleIcicleOrientation.${orientation.name},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showParentLabels: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveSegment: ${options.showActiveBars},
  maxDepth: ${options.showTracks ? 4 : 3},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _portfolioTreeSource(
  SimpleChartsGalleryOptions options,
) {
  final orientation = options.showReferenceBands
      ? SimpleTreeDiagramOrientation.horizontal
      : SimpleTreeDiagramOrientation.vertical;

  return _compositionSampleSource(
    chartType: 'SimpleTreeDiagramChart',
    title: 'Portfolio Tree',
    subtitle: 'Readable hierarchy branches',
    data: {
      'data': simpleTreeDiagramDataJson(SimpleChartsShowcaseData.portfolioTree),
    },
    options: _hierarchyOptionsJson(
      options,
      extra: {
        'orientation': orientation.name,
        'showLabels': true,
        'showRoot': options.showTracks,
        'curvedLinks': options.showReferenceLines,
        'showActiveNode': options.showActiveBars,
        'maxDepth': options.showReferenceBands ? 3 : 4,
      },
    ),
    dartCode:
        '''
SimpleTreeDiagramChart(
  data: SimpleChartsShowcaseData.portfolioTree,
  style: SimpleBarChartStyle.${options.barStyle.name},
  orientation: SimpleTreeDiagramOrientation.${orientation.name},
  showLabels: true,
  showValues: ${options.showValues},
  showRoot: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveNode: ${options.showActiveBars},
  curvedLinks: ${options.showReferenceLines},
  maxDepth: ${options.showReferenceBands ? 3 : 4},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _readinessIconsSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimplePictogramChart',
    title: 'Readiness Icons',
    subtitle: 'Countable icon array composition',
    data: {
      'data': simplePictogramDataJson(SimpleChartsShowcaseData.readinessIcons),
      'totalValue': 100,
      'rows': 5,
      'columns': 10,
      'symbol': SimplePictogramSymbol.person.name,
    },
    options: {
      ..._unitOptionsJson(options),
      'showActiveUnits': options.showActiveBars,
      'showEmptyUnits': options.showTracks,
    },
    dartCode:
        '''
SimplePictogramChart(
  data: SimpleChartsShowcaseData.readinessIcons,
  totalValue: 100,
  rows: 5,
  columns: 10,
  style: SimpleBarChartStyle.${options.barStyle.name},
  symbol: SimplePictogramSymbol.person,
  showLegend: ${options.showLegends},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveUnits: ${options.showActiveBars},
  showEmptyUnits: ${options.showTracks},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _marketMosaicSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleMarimekkoChart',
    title: 'Market Mosaic',
    subtitle: 'Segment size and channel mix',
    data: {
      'categories': SimpleChartsShowcaseData.marketMosaicCategories,
      'series': simpleMarimekkoSeriesJson(
        SimpleChartsShowcaseData.marketMosaic,
      ),
    },
    options: _matrixOptionsJson(
      options,
      extra: {'showActiveSegment': options.showActiveBars},
    ),
    dartCode:
        '''
SimpleMarimekkoChart(
  categories: SimpleChartsShowcaseData.marketMosaicCategories,
  series: SimpleChartsShowcaseData.marketMosaic,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showPercentages: ${options.showValues},
  showSegmentLabels: ${options.showReferenceLines},
  showColumnTotals: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveSegment: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}k',
)''',
  );
}

SimpleChartSampleSource _channelMosaicPlotSource(
  SimpleChartsGalleryOptions options,
) {
  return _compositionSampleSource(
    chartType: 'SimpleMosaicPlotChart',
    title: 'Channel Mosaic Plot',
    subtitle: 'Cell-based categorical relationship',
    data: {
      'xLabels': SimpleChartsShowcaseData.marketMosaicCategories,
      'yLabels': const ['Online', 'Partner', 'Field'],
      'cells': simpleMosaicPlotCellsJson(
        SimpleChartsShowcaseData.marketMosaicPlot,
      ),
    },
    options: _matrixOptionsJson(
      options,
      extra: {'showActiveCell': options.showActiveBars},
    ),
    dartCode:
        '''
SimpleMosaicPlotChart(
  xLabels: SimpleChartsShowcaseData.marketMosaicCategories,
  yLabels: const ['Online', 'Partner', 'Field'],
  cells: SimpleChartsShowcaseData.marketMosaicPlot,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showPercentages: ${options.showValues},
  showCellLabels: ${options.showReferenceLines},
  showColumnTotals: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveCell: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}k',
)''',
  );
}

SimpleChartSampleSource _compositionSampleSource({
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

Map<String, dynamic> _partOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
  };
}

Map<String, dynamic> _unitOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showLegend': options.showLegends,
    'showValues': options.showValues,
    'showTooltip': options.showTooltips,
    'showTracks': options.showTracks,
    'showReferenceBands': options.showReferenceBands,
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
    'showActive': options.showActiveBars,
  };
}

Map<String, dynamic> _hierarchyOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.barStyle.name,
    'showLabels': options.showValues,
    'showValues': options.showValues,
    'showParentLabels': options.showReferenceLines,
    'showTooltip': options.showTooltips,
    'showReferenceBands': options.showReferenceBands,
    ...extra,
  };
}

Map<String, dynamic> _matrixOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showPercentages': options.showValues,
    'showLabels': options.showReferenceLines,
    'showColumnTotals': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    ...extra,
  };
}
