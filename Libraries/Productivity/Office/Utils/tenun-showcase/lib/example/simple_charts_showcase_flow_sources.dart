import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleFlowSampleSourceKey {
  conversionFunnel,
  journeySankey,
  journeyAlluvial,
  journeyChord,
  journeyArc,
  ecosystemNetwork,
  opportunityMap,
  opportunityBubbles,
  beforeAfter,
  channelMix,
  channelShare,
  channelRose,
  budgetMix,
  profitBridge,
}

SimpleChartSampleSource? simpleFlowSampleSource(
  SimpleFlowSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleFlowSampleSourceKey.conversionFunnel => _conversionFunnelSource(
      options,
    ),
    SimpleFlowSampleSourceKey.journeySankey => _journeySankeySource(options),
    SimpleFlowSampleSourceKey.journeyAlluvial => _journeyAlluvialSource(
      options,
    ),
    SimpleFlowSampleSourceKey.journeyChord => _journeyChordSource(options),
    SimpleFlowSampleSourceKey.journeyArc => _journeyArcSource(options),
    SimpleFlowSampleSourceKey.ecosystemNetwork => _ecosystemNetworkSource(
      options,
    ),
    SimpleFlowSampleSourceKey.opportunityMap => _opportunityMapSource(options),
    SimpleFlowSampleSourceKey.opportunityBubbles => _opportunityBubblesSource(
      options,
    ),
    SimpleFlowSampleSourceKey.beforeAfter => _beforeAfterSource(options),
    SimpleFlowSampleSourceKey.channelMix => _channelMixSource(options),
    SimpleFlowSampleSourceKey.channelShare => _channelShareSource(options),
    SimpleFlowSampleSourceKey.channelRose => _channelRoseSource(options),
    SimpleFlowSampleSourceKey.budgetMix => _budgetMixSource(options),
    SimpleFlowSampleSourceKey.profitBridge => _profitBridgeSource(options),
  };
}

SimpleChartSampleSource _conversionFunnelSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleFunnelChart',
    title: 'Conversion Funnel',
    subtitle: 'Stage drop-off and conversion',
    data: {
      'data': simpleFunnelDataJson(SimpleChartsShowcaseData.conversionFunnel),
    },
    options: {
      ..._flowOptionsJson(options),
      'showPercentages': options.showValues,
      'showConversionRates': options.showReferenceLines,
      'showTrack': options.showTracks,
      'showActiveStage': options.showActiveBars,
    },
    dartCode:
        '''
SimpleFunnelChart(
  data: SimpleChartsShowcaseData.conversionFunnel,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showValues: ${options.showValues},
  showPercentages: ${options.showValues},
  showConversionRates: ${options.showReferenceLines},
  showTrack: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveStage: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _journeySankeySource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleSankeyChart',
    title: 'Journey Sankey',
    subtitle: 'Proportional flow between stages',
    data: {
      'links': simpleSankeyLinksJson(SimpleChartsShowcaseData.journeyFlow),
    },
    options: {
      ..._flowOptionsJson(options),
      'showLabels': true,
      'showNodeValues': options.showReferenceLines,
      'showActiveItem': options.showActiveBars,
      'nodeGap': options.showTracks ? 14 : 8,
    },
    dartCode:
        '''
SimpleSankeyChart(
  links: SimpleChartsShowcaseData.journeyFlow,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLabels: true,
  showValues: ${options.showValues},
  showNodeValues: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
  nodeGap: ${options.showTracks ? 14 : 8},
)''',
  );
}

SimpleChartSampleSource _journeyAlluvialSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleAlluvialChart',
    title: 'Journey Alluvial',
    subtitle: 'Multi-stage cohort paths',
    data: {
      'stageLabels': SimpleChartsShowcaseData.journeyAlluvialStages,
      'flows': simpleAlluvialFlowsJson(
        SimpleChartsShowcaseData.journeyAlluvial,
      ),
    },
    options: {
      ..._flowOptionsJson(options),
      'showStageLabels': true,
      'showNodeLabels': true,
      'showActiveItem': options.showActiveBars,
      'nodeGap': options.showTracks ? 14 : 8,
      'ribbonOpacity': options.showReferenceBands ? 0.46 : 0.32,
    },
    dartCode:
        '''
