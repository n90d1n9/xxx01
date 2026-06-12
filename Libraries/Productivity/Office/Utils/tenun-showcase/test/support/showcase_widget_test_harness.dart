import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun/tenun_core.dart' show ChartRegistry;
import 'package:tenun_pro/tenun_pro.dart' show registerTenunProCharts;
import 'package:tenun_showcase/story/charts.dart';

const showcasePumpDuration = Duration(milliseconds: 100);
const showcaseStoryPumpDuration = Duration(milliseconds: 120);
const showcaseStoryViewport = Size(1440, 1100);

void registerAllChartsForTest() {
  ChartRegistry.clear();
  registerTenunProCharts(includeCore: true);
}

Future<void> pumpShowcaseBody(
  WidgetTester tester, {
  required Widget child,
  double width = 820,
  double height = 620,
  Size? physicalSize,
  double devicePixelRatio = 1.0,
  bool settle = false,
}) async {
  final overrideView = physicalSize != null || devicePixelRatio != 1.0;
  if (overrideView) {
    if (physicalSize != null) {
      tester.view.physicalSize = physicalSize;
    }
    tester.view.devicePixelRatio = devicePixelRatio;
    addTearDown(tester.view.reset);
  }

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(showcasePumpDuration);
  }
}

Future<void> pumpChartStorybook(
  WidgetTester tester, {
  required String initialStory,
  Iterable<Story>? stories,
  Size viewport = showcaseStoryViewport,
  double devicePixelRatio = 1.0,
  bool showPanel = false,
  bool settle = false,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Storybook(
      stories: stories ?? charts,
      initialStory: initialStory,
      showPanel: showPanel,
      wrapperBuilder: (_, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(showcaseStoryPumpDuration);
  }
}
