import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_gallery_options.dart';
import 'simple_charts_showcase_source.dart';

enum SimpleComparisonSampleSourceKey {
  priorityPareto,
  forecastRange,
  sensitivityTornado,
  experimentErrorBars,
  experimentForest,
  benchmarkDots,
  feedbackLikert,
  priorityRace,
  roadmapTimeline,
  milestoneRoadmap,
  eventStrip,
  projectGantt,
  beforeAfterSlope,
  cohortPyramid,
}

SimpleChartSampleSource? simpleComparisonSampleSource(
  SimpleComparisonSampleSourceKey key,
  SimpleChartsGalleryOptions options,
) {
  if (!options.showSampleSource) {
    return null;
  }

  return switch (key) {
    SimpleComparisonSampleSourceKey.priorityPareto => _priorityParetoSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.forecastRange => _forecastRangeSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.sensitivityTornado =>
      _sensitivityTornadoSource(options),
    SimpleComparisonSampleSourceKey.experimentErrorBars =>
      _experimentErrorBarsSource(options),
    SimpleComparisonSampleSourceKey.experimentForest => _experimentForestSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.benchmarkDots => _benchmarkDotsSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.feedbackLikert => _feedbackLikertSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.priorityRace => _priorityRaceSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.roadmapTimeline => _roadmapTimelineSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.milestoneRoadmap => _milestoneRoadmapSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.eventStrip => _eventStripSource(options),
    SimpleComparisonSampleSourceKey.projectGantt => _projectGanttSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.beforeAfterSlope => _beforeAfterSlopeSource(
      options,
    ),
    SimpleComparisonSampleSourceKey.cohortPyramid => _cohortPyramidSource(
      options,
    ),
  };
}

SimpleChartSampleSource _priorityParetoSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleParetoChart',
    title: 'Priority Pareto',
    subtitle: 'Ranked drivers and cumulative share',
    data: {'data': simpleBarDataJson(SimpleChartsShowcaseData.priorityPareto)},
    options: {
      ..._barOptionsJson(options),
      'showCumulativeLabels': options.showReferenceLines,
      'showTargetLine': options.showReferenceBands,
    },
    dartCode:
        '''
SimpleParetoChart(
  data: SimpleChartsShowcaseData.priorityPareto,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showCumulativeLabels: ${options.showReferenceLines},
  showTargetLine: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
  valueFormatter: (value) => value.toStringAsFixed(0),
)''',
  );
}

SimpleChartSampleSource _forecastRangeSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleRangeChart',
    title: 'Forecast Range',
    subtitle: 'Min, max, and expected value',
    data: {
      'data': simpleRangeDataJson(SimpleChartsShowcaseData.forecastRanges),
    },
    options: {
      ..._barOptionsJson(options),
      'showRangeLabels': options.showValues,
      'showMarkers': options.showTracks,
      'referenceLines': options.showReferenceLines
          ? const [
              {'value': 75, 'label': 'Plan'},
            ]
          : const [],
      'referenceBands': options.showReferenceBands
          ? const [
              {
                'from': 70,
                'to': 90,
                'label': 'Target Zone',
                'color': '#FF22C55E',
              },
            ]
          : const [],
    },
    dartCode:
        '''
SimpleRangeChart(
  data: SimpleChartsShowcaseData.forecastRanges,
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showRangeLabels: ${options.showValues},
  showMarkers: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveRange: ${options.showActiveBars},
  referenceLines: ${options.showReferenceLines ? "const [SimpleChartReferenceLine(value: 75, label: 'Plan')]" : 'const []'},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _sensitivityTornadoSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleTornadoChart',
    title: 'Sensitivity Tornado',
    subtitle: 'Low and high scenario impact',
    data: {
      'data': simpleTornadoDataJson(
        SimpleChartsShowcaseData.sensitivityTornado,
      ),
      'baseline': 72,
      'lowLabel': 'Low case',
      'highLabel': 'High case',
    },
    options: {
      ..._barOptionsJson(options),
      'showLegend': options.showLegends,
      'showBaseline': options.showReferenceLines,
    },
    dartCode:
        '''
