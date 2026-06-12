import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

import 'simple_charts_showcase_advanced_dashboard_data.dart';
import 'simple_charts_showcase_advanced_dashboard_sources.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_widgets.dart';

List<Widget> simpleChartsAdvancedDashboardPanels(
  SimpleChartsGalleryOptions options,
) => [
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Engagement Scores',
    subtitle: 'Lightweight ranking comparison',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.engagementScores,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleLollipopChart(
      data: SimpleChartsShowcaseAdvancedDashboardData.engagementScores,
      orientation: SimpleBarChartOrientation.horizontal,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActivePoint: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 70, label: 'Benchmark')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 65,
                to: 82,
                label: 'Strong',
                color: Color(0xFF14B8A6),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Operating Targets',
    subtitle: 'Actual vs goal with ranges',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.operatingTargets,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleBulletChart(
      data: options.showReferenceBands
          ? SimpleChartsShowcaseAdvancedDashboardData.operatingTargets
          : SimpleChartsShowcaseAdvancedDashboardData.operatingTargetsPlain,
      style: options.barStyle,
      showValues: options.showValues,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Service Health',
    subtitle: 'KPI gauge with target bands',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.serviceHealth,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleGaugeChart(
      label: 'Readiness',
      value: 86,
      targetValue: options.showReferenceLines ? 90 : null,
      unit: '%',
      ranges: options.showReferenceBands
          ? SimpleChartsShowcaseAdvancedDashboardData.readinessRanges
          : const [],
      style: options.barStyle,
      showTicks: options.showGrid,
      showValue: options.showValues,
      showNeedle: options.showTracks,
      showRanges: options.showReferenceBands,
      showTarget: options.showReferenceLines,
      showTooltip: options.showTooltips,
      showActiveGauge: options.showActiveBars,
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Readiness Rings',
    subtitle: 'Multi-ring progress against targets',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.readinessRings,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleRadialBarChart(
      data: SimpleChartsShowcaseAdvancedDashboardData.readinessRings,
      style: options.barStyle,
      showLegend: options.showLegends,
      showLabels: options.showValues,
      showValues: options.showValues,
      showTargets: options.showReferenceLines,
      showTooltip: options.showTooltips,
      showActiveRing: options.showActiveBars,
      centerLabel: 'Avg',
      valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Capability Profile',
    subtitle: 'Multi-dimensional score comparison',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.capabilityProfile,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleRadarChart(
      axes: SimpleChartsShowcaseAdvancedDashboardData.capabilityAxes,
      series: SimpleChartsShowcaseAdvancedDashboardData.capabilityProfile,
      style: options.barStyle,
      showGrid: options.showGrid,
      showLabels: true,
      showValues: options.showValues,
      showDots: options.showTracks,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveAxis: options.showActiveBars,
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Capability Matrix',
    subtitle: 'Categorical magnitude by segment',
    source: simpleAdvancedDashboardSampleSource(
      SimpleAdvancedDashboardSampleSourceKey.capabilityMatrix,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleBubbleMatrixChart(
      xLabels:
          SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixColumns,
      yLabels: SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrixRows,
      cells: SimpleChartsShowcaseAdvancedDashboardData.capabilityMatrix,
      minValue: 0,
      maxValue: 100,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showLegend: options.showLegends,
      showTooltip: options.showTooltips,
      showActiveBubble: options.showActiveBars,
      useColorScale: options.showReferenceBands,
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
];
