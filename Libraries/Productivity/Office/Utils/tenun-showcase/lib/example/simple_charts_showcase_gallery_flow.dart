import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_flow_sources.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_widgets.dart';

List<Widget> simpleChartsFlowPanels(SimpleChartsGalleryOptions options) => [
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Conversion Funnel',
    subtitle: 'Stage drop-off and conversion',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.conversionFunnel,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleFunnelChart(
      data: SimpleChartsShowcaseData.conversionFunnel,
      style: options.barStyle,
      showValues: options.showValues,
      showPercentages: options.showValues,
      showConversionRates: options.showReferenceLines,
      showTrack: options.showTracks,
      showTooltip: options.showTooltips,
      showActiveStage: options.showActiveBars,
      valueFormatter: (value) {
        if (value >= 1000) {
          final precision = value >= 10000 ? 0 : 1;
          return '${(value / 1000).toStringAsFixed(precision)}k';
        }
        return value.toStringAsFixed(0);
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Journey Sankey',
    subtitle: 'Proportional flow between stages',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.journeySankey,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleSankeyChart(
      links: SimpleChartsShowcaseData.journeyFlow,
      style: options.barStyle,
      showLabels: true,
      showValues: options.showValues,
      showNodeValues: options.showReferenceLines,
      showTooltip: options.showTooltips,
      showActiveItem: options.showActiveBars,
      nodeGap: options.showTracks ? 14 : 8,
      valueFormatter: (value) {
        if (value >= 1000) {
          final precision = value >= 10000 ? 0 : 1;
          return '${(value / 1000).toStringAsFixed(precision)}k';
        }
        return value.toStringAsFixed(0);
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Journey Alluvial',
    subtitle: 'Multi-stage cohort paths',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.journeyAlluvial,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleAlluvialChart(
      stageLabels: SimpleChartsShowcaseData.journeyAlluvialStages,
      flows: SimpleChartsShowcaseData.journeyAlluvial,
      style: options.barStyle,
      showStageLabels: true,
      showNodeLabels: true,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActiveItem: options.showActiveBars,
      nodeGap: options.showTracks ? 14 : 8,
      ribbonOpacity: options.showReferenceBands ? 0.46 : 0.32,
      valueFormatter: (value) {
        if (value >= 1000) {
          final precision = value >= 10000 ? 0 : 1;
          return '${(value / 1000).toStringAsFixed(precision)}k';
        }
        return value.toStringAsFixed(0);
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Journey Chord',
    subtitle: 'Relationship strength across stages',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.journeyChord,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleChordChart(
      nodes: SimpleChartsShowcaseData.journeyChordNodes,
      links: SimpleChartsShowcaseData.journeyChord,
      style: options.barStyle,
      showLabels: true,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActiveItem: options.showActiveBars,
      linkOpacity: options.showReferenceBands ? 0.36 : 0.24,
      valueFormatter: (value) {
        if (value >= 1000) {
          final precision = value >= 10000 ? 0 : 1;
          return '${(value / 1000).toStringAsFixed(precision)}k';
        }
        return value.toStringAsFixed(0);
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Journey Arc',
    subtitle: 'Ordered relationship jumps',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.journeyArc,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleArcDiagramChart(
      nodes: SimpleChartsShowcaseData.journeyArcNodes,
      links: SimpleChartsShowcaseData.journeyArcLinks,
      style: options.barStyle,
      showLabels: true,
      showValues: options.showValues,
      showDirection: options.showReferenceLines,
      showTooltip: options.showTooltips,
      showActiveItem: options.showActiveBars,
      arcOpacity: options.showReferenceBands ? 0.52 : 0.38,
      valueFormatter: (value) {
        if (value >= 1000) {
          final precision = value >= 10000 ? 0 : 1;
          return '${(value / 1000).toStringAsFixed(precision)}k';
        }
        return value.toStringAsFixed(0);
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Ecosystem Network',
    subtitle: 'Relationship map with grouped nodes',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.ecosystemNetwork,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleNetworkGraphChart(
      nodes: SimpleChartsShowcaseData.ecosystemNetworkNodes,
      links: SimpleChartsShowcaseData.ecosystemNetworkLinks,
      style: options.barStyle,
      layout: options.showReferenceBands
          ? SimpleNetworkGraphLayout.grouped
          : SimpleNetworkGraphLayout.positioned,
      directed: options.showReferenceLines,
      showLabels: true,
      showValues: options.showValues,
      showLinkLabels: options.showReferenceLines,
      showLegend: options.showLegends,
      showGroupHulls: options.showReferenceBands,
      showTooltip: options.showTooltips,
      showActiveItem: options.showActiveBars,
      linkOpacity: options.showTracks ? 0.48 : 0.34,
      valueFormatter: (value) => value.toStringAsFixed(0),
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Opportunity Map',
    subtitle: 'Impact vs effort decision zones',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.opportunityMap,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleQuadrantChart(
      points: SimpleChartsShowcaseData.priorityQuadrant,
      style: options.barStyle,
      minX: 0,
      maxX: 100,
      minY: 0,
      maxY: 100,
      xSplit: 50,
      ySplit: 60,
      xAxisLabel: 'Effort',
      yAxisLabel: 'Impact',
      quadrantLabels: const SimpleQuadrantLabels(
        topRight: 'Major bets',
        topLeft: 'Quick wins',
        bottomLeft: 'Defer',
        bottomRight: 'Automate',
      ),
      showGrid: options.showGrid,
      showAxisLabels: true,
      showQuadrantLabels: options.showReferenceBands,
      showPointLabels: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 75, label: 'High')]
          : const [],
      xValueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
      yValueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
      sizeFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Opportunity Bubbles',
    subtitle: 'Impact vs effort bubble view',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.opportunityBubbles,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleBubbleChart(
      data: SimpleChartsShowcaseData.opportunityBubbles,
      style: options.barStyle,
      minX: 0,
      maxX: 100,
      minY: 0,
      maxY: 100,
      xAxisLabel: 'Effort',
      yAxisLabel: 'Impact',
      sizeLabel: 'Budget',
      showGrid: options.showGrid,
      showLabels: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveBubble: options.showActiveBars,
      showTrendLine: options.showReferenceLines,
      referenceLines: options.showReferenceLines
          ? const [
              SimpleScatterReferenceLine(
                axis: SimpleScatterReferenceAxis.x,
                value: 50,
                label: 'Effort',
              ),
              SimpleScatterReferenceLine(
                axis: SimpleScatterReferenceAxis.y,
                value: 70,
                label: 'Impact',
              ),
            ]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleScatterReferenceBand(
                axis: SimpleScatterReferenceAxis.y,
                from: 70,
                to: 100,
                label: 'High Impact',
                color: Color(0xFF22C55E),
              ),
            ]
          : const [],
      xValueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
      yValueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
      sizeFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Before / After',
    subtitle: 'Two-point change comparison',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.beforeAfter,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleDumbbellChart(
      data: SimpleChartsShowcaseData.beforeAfterScores,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showDelta: options.showValues,
      showTooltip: options.showTooltips,
      showActiveSegment: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 75, label: 'Goal')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 70,
                to: 85,
                label: 'Target Zone',
                color: Color(0xFF6366F1),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
      deltaFormatter: (value) {
        final prefix = value > 0 ? '+' : '';
        return '$prefix${value.toStringAsFixed(0)}';
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Channel Mix',
    subtitle: 'Grouped revenue comparison',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.channelMix,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleGroupedBarChart(
      categories: SimpleChartsShowcaseData.channelMixCategories,
      series: SimpleChartsShowcaseData.channelMix,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 40, label: 'Plan')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 34,
                to: 46,
                label: 'Healthy',
                color: Color(0xFF0F766E),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Channel Share',
    subtitle: 'Composition with center metric',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.channelShare,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleDonutChart(
      data: SimpleChartsShowcaseData.channelShare,
      style: options.barStyle,
      showLegend: options.showLegends,
      showLabels: options.showValues,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActiveSegment: options.showActiveBars,
      centerLabel: 'Total',
      centerValue: '\$128k',
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Channel Rose',
    subtitle: 'Radial magnitude by category',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.channelRose,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleRoseChart(
      data: SimpleChartsShowcaseData.channelRose,
      style: options.barStyle,
      maxValue: 50,
      showGrid: options.showGrid,
      showLegend: options.showLegends,
      showLabels: options.showValues,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActiveSegment: options.showActiveBars,
      scale: options.showReferenceBands
          ? SimpleRoseScale.area
          : SimpleRoseScale.radius,
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Budget Mix',
    subtitle: 'Stacked allocation view',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.budgetMix,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleStackedBarChart(
      categories: SimpleChartsShowcaseData.budgetMixCategories,
      series: SimpleChartsShowcaseData.budgetMix,
      mode: options.stackAsPercent
          ? SimpleStackedBarMode.percent
          : SimpleStackedBarMode.absolute,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? [
              SimpleChartReferenceLine(
                value: options.stackAsPercent ? 75 : 90,
                label: options.stackAsPercent ? 'Share' : 'Budget',
              ),
            ]
          : const [],
      referenceBands: options.showReferenceBands
          ? [
              SimpleChartReferenceBand(
                from: options.stackAsPercent ? 60 : 76,
                to: options.stackAsPercent ? 88 : 98,
                label: options.stackAsPercent ? 'Target Mix' : 'Target Spend',
                color: const Color(0xFF9333EA),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Profit Bridge',
    subtitle: 'Sequential contribution waterfall',
    source: simpleFlowSampleSource(
      SimpleFlowSampleSourceKey.profitBridge,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleWaterfallChart(
      data: SimpleChartsShowcaseData.profitBridge,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showConnectors: options.showTracks,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 170, label: 'Plan')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 160,
                to: 190,
                label: 'Target Range',
                color: Color(0xFF16A34A),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
      deltaFormatter: (value) {
        final prefix = value > 0 ? '+' : '';
        return '$prefix\$${value.toStringAsFixed(0)}k';
      },
    ),
  ),
];