SimpleTornadoChart(
  data: SimpleChartsShowcaseData.sensitivityTornado,
  baseline: 72,
  lowLabel: 'Low case',
  highLabel: 'High case',
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showBaseline: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveBar: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _experimentErrorBarsSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleErrorBarChart',
    title: 'Experiment Error Bars',
    subtitle: 'Mean and confidence interval',
    data: {
      'data': simpleErrorBarDataJson(
        SimpleChartsShowcaseData.experimentIntervals,
      ),
      'minValue': 50,
      'maxValue': 100,
    },
    options: {
      ..._barOptionsJson(options),
      'showErrorLabels': options.showReferenceLines,
      'showCaps': options.showTracks,
      'showLine': options.showReferenceBands,
    },
    dartCode:
        '''
SimpleErrorBarChart(
  data: SimpleChartsShowcaseData.experimentIntervals,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 50,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showErrorLabels: ${options.showReferenceLines},
  showCaps: ${options.showTracks},
  showLine: ${options.showReferenceBands},
  showTooltip: ${options.showTooltips},
  showActivePoint: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _experimentForestSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleForestPlotChart',
    title: 'Experiment Forest',
    subtitle: 'Effect size and confidence interval',
    data: {
      'data': simpleForestPlotDataJson(
        SimpleChartsShowcaseData.experimentEffects,
      ),
      'minValue': -0.4,
      'maxValue': 0.4,
      'referenceValue': 0,
    },
    options: {
      ..._barOptionsJson(options),
      'showIntervalLabels': options.showReferenceLines,
      'showWeights': options.showReferenceBands,
      'showReferenceLine': options.showReferenceLines,
    },
    dartCode:
        '''
SimpleForestPlotChart(
  data: SimpleChartsShowcaseData.experimentEffects,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: -0.4,
  maxValue: 0.4,
  referenceValue: 0,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showIntervalLabels: ${options.showReferenceLines},
  showWeights: ${options.showReferenceBands},
  showReferenceLine: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveItem: ${options.showActiveBars},
  valueFormatter: (value) => value.toStringAsFixed(2),
  weightFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _benchmarkDotsSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleDotPlotChart',
    title: 'Benchmark Dots',
    subtitle: 'Compact ranking and comparison',
    data: {
      'categories': SimpleChartsShowcaseData.benchmarkCategories,
      'series': simpleDotPlotSeriesJson(SimpleChartsShowcaseData.benchmarkDots),
      'minValue': 0,
      'maxValue': 100,
    },
    options: {
      ..._barOptionsJson(options),
      'showGuideLines': options.showReferenceLines,
      'showActiveDot': options.showActiveBars,
    },
    dartCode:
        '''
SimpleDotPlotChart(
  categories: SimpleChartsShowcaseData.benchmarkCategories,
  series: SimpleChartsShowcaseData.benchmarkDots,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showGuideLines: ${options.showReferenceLines},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveDot: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _feedbackLikertSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleLikertChart',
    title: 'Feedback Likert',
    subtitle: 'Diverging response distribution',
    data: {
      'categories': simpleLikertCategoriesJson(
        SimpleChartsShowcaseData.feedbackLikertCategories,
      ),
      'items': simpleLikertItemsJson(SimpleChartsShowcaseData.feedbackLikert),
    },
    options: {
      ..._barOptionsJson(options),
      'stackAsPercent': options.stackAsPercent,
      'showActiveSegment': options.showActiveBars,
      'showCenterLine': options.showReferenceLines,
      'showAxisLabels': options.showReferenceLines,
    },
    dartCode:
        '''
SimpleLikertChart(
  categories: SimpleChartsShowcaseData.feedbackLikertCategories,
  items: SimpleChartsShowcaseData.feedbackLikert,
  style: SimpleBarChartStyle.${options.barStyle.name},
  stackAsPercent: ${options.stackAsPercent},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveSegment: ${options.showActiveBars},
  showCenterLine: ${options.showReferenceLines},
  showAxisLabels: ${options.showReferenceLines},
)''',
  );
}

SimpleChartSampleSource _priorityRaceSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleBumpChart',
    title: 'Priority Race',
    subtitle: 'Rank movement over time',
    data: {
      'periods': SimpleChartsShowcaseData.priorityPeriods,
      'series': simpleBumpSeriesJson(SimpleChartsShowcaseData.priorityRanks),
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showDots': options.showTracks,
        'showActiveSeries': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleBumpChart(
  periods: SimpleChartsShowcaseData.priorityPeriods,
  series: SimpleChartsShowcaseData.priorityRanks,
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  showGrid: ${options.showGrid},
  showDots: ${options.showTracks},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveSeries: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _roadmapTimelineSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleTimelineChart',
    title: 'Roadmap Timeline',
    subtitle: 'Milestones and planned releases',
    data: {
      'events': simpleTimelineEventsJson(
        SimpleChartsShowcaseData.roadmapTimeline,
      ),
    },
    options: _timelineOptionsJson(
      options,
      extra: {
        'alternating': options.showReferenceBands,
        'showActiveEvent': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleTimelineChart(
  events: SimpleChartsShowcaseData.roadmapTimeline,
  style: SimpleBarChartStyle.${options.barStyle.name},
  alternating: ${options.showReferenceBands},
  showDates: ${options.showValues},
  showDescriptions: ${options.showReferenceLines},
  showTags: ${options.showTracks},
  showTooltip: ${options.showTooltips},
  showActiveEvent: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _milestoneRoadmapSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleMilestoneChart',
    title: 'Milestone Roadmap',
    subtitle: 'Date-positioned gates and checkpoints',
    data: {
      'milestones': simpleMilestonesJson(
        SimpleChartsShowcaseData.roadmapMilestones,
      ),
      'minDate': simpleDateJson(DateTime(2026, 1)),
      'maxDate': simpleDateJson(DateTime(2026, 5)),
    },
    options: _timelineOptionsJson(
      options,
      extra: {
        'alternating': options.showReferenceBands,
        'showConnector': options.showGrid,
        'showActiveMilestone': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleMilestoneChart(
  milestones: SimpleChartsShowcaseData.roadmapMilestones,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minDate: DateTime(2026, 1),
  maxDate: DateTime(2026, 5),
  alternating: ${options.showReferenceBands},
  showDates: ${options.showValues},
  showDescriptions: ${options.showReferenceLines},
  showTags: ${options.showTracks},
  showConnector: ${options.showGrid},
  showTooltip: ${options.showTooltips},
  showActiveMilestone: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _eventStripSource(SimpleChartsGalleryOptions options) {
  return _comparisonSampleSource(
    chartType: 'SimpleEventStripChart',
    title: 'Event Strip',
    subtitle: 'Activity density by time and lane',
    data: {
      'lanes': simpleEventStripLanesJson(SimpleChartsShowcaseData.eventStrip),
      'minDate': simpleDateJson(DateTime(2026, 1)),
      'maxDate': simpleDateJson(DateTime(2026, 5)),
      'markerDate': options.showReferenceLines
          ? simpleDateJson(DateTime(2026, 3, 1))
          : null,
    },
    options: {
      ..._timelineOptionsJson(options),
      'showGrid': options.showGrid,
      'showEventLabels': options.showReferenceBands,
      'showWeights': options.showValues,
      'showMarkerDate': options.showReferenceLines,
      'showActiveEvent': options.showActiveBars,
    },
    dartCode:
        '''
SimpleEventStripChart(
  lanes: SimpleChartsShowcaseData.eventStrip,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minDate: DateTime(2026, 1),
  maxDate: DateTime(2026, 5),
  markerDate: ${options.showReferenceLines ? 'DateTime(2026, 3, 1)' : 'null'},
  showGrid: ${options.showGrid},
  showDates: ${options.showValues},
  showEventLabels: ${options.showReferenceBands},
  showWeights: ${options.showValues},
  showMarkerDate: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveEvent: ${options.showActiveBars},
  weightFormatter: (value) => value.toStringAsFixed(1),
)''',
  );
}

SimpleChartSampleSource _projectGanttSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleGanttChart',
    title: 'Project Gantt',
    subtitle: 'Task duration, dependencies, progress',
    data: {
      'tasks': simpleGanttTasksJson(SimpleChartsShowcaseData.projectGantt),
      'minDate': simpleDateJson(DateTime(2026, 1)),
      'maxDate': simpleDateJson(DateTime(2026, 3, 5)),
      'today': options.showReferenceLines
          ? simpleDateJson(DateTime(2026, 2))
          : null,
    },
    options: {
      ..._timelineOptionsJson(options),
      'showGrid': options.showGrid,
      'showProgress': options.showValues,
      'showDependencies': options.showReferenceBands,
      'showToday': options.showReferenceLines,
      'showActiveTask': options.showActiveBars,
    },
    dartCode:
        '''
SimpleGanttChart(
  tasks: SimpleChartsShowcaseData.projectGantt,
  style: SimpleBarChartStyle.${options.barStyle.name},
  minDate: DateTime(2026, 1),
  maxDate: DateTime(2026, 3, 5),
  today: ${options.showReferenceLines ? 'DateTime(2026, 2)' : 'null'},
  showGrid: ${options.showGrid},
  showDates: ${options.showValues},
  showProgress: ${options.showValues},
  showDependencies: ${options.showReferenceBands},
  showToday: ${options.showReferenceLines},
  showTooltip: ${options.showTooltips},
  showActiveTask: ${options.showActiveBars},
)''',
  );
}

SimpleChartSampleSource _beforeAfterSlopeSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimpleSlopeChart',
    title: 'Before / After Slope',
    subtitle: 'Two-point movement comparison',
    data: {
      'data': simpleSlopeDataJson(SimpleChartsShowcaseData.slopeMoves),
      'startLabel': 'Before',
      'endLabel': 'After',
      'minValue': 0,
      'maxValue': 100,
    },
    options: _trendOptionsJson(
      options,
      extra: {
        'showDelta': options.showReferenceLines,
        'showEndLabels': true,
        'showActiveLine': options.showActiveBars,
      },
    ),
    dartCode:
        '''
SimpleSlopeChart(
  data: SimpleChartsShowcaseData.slopeMoves,
  startLabel: 'Before',
  endLabel: 'After',
  style: SimpleTrendChartStyle.${options.trendStyle.name},
  minValue: 0,
  maxValue: 100,
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showDelta: ${options.showReferenceLines},
  showEndLabels: true,
  showTooltip: ${options.showTooltips},
  showActiveLine: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)} pts',
)''',
  );
}

SimpleChartSampleSource _cohortPyramidSource(
  SimpleChartsGalleryOptions options,
) {
  return _comparisonSampleSource(
    chartType: 'SimplePopulationPyramidChart',
    title: 'Cohort Pyramid',
    subtitle: 'Two-sided segment distribution',
    data: {
      'data': simplePopulationPyramidDataJson(
        SimpleChartsShowcaseData.cohortPyramid,
      ),
      'leftLabel': 'Learners',
      'rightLabel': 'Mentors',
    },
    options: _barOptionsJson(options),
    dartCode:
        '''