SimpleAlluvialChart(
  stageLabels: SimpleChartsShowcaseData.journeyAlluvialStages,
  flows: SimpleChartsShowcaseData.journeyAlluvial,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showStageLabels: true,
  showNodeLabels: true,
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _journeyChordSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleChordChart',
    title: 'Journey Chord',
    subtitle: 'Relationship strength across stages',
    data: {
      'nodes': simpleChordNodesJson(SimpleChartsShowcaseData.journeyChordNodes),
      'links': simpleChordLinksJson(SimpleChartsShowcaseData.journeyChord),
    },
    options: {
      ..._flowOptionsJson(options),
      'showLabels': true,
      'showActiveItem': options.showActiveBars,
      'linkOpacity': options.showReferenceBands ? 0.36 : 0.24,
    },
    dartCode:
        '''
SimpleChordChart(
  nodes: SimpleChartsShowcaseData.journeyChordNodes,
  links: SimpleChartsShowcaseData.journeyChord,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLabels: true,
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _journeyArcSource(SimpleChartsGalleryOptions options) {
  return _flowSampleSource(
    chartType: 'SimpleArcDiagramChart',
    title: 'Journey Arc',
    subtitle: 'Ordered relationship jumps',
    data: {
      'nodes': simpleArcDiagramNodesJson(
        SimpleChartsShowcaseData.journeyArcNodes,
      ),
      'links': simpleArcDiagramLinksJson(
        SimpleChartsShowcaseData.journeyArcLinks,
      ),
    },
    options: {
      ..._flowOptionsJson(options),
      'showLabels': true,
      'showDirection': options.showReferenceLines,
      'showActiveItem': options.showActiveBars,
      'arcOpacity': options.showReferenceBands ? 0.52 : 0.38,
    },
    dartCode:
        '''
SimpleArcDiagramChart(
  nodes: SimpleChartsShowcaseData.journeyArcNodes,
  links: SimpleChartsShowcaseData.journeyArcLinks,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLabels: true,
  showValues: ${options.showValues},
  showDirection: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _ecosystemNetworkSource(
  SimpleChartsGalleryOptions options,
) {
  final layout = options.showReferenceBands
      ? SimpleNetworkGraphLayout.grouped
      : SimpleNetworkGraphLayout.positioned;

  return _flowSampleSource(
    chartType: 'SimpleNetworkGraphChart',
    title: 'Ecosystem Network',
    subtitle: 'Relationship map with grouped nodes',
    data: {
      'nodes': simpleNetworkNodesJson(
        SimpleChartsShowcaseData.ecosystemNetworkNodes,
      ),
      'links': simpleNetworkLinksJson(
        SimpleChartsShowcaseData.ecosystemNetworkLinks,
      ),
    },
    options: {
      ..._flowOptionsJson(options),
      'layout': layout.name,
      'directed': options.showReferenceLines,
      'showLabels': true,
      'showLinkLabels': options.showReferenceLines,
      'showLegend': options.showLegends,
      'showGroupHulls': options.showReferenceBands,
      'showActiveItem': options.showActiveBars,
      'linkOpacity': options.showTracks ? 0.48 : 0.34,
    },
    dartCode:
        '''
SimpleNetworkGraphChart(
  nodes: SimpleChartsShowcaseData.ecosystemNetworkNodes,
  links: SimpleChartsShowcaseData.ecosystemNetworkLinks,
  style: SimpleBarChartStyle.${options.barStyle.name},
  layout: SimpleNetworkGraphLayout.${layout.name},
  directed: ${options.showReferenceLines},
  showLabels: true,
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _opportunityMapSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleQuadrantChart',
    title: 'Opportunity Map',
    subtitle: 'Impact vs effort decision zones',
    data: {
      'points': simpleQuadrantPointsJson(
        SimpleChartsShowcaseData.priorityQuadrant,
      ),
      'minX': 0,
      'maxX': 100,
      'minY': 0,
      'maxY': 100,
      'xSplit': 50,
      'ySplit': 60,
      'xAxisLabel': 'Effort',
      'yAxisLabel': 'Impact',
      'quadrantLabels': {
        'topRight': 'Major bets',
        'topLeft': 'Quick wins',
        'bottomLeft': 'Defer',
        'bottomRight': 'Automate',
      },
    },
    options: {
      ..._axisOptionsJson(options),
      'showQuadrantLabels': options.showReferenceBands,
      'showPointLabels': options.showValues,
    },
    dartCode:
        '''
SimpleQuadrantChart(
  points: SimpleChartsShowcaseData.priorityQuadrant,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  xSplit: 50,
  ySplit: 60,
  showGrid: ${options.showGrid},
  showPointLabels: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _opportunityBubblesSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleBubbleChart',
    title: 'Opportunity Bubbles',
    subtitle: 'Impact vs effort bubble view',
    data: {
      'data': simpleBubbleDataJson(SimpleChartsShowcaseData.opportunityBubbles),
      'minX': 0,
      'maxX': 100,
      'minY': 0,
      'maxY': 100,
      'xAxisLabel': 'Effort',
      'yAxisLabel': 'Impact',
      'sizeLabel': 'Budget',
    },
    options: {
      ..._axisOptionsJson(options),
      'showLabels': options.showValues,
      'showActiveBubble': options.showActiveBars,
      'showTrendLine': options.showReferenceLines,
    },
    dartCode:
        '''
SimpleBubbleChart(
  data: SimpleChartsShowcaseData.opportunityBubbles,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minX: 0,
  maxX: 100,
  minY: 0,
  maxY: 100,
  showGrid: ${options.showGrid},
  showLabels: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _beforeAfterSource(SimpleChartsGalleryOptions options) {
  return _flowSampleSource(
    chartType: 'SimpleDumbbellChart',
    title: 'Before / After',
    subtitle: 'Two-point change comparison',
    data: {
      'data': simpleDumbbellDataJson(
        SimpleChartsShowcaseData.beforeAfterScores,
      ),
    },
    options: {
      ..._axisOptionsJson(options),
      'showDelta': options.showValues,
      'showActiveSegment': options.showActiveBars,
    },
    dartCode:
        '''
SimpleDumbbellChart(
  data: SimpleChartsShowcaseData.beforeAfterScores,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDelta: ${options.showValues},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _channelMixSource(SimpleChartsGalleryOptions options) {
  return _flowSampleSource(
    chartType: 'SimpleGroupedBarChart',
    title: 'Channel Mix',
    subtitle: 'Grouped revenue comparison',
    data: {
      'categories': SimpleChartsShowcaseData.channelMixCategories,
      'series': simpleGroupedBarSeriesJson(SimpleChartsShowcaseData.channelMix),
    },
    options: _barOptionsJson(options),
    dartCode:
        '''
SimpleGroupedBarChart(
  categories: SimpleChartsShowcaseData.channelMixCategories,
  series: SimpleChartsShowcaseData.channelMix,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _channelShareSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleDonutChart',
    title: 'Channel Share',
    subtitle: 'Composition with center metric',
    data: {
      'data': simpleDonutDataJson(SimpleChartsShowcaseData.channelShare),
      'centerLabel': 'Total',
      'centerValue': r'$128k',
    },
    options: {
      'style': options.barStyle.name,
      'showLegend': options.showLegends,
      'showLabels': options.showValues,
      'showValues': options.showValues,
      'showTooltip': options.showTooltips,
      'showActiveSegment': options.showActiveBars,
    },
    dartCode:
        '''
SimpleDonutChart(
  data: SimpleChartsShowcaseData.channelShare,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showLegend: ${options.showLegends},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
  showTooltip: ${options.showTooltips},
  centerLabel: 'Total',
  centerValue: '\$128k',
)''',
  );
}

SimpleChartSampleSource _channelRoseSource(SimpleChartsGalleryOptions options) {
  final scale = options.showReferenceBands
      ? SimpleRoseScale.area
      : SimpleRoseScale.radius;

  return _flowSampleSource(
    chartType: 'SimpleRoseChart',
    title: 'Channel Rose',
    subtitle: 'Radial magnitude by category',
    data: {
      'data': simpleRoseDataJson(SimpleChartsShowcaseData.channelRose),
      'maxValue': 50,
    },
    options: {
      ..._flowOptionsJson(options),
      'scale': scale.name,
      'showGrid': options.showGrid,
      'showLegend': options.showLegends,
      'showLabels': options.showValues,
      'showActiveSegment': options.showActiveBars,
    },
    dartCode:
        '''
SimpleRoseChart(
  data: SimpleChartsShowcaseData.channelRose,
  style: SimpleBarChartStyle.${options.barStyle.name},
  maxValue: 50,
  scale: SimpleRoseScale.${scale.name},
  showGrid: ${options.showGrid},
  showLegend: ${options.showLegends},
  showLabels: ${options.showValues},
  showValues: ${options.showValues},
)''',
  );
}

SimpleChartSampleSource _budgetMixSource(SimpleChartsGalleryOptions options) {
  final mode = options.stackAsPercent
      ? SimpleStackedBarMode.percent
      : SimpleStackedBarMode.absolute;

  return _flowSampleSource(
    chartType: 'SimpleStackedBarChart',
    title: 'Budget Mix',
    subtitle: 'Stacked allocation view',
    data: {
      'categories': SimpleChartsShowcaseData.budgetMixCategories,
      'series': simpleGroupedBarSeriesJson(SimpleChartsShowcaseData.budgetMix),
    },
    options: {..._barOptionsJson(options), 'mode': mode.name},
    dartCode:
        '''
SimpleStackedBarChart(
  categories: SimpleChartsShowcaseData.budgetMixCategories,
  series: SimpleChartsShowcaseData.budgetMix,
  mode: SimpleStackedBarMode.${mode.name},
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _profitBridgeSource(
  SimpleChartsGalleryOptions options,
) {
  return _flowSampleSource(
    chartType: 'SimpleWaterfallChart',
    title: 'Profit Bridge',
    subtitle: 'Sequential contribution waterfall',
    data: {
      'data': simpleWaterfallDataJson(SimpleChartsShowcaseData.profitBridge),
    },
    options: {
      ..._barOptionsJson(options),
      'showConnectors': options.showTracks,
    },
    dartCode:
        '''
SimpleWaterfallChart(
  data: SimpleChartsShowcaseData.profitBridge,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showConnectors: ${options.showTracks},
  showTooltip: ${options.showTooltips},
)''',
  );
}

SimpleChartSampleSource _flowSampleSource({
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

Map<String, dynamic> _flowOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showValues': options.showValues,
    'showTooltip': options.showTooltips,
  };
}

Map<String, dynamic> _axisOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showActive': options.showActiveBars,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
  };
}

Map<String, dynamic> _barOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showActiveBar': options.showActiveBars,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
  };
}
