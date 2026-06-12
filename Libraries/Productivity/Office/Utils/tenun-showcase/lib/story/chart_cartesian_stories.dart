import '../example/area_chart_example.dart';
import '../example/bar_chart_examples.dart';
import '../example/chart_type_switch_example.dart';
import '../example/json_bar_chart_example.dart';
import '../example/line_chart_examples.dart';
import '../example/multi_bar_example.dart';
import '../example/scatter_chart_example.dart';
import '../example/stacked_bar_example.dart';
import 'chart_cartesian_story_contracts.dart';
import 'chart_story_builders.dart';
import 'chart_story_knobs.dart';

final chartCartesianExplorationStories = [
  centeredChartStory(
    name: 'Charts/By Data Shape/Cartesian/Area Variants',
    description: 'Multi-variant area charts (JSON-driven + config object).',
    child: const AreaChartExample(),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Cartesian/Area Knobs',
    description:
        'Toggle legend/tooltip/grid/dots + data mode, then switch chart type manually or auto by inferred data shape.',
    height: 460,
    contract: chartCartesianAreaKnobsContract,
    builder: (context) {
      final knobs = chartStoryAreaKnobs(context);

      return AreaInteractiveKnobExample(
        showLegend: knobs.showLegend,
        showTooltip: knobs.showTooltip,
        showGrid: knobs.showGrid,
        showDots: knobs.showDots,
        gradientArea: knobs.gradientArea,
        dataMode: knobs.dataMode,
        pointCount: knobs.pointCount,
        samplingThreshold: knobs.samplingThreshold,
        samplingStrategyIndex: knobs.samplingStrategyIndex,
      );
    },
  ),
  centeredChartStory(
    name: 'Charts/By Data Shape/Cartesian/Line Variants',
    description: 'Line chart variants (JSON + config object).',
    child: const LineChartExample(),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Cartesian/Line Knobs',
    description:
        'Toggle line options + data mode, then switch chart type manually or auto by inferred data shape.',
    height: 460,
    contract: chartCartesianLineKnobsContract,
    builder: (context) {
      final knobs = chartStoryLineKnobs(context);

      return LineInteractiveKnobExample(
        showLegend: knobs.showLegend,
        showGrid: knobs.showGrid,
        showDots: knobs.showDots,
        curveSmoothness: knobs.curveSmoothness,
        dataMode: knobs.dataMode,
        pointCount: knobs.pointCount,
        samplingThreshold: knobs.samplingThreshold,
        samplingStrategyIndex: knobs.samplingStrategyIndex,
      );
    },
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Smart Type Switch',
    description:
        'Shape-aware runtime switching with optional cross-shape conversion (bar/line/area/pie/treemap/sunburst).',
    height: 420,
    builder: (context) {
      final sampling = chartStoryDataModeKnobs(context);

      return ChartTypeSwitchExample(
        dataMode: sampling.dataMode,
        pointCount: sampling.pointCount,
        samplingThreshold: sampling.samplingThreshold,
        samplingStrategyIndex: sampling.samplingStrategyIndex,
      );
    },
  ),
];

final chartCartesianVariantStories = [
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Simple',
    description:
        'Simple bar with large-data knobs plus manual/auto shape-aware chart switching.',
    contract: chartCartesianBarSimpleContract,
    builder: (context) {
      final knobs = chartStoryInteractiveDataKnobs(context);
      return knobs.wrapThemed(
        chartStoryCentered(
          child: BarInteractiveKnobExample(
            showTooltip: knobs.showTooltip,
            dataMode: knobs.dataMode,
            pointCount: knobs.pointCount,
            samplingThreshold: knobs.samplingThreshold,
            samplingStrategyIndex: knobs.samplingStrategyIndex,
          ),
        ),
      );
    },
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Grouped',
    description:
        'Grouped (multi-series) bar chart comparing quarterly revenue by region.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => GroupedBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Stacked',
    description: 'Stacked bar chart showing project tasks completion status.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => StackedBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Horizontal',
    description: 'Horizontal bar chart displaying top products by sales.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => HorizontalBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Gradient',
    description: 'Bar chart with gradient colors for website traffic sources.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => GradientBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Negative Values',
    description: 'Bar chart demonstrating positive and negative values (P&L).',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => NegativeBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Custom Colors',
    description: 'Bar chart with custom colors for team performance scores.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => CustomColorBarChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Mixed Bar-Line',
    description: 'Bar chart showing actual sales vs target comparison.',
    builder: (context) => chartStoryDisplayCenter(
      context,
      (display) => MixedBarLineChartExample(showTooltip: display.showTooltip),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/JSON Showcase',
    description: 'JSON-driven bar chart examples in one screen.',
    builder: (context) => const JsonBarChartExample(),
  ),
  centeredChartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Legacy Multi',
    description: 'Legacy multi-bar example.',
    child: const MultiBarExample(),
  ),
  centeredChartStory(
    name: 'Charts/By Data Shape/Cartesian/Bar/Legacy Stacked',
    description: 'Legacy stacked bar example.',
    child: const StackedBarExample(),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Cartesian/Scatter/Basic',
    description: 'Scatter chart with regular/auto/large data-mode controls.',
    builder: (context) {
      final knobs = chartStoryInteractiveDataKnobs(context);
      return knobs.wrapThemed(
        chartStoryCentered(
          child: ScatterInteractiveKnobExample(
            showTooltip: knobs.showTooltip,
            dataMode: knobs.dataMode,
            pointCount: knobs.pointCount,
            samplingThreshold: knobs.samplingThreshold,
            samplingStrategyIndex: knobs.samplingStrategyIndex,
          ),
        ),
      );
    },
  ),
];

final chartCartesianStories = [
  ...chartCartesianExplorationStories,
  ...chartCartesianVariantStories,
];
