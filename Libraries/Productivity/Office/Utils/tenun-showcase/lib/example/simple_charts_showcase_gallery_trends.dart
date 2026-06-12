import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_trend_sources.dart';
import 'simple_charts_showcase_widgets.dart';

List<Widget> simpleChartsTrendPanels(SimpleChartsGalleryOptions options) => [
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Revenue Trend',
    subtitle: 'Actual vs target',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.revenueTrend,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleLineChart(
      series: SimpleChartsShowcaseData.revenueTrend,
      style: options.trendStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showDots: true,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 65, label: 'Plan')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 60,
                to: 75,
                label: 'Plan Range',
                color: Color(0xFF7C3AED),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Regional Small Multiples',
    subtitle: 'Repeated mini trends on one scale',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.regionalSmallMultiples,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleSmallMultiplesChart(
      panels: SimpleChartsShowcaseData.regionalSmallMultiples,
      style: options.trendStyle,
      minValue: 0,
      maxValue: 80,
      columns: options.showReferenceBands ? 2 : null,
      showGrid: options.showGrid,
      showDots: options.showTracks,
      showValues: options.showValues,
      showArea: options.showReferenceBands,
      showTooltip: options.showTooltips,
      showPanelDividers: options.showTracks,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 60, label: 'Goal')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 55,
                to: 70,
                label: 'Target',
                color: Color(0xFF2563EB),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Seasonal Cycle Plot',
    subtitle: 'Repeated periods across cycles',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.seasonalCyclePlot,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleCyclePlotChart(
      points: SimpleChartsShowcaseData.seasonalCyclePlot,
      periodLabels: SimpleChartsShowcaseData.seasonalPeriods,
      cycleLabels: SimpleChartsShowcaseData.seasonalCycles,
      style: options.trendStyle,
      minValue: 0,
      maxValue: 100,
      showGrid: options.showGrid,
      showDots: options.showTracks,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showAverageLine: options.showReferenceLines,
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 62,
                to: 82,
                label: 'High Season',
                color: Color(0xFF0D9488),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Capacity Steps',
    subtitle: 'Held values and scheduled changes',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.capacitySteps,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleStepChart(
      series: SimpleChartsShowcaseData.capacitySteps,
      style: options.trendStyle,
      mode: options.showReferenceBands
          ? SimpleStepChartMode.middle
          : SimpleStepChartMode.after,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showDots: options.showTracks,
      showArea: options.showReferenceBands,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveStep: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 40, label: 'Commit')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 36,
                to: 52,
                label: 'Operating Window',
                color: Color(0xFF0D9488),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} seats',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Revenue Fan',
    subtitle: 'Forecast with uncertainty bands',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.revenueFan,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleFanChart(
      points: SimpleChartsShowcaseData.revenueForecastFan,
      style: options.trendStyle,
      valueLabel: 'Revenue',
      showGrid: options.showGrid,
      showBands: options.showReferenceBands,
      showLine: true,
      showDots: options.showTracks,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 100, label: 'Goal')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 90,
                to: 120,
                label: 'Plan Range',
                color: Color(0xFF14B8A6),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Seasonal Spiral',
    subtitle: 'Cyclical demand path',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.seasonalSpiral,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleSpiralChart(
      points: SimpleChartsShowcaseData.seasonalDemandSpiral,
      style: options.trendStyle,
      centerLabel: 'Demand',
      cycleLength: 12,
      showGrid: options.showGrid,
      showLine: true,
      showDots: options.showTracks,
      showLabels: options.showValues,
      showValues: options.showReferenceBands,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      showCycleGuides: options.showReferenceLines,
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Market Candles',
    subtitle: 'Open, high, low, close with volume',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.marketCandles,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleCandlestickChart(
      data: SimpleChartsShowcaseData.marketCandles,
      style: options.barStyle,
      mode: options.showReferenceBands
          ? SimpleCandlestickChartMode.ohlc
          : SimpleCandlestickChartMode.candlestick,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showVolume: options.showTracks,
      showTooltip: options.showTooltips,
      showActiveCandle: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 124, label: 'Breakout')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 110,
                to: 118,
                label: 'Support',
                color: Color(0xFF14B8A6),
              ),
            ]
          : const [],
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Product Trajectory',
    subtitle: 'Movement through two business metrics',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.productTrajectory,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleConnectedScatterChart(
      series: SimpleChartsShowcaseData.productTrajectory,
      style: options.barStyle,
      minX: 0,
      maxX: 100,
      minY: 0,
      maxY: 100,
      xAxisLabel: 'Reach',
      yAxisLabel: 'Quality',
      showGrid: options.showGrid,
      showLabels: options.showValues,
      showValues: options.showReferenceBands,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      showArrows: options.showReferenceLines,
      showEndpointLabels: !options.showReferenceBands,
      referenceLines: options.showReferenceLines
          ? const [
              SimpleScatterReferenceLine(
                axis: SimpleScatterReferenceAxis.x,
                value: 50,
                label: 'Reach',
              ),
              SimpleScatterReferenceLine(
                axis: SimpleScatterReferenceAxis.y,
                value: 75,
                label: 'Quality',
              ),
            ]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleScatterReferenceBand(
                axis: SimpleScatterReferenceAxis.y,
                from: 75,
                to: 100,
                label: 'Healthy',
                color: Color(0xFF14B8A6),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Process Control',
    subtitle: 'Mean, limits, and stability signals',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.processControl,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleControlChart(
      points: SimpleChartsShowcaseData.processControl,
      style: options.trendStyle,
      minValue: 76,
      maxValue: 98,
      centerValue: 87,
      lowerControlLimit: 80,
      upperControlLimit: 94,
      lowerWarningLimit: 83,
      upperWarningLimit: 91,
      showGrid: options.showGrid,
      showDots: options.showTracks,
      showValues: options.showValues,
      showCenterLine: options.showReferenceLines,
      showControlLimits: options.showReferenceLines,
      showWarningBand: options.showReferenceBands,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Product Adoption',
    subtitle: 'Activation and retention',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.productAdoption,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleAreaChart(
      series: SimpleChartsShowcaseData.productAdoption,
      style: options.trendStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showDots: true,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 50, label: 'Healthy')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 45,
                to: 60,
                label: 'Good Range',
                color: Color(0xFF0891B2),
              ),
            ]
          : const [],
      fillOpacity: 0.24,
      valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Retention Cohorts',
    subtitle: 'Period-by-period cohort decay',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.retentionCohorts,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleCohortRetentionChart(
      rows: SimpleChartsShowcaseData.retentionCohorts,
      periodLabels: SimpleChartsShowcaseData.retentionPeriods,
      minValue: 0,
      maxValue: 1,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showCohortSize: options.showReferenceLines,
      showEmptyCells: options.showReferenceBands,
      showTooltip: options.showTooltips,
      showActiveCell: options.showActiveBars,
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Health Horizon',
    subtitle: 'Compact positive and negative signals',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.healthHorizon,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleHorizonChart(
      series: SimpleChartsShowcaseData.healthHorizon,
      style: options.trendStyle,
      showGrid: options.showGrid,
      showLabels: options.showValues,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      smooth: options.showReferenceBands,
      bandCount: options.showReferenceLines ? 3 : 2,
      valueFormatter: (value) {
        final prefix = value > 0 ? '+' : '';
        return '$prefix${value.toStringAsFixed(0)} pts';
      },
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Channel Stream',
    subtitle: 'Composition shift over time',
    source: simpleTrendSampleSource(
      SimpleTrendSampleSourceKey.channelStream,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleStreamgraphChart(
      series: SimpleChartsShowcaseData.channelStream,
      style: options.trendStyle,
      mode: options.stackAsPercent
          ? SimpleStreamgraphMode.percent
          : SimpleStreamgraphMode.absolute,
      showGrid: options.showGrid,
      showLabels: options.showValues,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveLayer: options.showActiveBars,
      smooth: options.showReferenceBands,
      valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
    ),
  ),
];
