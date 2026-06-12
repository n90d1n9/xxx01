import 'package:flutter/widgets.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'chart_story_contract.dart';

Story chartStory({
  required String name,
  required String description,
  required WidgetBuilder builder,
  ChartStoryContract? contract,
}) {
  final story = Story(name: name, description: description, builder: builder);
  chartStoryContractRegistry.registerStory(story, contract);
  return story;
}

Widget chartStoryFixedHeight({required double height, required Widget child}) {
  return SizedBox(height: height, child: child);
}

Widget chartStoryCentered({required Widget child}) {
  return Center(child: child);
}

Story fixedHeightChartStory({
  required String name,
  required String description,
  required double height,
  required WidgetBuilder builder,
  ChartStoryContract? contract,
}) {
  return chartStory(
    name: name,
    description: description,
    contract: contract,
    builder: (context) =>
        chartStoryFixedHeight(height: height, child: builder(context)),
  );
}

Story fixedHeightChartChildStory({
  required String name,
  required String description,
  required double height,
  required Widget child,
  ChartStoryContract? contract,
}) {
  return fixedHeightChartStory(
    name: name,
    description: description,
    height: height,
    contract: contract,
    builder: (context) => child,
  );
}

Story centeredChartStory({
  required String name,
  required String description,
  required Widget child,
  ChartStoryContract? contract,
}) {
  return chartStory(
    name: name,
    description: description,
    contract: contract,
    builder: (context) => chartStoryCentered(child: child),
  );
}
