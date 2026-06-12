import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'showcase_widget_test_harness.dart' as showcase;

const chartSamplePumpDuration = showcase.showcasePumpDuration;

void registerAllChartsForTest() => showcase.registerAllChartsForTest();

Future<void> pumpChartSampleBody(
  WidgetTester tester, {
  required Widget child,
  double width = 820,
  double height = 620,
}) {
  return showcase.pumpShowcaseBody(
    tester,
    child: child,
    width: width,
    height: height,
  );
}
