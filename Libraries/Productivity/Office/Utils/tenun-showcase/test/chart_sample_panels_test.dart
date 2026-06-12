import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_panels.dart';
import 'package:tenun_showcase/example/showcase_source_panel.dart';

import 'support/chart_sample_test_fixtures.dart';
import 'support/chart_sample_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  testWidgets('sample panel renders chart and source sections', (
    WidgetTester tester,
  ) async {
    await pumpChartSampleBody(
      tester,
      child: const ChartSamplePanel(sample: testRevenueBarsSample),
    );

    final selectableText = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((widget) => widget.data)
        .join('\n');

    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Sample JSON'), findsOneWidget);
    expect(find.text('Dart Code'), findsOneWidget);
    expect(selectableText, contains('"type": "bar"'));
    expect(selectableText, contains('TenunChartFromJson('));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample gallery hides optional source sections', (
    WidgetTester tester,
  ) async {
    await pumpChartSampleBody(
      tester,
      child: const ChartSampleGallery(
        samples: [testRevenueBarsSample, testRevenueTrendSample],
        options: ChartSampleShowcaseOptions(
          showSampleJson: false,
          showSampleCode: false,
        ),
      ),
    );

    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Revenue Trend'), findsOneWidget);
    expect(find.text('Sample JSON'), findsNothing);
    expect(find.text('Dart Code'), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample panel honors presentation options', (
    WidgetTester tester,
  ) async {
    await pumpChartSampleBody(
      tester,
      width: 540,
      height: 360,
      child: const ChartSamplePanel(
        sample: testRevenueBarsSample,
        options: ChartSampleShowcaseOptions(
          showSampleTitle: false,
          showChart: false,
          showSampleCode: false,
          sourcePanelHeight: 120,
          sourcePanelMinWidth: 260,
          chartPadding: 12,
        ),
      ),
    );

    final sourcePanel = tester.widget<ShowcaseSourceTextPanel>(
      find.byType(ShowcaseSourceTextPanel),
    );

    expect(find.text('Revenue Bars'), findsNothing);
    expect(find.text('Sample JSON'), findsOneWidget);
    expect(find.text('Dart Code'), findsNothing);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(sourcePanel.height, 120);
    expect(sourcePanel.text, contains('"type": "bar"'));
    expect(sourcePanel.text, contains('"tooltip": {'));
    expect(tester.takeException(), isNull);
  });
}
