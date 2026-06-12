import '../example/heatmap_chart_example.dart';
import 'chart_story_builders.dart';

final chartMatrixStories = [
  centeredChartStory(
    name: 'Charts/By Data Shape/Matrix/Heatmap/Basic',
    description: 'Temperature heatmap example.',
    child: const HeatmapChartExample(),
  ),
];
