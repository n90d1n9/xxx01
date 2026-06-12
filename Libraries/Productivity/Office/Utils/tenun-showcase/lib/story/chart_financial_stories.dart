import '../example/candlestick_chart_example.dart';
import 'chart_story_builders.dart';
import 'chart_story_knobs.dart';

final chartFinancialStories = [
  chartStory(
    name: 'Charts/By Data Shape/Financial/Candlestick/Basic',
    description:
        'Candlestick chart with regular/auto/large data-mode controls.',
    builder: (context) {
      final knobs = chartStoryInteractiveDataKnobs(context);
      return knobs.wrapThemed(
        chartStoryCentered(
          child: CandlestickInteractiveKnobExample(
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
