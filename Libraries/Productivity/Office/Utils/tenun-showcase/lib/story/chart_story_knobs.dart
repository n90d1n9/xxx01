import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun/tenun_core.dart'
    show SimpleBarChartStyle, SimpleTrendChartStyle;

import '../example/chart_sample_source_helpers.dart';
import '../example/simple_charts_showcase_families.dart';

class ChartStoryDisplayKnobs {
  const ChartStoryDisplayKnobs({
    required this.isDark,
    required this.showTooltip,
  });

  final bool isDark;
  final bool showTooltip;

  Widget wrapThemed(Widget child) {
    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: child,
    );
  }
}

class ChartStoryDataModeKnobs {
  const ChartStoryDataModeKnobs({
    required this.dataMode,
    required this.pointCount,
    required this.samplingThreshold,
    required this.samplingStrategyIndex,
  });

  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;

  bool get advancedEnabled => dataMode != 'regular';
}

class ChartStoryInteractiveDataKnobs {
  const ChartStoryInteractiveDataKnobs({
    required this.display,
    required this.sampling,
  });

  final ChartStoryDisplayKnobs display;
  final ChartStoryDataModeKnobs sampling;

  bool get isDark => display.isDark;
  bool get showTooltip => display.showTooltip;
  String get dataMode => sampling.dataMode;
  int get pointCount => sampling.pointCount;
  int get samplingThreshold => sampling.samplingThreshold;
  int get samplingStrategyIndex => sampling.samplingStrategyIndex;

  Widget wrapThemed(Widget child) => display.wrapThemed(child);
}

class ChartStoryCartesianDisplayKnobs {
  const ChartStoryCartesianDisplayKnobs({
    required this.showLegend,
    required this.showTooltip,
    required this.showGrid,
    required this.showDots,
  });

  final bool showLegend;
  final bool showTooltip;
  final bool showGrid;
  final bool showDots;
}

class ChartStorySimpleChartsKnobs {
  const ChartStorySimpleChartsKnobs({
    required this.barStyle,
    required this.trendStyle,
    required this.tierFilter,
    required this.darkMode,
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
    required this.progressiveGalleryLoading,
    required this.initialVisibleGalleryGroups,
    required this.galleryGroupRevealInterval,
  });

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
}

class ChartStoryAreaKnobs {
  const ChartStoryAreaKnobs({
    required this.showLegend,
    required this.showTooltip,
    required this.showGrid,
    required this.showDots,
    required this.gradientArea,
    required this.dataMode,
    required this.pointCount,
    required this.samplingThreshold,
    required this.samplingStrategyIndex,
  });

  final bool showLegend;
  final bool showTooltip;
  final bool showGrid;
  final bool showDots;
  final bool gradientArea;
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;
}

class ChartStoryLineKnobs {
  const ChartStoryLineKnobs({
    required this.showLegend,
    required this.showGrid,
    required this.showDots,
    required this.curveSmoothness,
    required this.dataMode,
    required this.pointCount,
    required this.samplingThreshold,
    required this.samplingStrategyIndex,
  });

  final bool showLegend;
  final bool showGrid;
  final bool showDots;
  final double curveSmoothness;
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;
}

ChartStoryDisplayKnobs chartStoryDisplayKnobs(
  BuildContext context, {
  bool initialDark = false,
  bool initialTooltip = true,
}) {
  return ChartStoryDisplayKnobs(
    isDark: context.knobs.boolean(label: 'Dark Theme', initial: initialDark),
    showTooltip: context.knobs.boolean(
      label: 'Show Tooltip',
      initial: initialTooltip,
    ),
  );
}

