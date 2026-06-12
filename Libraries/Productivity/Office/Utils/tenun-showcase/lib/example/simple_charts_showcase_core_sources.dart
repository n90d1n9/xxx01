import 'simple_charts_showcase_core_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleCoreSampleSourceKey { regionalGrowth, courseOutcomes }

SimpleChartSampleSource? simpleCoreSampleSource(
  SimpleCoreSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleCoreSampleSourceKey.regionalGrowth => _regionalGrowthSource(options),
    SimpleCoreSampleSourceKey.courseOutcomes => _courseOutcomesSource(options),
  };
}

SimpleChartSampleSource _regionalGrowthSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleBarChart',
      title: 'Regional Growth',
      subtitle: 'Professional services pipeline',
      data: {
        'data': simpleBarDataJson(SimpleChartsShowcaseCoreData.regionalGrowth),
      },
      options: _coreOptionsJson(options),
    ),
    dartCode:
        '''
SimpleBarChart(
  data: SimpleChartsShowcaseCoreData.regionalGrowth,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showTrack: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveBar: ${options.showActiveBars},
  referenceLines: const [SimpleChartReferenceLine(value: 25, label: 'Target')],
  referenceBands: const [
    SimpleChartReferenceBand(
      from: 20,
      to: 35,
      label: 'Healthy',
      color: Color(0xFF16A34A),
    ),
  ],
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _courseOutcomesSource(
  SimpleChartsGalleryOptions options,
) {
  return SimpleChartSampleSource(
    sampleJson: simpleChartSourceJson(
      chartType: 'SimpleBarChart',
      title: 'Course Outcomes',
      subtitle: 'Education cohort comparison',
      data: {
        'data': simpleBarDataJson(SimpleChartsShowcaseCoreData.courseOutcomes),
      },
      options: {..._coreOptionsJson(options), 'orientation': 'horizontal'},
    ),
    dartCode:
        '''
SimpleBarChart(
  data: SimpleChartsShowcaseCoreData.courseOutcomes,
  orientation: SimpleBarChartOrientation.horizontal,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showTrack: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveBar: ${options.showActiveBars},
  referenceLines: const [SimpleChartReferenceLine(value: 80, label: 'Goal')],
  referenceBands: const [
    SimpleChartReferenceBand(
      from: 75,
      to: 90,
      label: 'Mastery',
      color: Color(0xFF2563EB),
    ),
  ],
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

Map<String, dynamic> _coreOptionsJson(SimpleChartsGalleryOptions options) {
  return {
    'style': options.barStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showTrack': options.showTracks,
    'showTooltip': options.showTooltips,
    'showActive': options.showActiveBars,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
  };
}
