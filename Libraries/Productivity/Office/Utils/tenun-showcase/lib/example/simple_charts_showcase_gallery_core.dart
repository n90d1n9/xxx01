import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_core_sources.dart';
import 'simple_charts_showcase_core_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_widgets.dart';

List<Widget> simpleChartsCorePanels(SimpleChartsGalleryOptions options) => [
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Regional Growth',
    subtitle: 'Professional services pipeline',
    source: simpleCoreSampleSource(
      SimpleCoreSampleSourceKey.regionalGrowth,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleBarChart(
      data: SimpleChartsShowcaseCoreData.regionalGrowth,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showTrack: options.showTracks,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 25, label: 'Target')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 20,
                to: 35,
                label: 'Healthy',
                color: Color(0xFF16A34A),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
    ),
  ),
  SimpleChartsShowcasePanel(
    width: options.panelWidth,
    title: 'Course Outcomes',
    subtitle: 'Education cohort comparison',
    source: simpleCoreSampleSource(
      SimpleCoreSampleSourceKey.courseOutcomes,
      options,
    ),
    showSampleJson: options.showSampleJson,
    showSampleCode: options.showSampleCode,
    child: SimpleBarChart(
      data: SimpleChartsShowcaseCoreData.courseOutcomes,
      orientation: SimpleBarChartOrientation.horizontal,
      style: options.barStyle,
      showGrid: options.showGrid,
      showValues: options.showValues,
      showTrack: options.showTracks,
      showTooltip: options.showTooltips,
      showActiveBar: options.showActiveBars,
      referenceLines: options.showReferenceLines
          ? const [SimpleChartReferenceLine(value: 80, label: 'Goal')]
          : const [],
      referenceBands: options.showReferenceBands
          ? const [
              SimpleChartReferenceBand(
                from: 75,
                to: 90,
                label: 'Mastery',
                color: Color(0xFF2563EB),
              ),
            ]
          : const [],
      valueFormatter: (value) => '${value.toStringAsFixed(0)} pts',
    ),
  ),
];