SimplePopulationPyramidChart(
  data: SimpleChartsShowcaseData.cohortPyramid,
  leftLabel: 'Learners',
  rightLabel: 'Mentors',
  style: SimpleBarChartStyle.${options.barStyle.name},
  showGrid: ${options.showGrid},
  showValues: ${options.showValues},
  showLegend: ${options.showLegends},
  showTooltip: ${options.showTooltips},
  showActiveBar: ${options.showActiveBars},
  valueFormatter: (value) => '\${value.toStringAsFixed(0)}%',
)''',
  );
}

SimpleChartSampleSource _comparisonSampleSource({
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

Map<String, dynamic> _barOptionsJson(SimpleChartsGalleryOptions options) {
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

Map<String, dynamic> _trendOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.trendStyle.name,
    'showGrid': options.showGrid,
    'showValues': options.showValues,
    'showLegend': options.showLegends,
    'showTooltip': options.showTooltips,
    'showReferenceLines': options.showReferenceLines,
    'showReferenceBands': options.showReferenceBands,
    ...extra,
  };
}

Map<String, dynamic> _timelineOptionsJson(
  SimpleChartsGalleryOptions options, {
  Map<String, dynamic> extra = const {},
}) {
  return {
    'style': options.barStyle.name,
    'showDates': options.showValues,
    'showDescriptions': options.showReferenceLines,
    'showTags': options.showTracks,
    'showTooltip': options.showTooltips,
    ...extra,
  };
}
