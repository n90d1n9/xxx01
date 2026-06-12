import 'package:tenun/tenun_core.dart';

class SimpleChartsGalleryOptions {
  final double panelWidth;
  final SimpleBarChartStyle barStyle;
  final SimpleTrendChartStyle trendStyle;
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

  const SimpleChartsGalleryOptions({
    required this.panelWidth,
    required this.barStyle,
    required this.trendStyle,
    required this.showGrid,
    required this.showValues,
    required this.showTracks,
    required this.showTooltips,
    required this.showLegends,
    required this.showReferenceLines,
    required this.showReferenceBands,
    required this.showActiveBars,
    required this.stackAsPercent,
    required this.showSampleJson,
    required this.showSampleCode,
  });

  bool get showSampleSource => showSampleJson || showSampleCode;
}