ChartStoryInteractiveDataKnobs chartStoryInteractiveDataKnobs(
  BuildContext context, {
  bool initialDark = false,
  bool initialTooltip = true,
  String initialDataMode = 'regular',
  int initialPointCount = 2500,
  int initialSamplingThreshold = 600,
}) {
  return ChartStoryInteractiveDataKnobs(
    display: chartStoryDisplayKnobs(
      context,
      initialDark: initialDark,
      initialTooltip: initialTooltip,
    ),
    sampling: chartStoryDataModeKnobs(
      context,
      initialDataMode: initialDataMode,
      initialPointCount: initialPointCount,
      initialSamplingThreshold: initialSamplingThreshold,
    ),
  );
}

Widget chartStoryDisplayCenter(
  BuildContext context,
  Widget Function(ChartStoryDisplayKnobs display) builder,
) {
  final display = chartStoryDisplayKnobs(context);
  return display.wrapThemed(Center(child: builder(display)));
}

ChartStoryAreaKnobs chartStoryAreaKnobs(
  BuildContext context, {
  bool initialGradientArea = true,
}) {
  final display = chartStoryCartesianDisplayKnobs(context);
  final sampling = chartStoryDataModeKnobs(context);
  return ChartStoryAreaKnobs(
    showLegend: display.showLegend,
    showTooltip: display.showTooltip,
    showGrid: display.showGrid,
    showDots: display.showDots,
    gradientArea: context.knobs.boolean(
      label: 'Gradient Area',
      initial: initialGradientArea,
    ),
    dataMode: sampling.dataMode,
    pointCount: sampling.pointCount,
    samplingThreshold: sampling.samplingThreshold,
    samplingStrategyIndex: sampling.samplingStrategyIndex,
  );
}

ChartStoryLineKnobs chartStoryLineKnobs(
  BuildContext context, {
  double initialCurveSmoothness = 0.25,
}) {
  final display = chartStoryCartesianDisplayKnobs(context);
  final sampling = chartStoryDataModeKnobs(context);
  return ChartStoryLineKnobs(
    showLegend: display.showLegend,
    showGrid: display.showGrid,
    showDots: display.showDots,
    curveSmoothness: context.knobs.slider(
      label: 'Curve Smoothness',
      initial: initialCurveSmoothness,
      min: 0.0,
      max: 0.5,
    ),
    dataMode: sampling.dataMode,
    pointCount: sampling.pointCount,
    samplingThreshold: sampling.samplingThreshold,
    samplingStrategyIndex: sampling.samplingStrategyIndex,
  );
}

