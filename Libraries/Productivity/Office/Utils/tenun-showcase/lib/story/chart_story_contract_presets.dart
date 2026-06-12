import 'chart_story_contract.dart';

const chartStoryThemeKnobSpecs = [
  ChartStoryKnobSpec.boolean(
    key: 'darkMode',
    label: 'Dark Theme',
    group: 'Theme',
  ),
];

const chartStoryTooltipKnobSpec = ChartStoryKnobSpec.boolean(
  key: 'showTooltip',
  label: 'Show Tooltip',
  group: 'Interaction',
  defaultValue: true,
);

const chartStoryCartesianDisplayKnobSpecs = [
  ChartStoryKnobSpec.boolean(
    key: 'showLegend',
    label: 'Show Legend',
    group: 'Display',
    defaultValue: true,
  ),
  chartStoryTooltipKnobSpec,
  ChartStoryKnobSpec.boolean(
    key: 'showGrid',
    label: 'Show Grid',
    group: 'Display',
    defaultValue: true,
  ),
  ChartStoryKnobSpec.boolean(
    key: 'showDots',
    label: 'Show Dots',
    group: 'Display',
    defaultValue: true,
  ),
];

const chartStoryDataModeKnobSpecs = [
  ChartStoryKnobSpec.options(
    key: 'dataMode',
    label: 'Data Mode',
    group: 'Data',
    defaultValue: 'Regular',
    options: ['Regular', 'Auto', 'Large'],
  ),
  ChartStoryKnobSpec.sliderInt(
    key: 'pointCount',
    label: 'Point Count',
    group: 'Data',
    min: 12,
    max: 5000,
    defaultValue: 36,
  ),
  ChartStoryKnobSpec.sliderInt(
    key: 'samplingThreshold',
    label: 'Sampling Threshold',
    group: 'Data',
    min: 50,
    max: 5000,
    defaultValue: 300,
  ),
  ChartStoryKnobSpec.options(
    key: 'samplingStrategyIndex',
    label: 'Sampling Strategy Mode',
    group: 'Data',
    defaultValue: 'Largest Triangle Three Buckets',
    options: ['Largest Triangle Three Buckets', 'Min Max', 'Average'],
  ),
];

List<ChartStoryKnobSpec> chartStoryInteractiveDataKnobSpecs({
  Iterable<ChartStoryKnobSpec> display = const [],
  Iterable<ChartStoryKnobSpec> extras = const [],
}) {
  return [
    ...chartStoryThemeKnobSpecs,
    if (display.isEmpty) chartStoryTooltipKnobSpec else ...display,
    ...extras,
    ...chartStoryDataModeKnobSpecs,
  ];
}
