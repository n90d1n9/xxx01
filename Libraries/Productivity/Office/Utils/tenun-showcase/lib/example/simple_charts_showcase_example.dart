import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_families.dart';
import 'simple_charts_showcase_layout.dart';

class SimpleChartsShowcaseExample extends StatelessWidget {
  final SimpleBarChartStyle barStyle;
  final SimpleTrendChartStyle trendStyle;
  final SimpleChartsShowcaseTierFilter tierFilter;
  final bool darkMode;
  final bool showGrid;
  final bool showValues;
  final bool showTracks;
  final bool showTooltips;
  final bool showLegends;
  final bool showReferenceLines;
  final bool showReferenceBands;
  final bool showActiveBars;
  final bool stackAsPercent;
  final bool showSampleJson;
  final bool showSampleCode;
  final bool progressiveGalleryLoading;
  final int initialVisibleGalleryGroups;
  final Duration galleryGroupRevealInterval;

  const SimpleChartsShowcaseExample({
    super.key,
    this.barStyle = SimpleBarChartStyle.elegant,
    this.trendStyle = SimpleTrendChartStyle.elegant,
    this.tierFilter = SimpleChartsShowcaseTierFilter.all,
    this.darkMode = false,
    this.showGrid = true,
    this.showValues = true,
    this.showTracks = true,
    this.showTooltips = true,
    this.showLegends = true,
    this.showReferenceLines = true,
    this.showReferenceBands = true,
    this.showActiveBars = true,
    this.stackAsPercent = false,
    this.showSampleJson = false,
    this.showSampleCode = false,
    this.progressiveGalleryLoading = true,
    this.initialVisibleGalleryGroups = 1,
    this.galleryGroupRevealInterval = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return SimpleChartsShowcaseLayout(
      barStyle: barStyle,
      trendStyle: trendStyle,
      tierFilter: tierFilter,
      darkMode: darkMode,
      showGrid: showGrid,
      showValues: showValues,
      showTracks: showTracks,
      showTooltips: showTooltips,
      showLegends: showLegends,
      showReferenceLines: showReferenceLines,
      showReferenceBands: showReferenceBands,
      showActiveBars: showActiveBars,
      stackAsPercent: stackAsPercent,
      showSampleJson: showSampleJson,
      showSampleCode: showSampleCode,
      progressiveGalleryLoading: progressiveGalleryLoading,
      initialVisibleGalleryGroups: initialVisibleGalleryGroups,
      galleryGroupRevealInterval: galleryGroupRevealInterval,
    );
  }
}