ChartStorySimpleChartsKnobs chartStorySimpleChartsKnobs(
  BuildContext context, {
  SimpleBarChartStyle initialBarStyle = SimpleBarChartStyle.elegant,
  SimpleTrendChartStyle initialTrendStyle = SimpleTrendChartStyle.modern,
  SimpleChartsShowcaseTierFilter initialTierFilter =
      SimpleChartsShowcaseTierFilter.all,
  bool initialDarkMode = false,
  bool initialShowGrid = true,
  bool initialShowValues = true,
  bool initialShowTracks = true,
  bool initialShowTooltips = true,
  bool initialShowLegends = true,
  bool initialShowReferenceLines = true,
  bool initialShowReferenceBands = true,
  bool initialShowActiveBars = true,
  bool initialStackAsPercent = false,
  bool initialShowSampleJson = false,
  bool initialShowSampleCode = false,
  bool initialProgressiveGalleryLoading = true,
  int initialVisibleGalleryGroups = 1,
  int initialGalleryGroupRevealIntervalMs = 350,
}) {
  final tierFilter = context.knobs.options<SimpleChartsShowcaseTierFilter>(
    label: 'Simple Chart Tier',
    initial: initialTierFilter,
    options: _chartStoryEnumOptions(SimpleChartsShowcaseTierFilter.values),
  );
  final maxVisibleGalleryGroups = simpleChartsShowcaseFamiliesForTier(
    tierFilter,
  ).length.clamp(1, simpleChartsShowcaseFamilies.length).toInt();
  final clampedInitialVisibleGalleryGroups = initialVisibleGalleryGroups
      .clamp(1, maxVisibleGalleryGroups)
      .toInt();
  final progressiveGalleryLoading = context.knobs.boolean(
    label: 'Progressive Gallery Loading',
    initial: initialProgressiveGalleryLoading,
  );
  final visibleGalleryGroups =
      context.knobs.nullable.sliderInt(
        label: 'Initial Gallery Groups',
        initial: clampedInitialVisibleGalleryGroups,
        min: 1,
        max: maxVisibleGalleryGroups,
        divisions: (maxVisibleGalleryGroups - 1).clamp(1, 100).toInt(),
        enabled: progressiveGalleryLoading,
      ) ??
      clampedInitialVisibleGalleryGroups;
  final revealIntervalMs =
      context.knobs.nullable.sliderInt(
        label: 'Gallery Reveal Interval (ms)',
        initial: initialGalleryGroupRevealIntervalMs,
        min: 100,
        max: 1500,
        divisions: 14,
        enabled: progressiveGalleryLoading,
      ) ??
      initialGalleryGroupRevealIntervalMs;

  return ChartStorySimpleChartsKnobs(
    barStyle: context.knobs.options<SimpleBarChartStyle>(
      label: 'Bar Style',
      initial: initialBarStyle,
      options: _chartStoryEnumOptions(SimpleBarChartStyle.values),
    ),
    trendStyle: context.knobs.options<SimpleTrendChartStyle>(
      label: 'Line & Area Style',
      initial: initialTrendStyle,
      options: _chartStoryEnumOptions(SimpleTrendChartStyle.values),
    ),
    tierFilter: tierFilter,
    darkMode: context.knobs.boolean(
      label: 'Dark Theme',
      initial: initialDarkMode,
    ),
    showGrid: context.knobs.boolean(
      label: 'Show Grid',
      initial: initialShowGrid,
    ),
    showValues: context.knobs.boolean(
      label: 'Show Values',
      initial: initialShowValues,
    ),
    showTracks: context.knobs.boolean(
      label: 'Show Bar Tracks',
      initial: initialShowTracks,
    ),
    showTooltips: context.knobs.boolean(
      label: 'Show Tooltips',
      initial: initialShowTooltips,
    ),
    showLegends: context.knobs.boolean(
      label: 'Show Trend Legends',
      initial: initialShowLegends,
    ),
    showReferenceLines: context.knobs.boolean(
      label: 'Show Targets',
      initial: initialShowReferenceLines,
    ),
    showReferenceBands: context.knobs.boolean(
      label: 'Show Target Ranges',
      initial: initialShowReferenceBands,
    ),
    showActiveBars: context.knobs.boolean(
      label: 'Highlight Active Bars',
      initial: initialShowActiveBars,
    ),
    stackAsPercent: context.knobs.boolean(
      label: 'Stack as Percent',
      initial: initialStackAsPercent,
    ),
    showSampleJson: context.knobs.boolean(
      label: 'Show Simple Sample JSON',
      initial: initialShowSampleJson,
    ),
    showSampleCode: context.knobs.boolean(
      label: 'Show Simple Dart Code',
      initial: initialShowSampleCode,
    ),
    progressiveGalleryLoading: progressiveGalleryLoading,
    initialVisibleGalleryGroups: visibleGalleryGroups,
    galleryGroupRevealInterval: Duration(milliseconds: revealIntervalMs),
  );
}

ChartStoryCartesianDisplayKnobs chartStoryCartesianDisplayKnobs(
  BuildContext context, {
  String labelPrefix = '',
  bool initialLegend = true,
  bool initialTooltip = true,
  bool initialGrid = true,
  bool initialDots = true,
}) {
  return ChartStoryCartesianDisplayKnobs(
    showLegend: context.knobs.boolean(
      label: _chartStoryKnobLabel(labelPrefix, 'Show Legend'),
      initial: initialLegend,
    ),
    showTooltip: context.knobs.boolean(
      label: _chartStoryKnobLabel(labelPrefix, 'Show Tooltip'),
      initial: initialTooltip,
    ),
    showGrid: context.knobs.boolean(
      label: _chartStoryKnobLabel(labelPrefix, 'Show Grid'),
      initial: initialGrid,
    ),
    showDots: context.knobs.boolean(
      label: _chartStoryKnobLabel(labelPrefix, 'Show Dots'),
      initial: initialDots,
    ),
  );
}

ChartStoryDataModeKnobs chartStoryDataModeKnobs(
  BuildContext context, {
  String labelPrefix = '',
  String initialDataMode = 'regular',
  int initialPointCount = 2500,
  int initialSamplingThreshold = 600,
}) {
  final dataMode = context.knobs.options<String>(
    label: _chartStoryKnobLabel(labelPrefix, 'Data Mode'),
    initial: initialDataMode,
    options: const [
      Option(label: 'Regular (Simple)', value: 'regular'),
      Option(label: 'Auto', value: 'auto'),
      Option(label: 'Large', value: 'large'),
    ],
  );
  final advancedEnabled = dataMode != 'regular';
  final pointCount =
      context.knobs.nullable.sliderInt(
        label: _chartStoryKnobLabel(labelPrefix, 'Point Count'),
        initial: initialPointCount,
        min: 100,
        max: 30000,
        divisions: 299,
        enabled: advancedEnabled,
      ) ??
      initialPointCount;
  final samplingThreshold =
      context.knobs.nullable.sliderInt(
        label: _chartStoryKnobLabel(labelPrefix, 'Sampling Threshold'),
        initial: initialSamplingThreshold,
        min: 100,
        max: 4000,
        divisions: 390,
        enabled: advancedEnabled,
      ) ??
      initialSamplingThreshold;
  final samplingStrategy =
      context.knobs.nullable.options<int>(
        label: _chartStoryKnobLabel(labelPrefix, 'Sampling Strategy Mode'),
        initial: 0,
        enabled: advancedEnabled,
        options: const [
          Option(label: 'Auto', value: 0),
          Option(label: 'LTTB', value: 1),
          Option(label: 'MinMax', value: 2),
          Option(label: 'Nth', value: 3),
        ],
      ) ??
      0;

  return ChartStoryDataModeKnobs(
    dataMode: dataMode,
    pointCount: pointCount,
    samplingThreshold: samplingThreshold,
    samplingStrategyIndex: samplingStrategy,
  );
}

ChartSampleShowcaseOptions chartStorySampleShowcaseOptions(
  BuildContext context, {
  bool initialSampleJson = true,
  bool initialSampleCode = true,
  bool initialLegend = true,
  bool initialTooltip = true,
  double chartPadding = 8,
  double sourcePanelHeight = 180,
  double sourcePanelMinWidth = 360,
}) {
  return ChartSampleShowcaseOptions(
    showSampleJson: context.knobs.boolean(
      label: 'Show Sample JSON',
      initial: initialSampleJson,
    ),
    showSampleCode: context.knobs.boolean(
      label: 'Show Dart Code',
      initial: initialSampleCode,
    ),
    showLegend: context.knobs.boolean(
      label: 'Sample Legend',
      initial: initialLegend,
    ),
    showTooltip: context.knobs.boolean(
      label: 'Sample Tooltip',
      initial: initialTooltip,
    ),
    chartPadding: chartPadding,
    sourcePanelHeight: sourcePanelHeight,
    sourcePanelMinWidth: sourcePanelMinWidth,
  );
}

String _chartStoryKnobLabel(String prefix, String label) {
  final normalized = prefix.trim();
  return normalized.isEmpty ? label : '$normalized $label';
}

List<Option<T>> _chartStoryEnumOptions<T extends Enum>(Iterable<T> values) {
  return [
    for (final value in values)
      Option(label: _chartStoryEnumLabel(value), value: value),
  ];
}

String _chartStoryEnumLabel(Enum value) {
  final name = value.name;
  return name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
}
