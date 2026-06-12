import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_showcase.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/chart_sample_test_fixtures.dart';
import 'support/chart_sample_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  testWidgets('sample family explorer switches selected family samples', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Latency'), findsNothing);

    await tester.tap(find.text('Distribution').first);
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer filters by chart type and sample title', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    expect(find.text('Showing 2 families'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'histogram');
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Cartesian'), findsNothing);
    expect(find.text('Distribution'), findsWidgets);
    expect(find.text('Showing 1 of 2 families'), findsOneWidget);
    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);

    await tester.enterText(find.byType(TextField), 'revenue');
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Cartesian'), findsWidgets);
    expect(find.text('Distribution'), findsNothing);
    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Latency'), findsNothing);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('No chart families found'), findsOneWidget);
    expect(find.text('Showing 0 of 2 families'), findsOneWidget);
    expect(find.text('Latency'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer type filter strip narrows families', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('bar (1)'), findsOneWidget);
    expect(find.text('histogram (1)'), findsOneWidget);

    await tester.tap(find.text('histogram (1)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 1 of 2 families'), findsOneWidget);
    expect(find.text('Distribution'), findsWidgets);
    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);

    await tester.tap(find.text('All (2)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(find.text('Distribution'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer tier filter scopes families and types', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testTierFamilies,
      initialFamilyId: 'cartesian',
    );

    expect(find.text('All tiers (2)'), findsOneWidget);
    expect(find.text('Core (1)'), findsOneWidget);
    expect(find.text('Pro (1)'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('bar (1)'), findsOneWidget);
    expect(find.text('histogram (1)'), findsOneWidget);

    await tester.tap(find.text('Pro (1)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 1 of 2 families'), findsOneWidget);
    expect(find.text('Advanced'), findsWidgets);
    expect(find.text('Latency Histogram'), findsOneWidget);
    expect(find.text('Cartesian'), findsNothing);
    expect(find.text('All (1)'), findsOneWidget);
    expect(find.text('bar (1)'), findsNothing);
    expect(find.text('histogram (1)'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear filters'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(find.text('Advanced'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer keeps visible filtered family selected', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Latency'), findsNothing);

    await tester.tap(find.text('histogram (1)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Distribution'), findsWidgets);
    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);

    await tester.tap(find.text('All (2)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(find.text('Distribution'), findsWidgets);
    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer stats summarize visible scope', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testStatsFamilies,
      initialFamilyId: 'distribution',
      height: 900,
    );

    expect(find.text('Families 2'), findsOneWidget);
    expect(find.text('Samples 3'), findsOneWidget);
    expect(find.text('Types 3'), findsOneWidget);

    await tester.tap(find.text('histogram (1)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Families 1/2'), findsOneWidget);
    expect(find.text('Samples 1/3'), findsOneWidget);
    expect(find.text('Types 1/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer filters selected family sample details', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(tester, families: testMixedFamilies, height: 900);

    expect(find.text('Revenue Bars'), findsOneWidget);
    expect(find.text('Latency Histogram'), findsOneWidget);
    expect(find.text('Variance Violin'), findsOneWidget);

    await tester.tap(find.text('histogram (1)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 1 of 3 samples'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);
    expect(find.text('Latency Histogram'), findsOneWidget);
    expect(find.text('Variance Violin'), findsNothing);

    await tester.tap(find.text('All (1)'));
    await tester.pump(chartSamplePumpDuration);
    await tester.enterText(find.byType(TextField), 'variance');
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 1 of 3 samples'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);
    expect(find.text('Latency Histogram'), findsNothing);
    expect(find.text('Variance Violin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer sorts catalog families', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testSortFamilies,
      width: 520,
      height: 920,
    );

    double tileTop(String title) =>
        tester.getTopLeft(find.text(title).first).dy;

    expect(find.text('Sort: Curated'), findsOneWidget);
    expect(tileTop('Gamma'), lessThan(tileTop('Alpha')));

    await _selectExplorerSort(tester, 'Name');

    expect(find.text('Sort: Name'), findsOneWidget);
    expect(tileTop('Alpha'), lessThan(tileTop('Beta')));
    expect(tileTop('Beta'), lessThan(tileTop('Gamma')));

    await _selectExplorerSort(tester, 'Samples');

    expect(find.text('Sort: Samples'), findsOneWidget);
    expect(tileTop('Beta'), lessThan(tileTop('Alpha')));
    expect(tileTop('Alpha'), lessThan(tileTop('Gamma')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer clear button resets combined filters', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    await tester.tap(find.text('histogram (1)'));
    await tester.pump(chartSamplePumpDuration);
    await tester.enterText(find.byType(TextField), 'revenue');
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('No chart families found'), findsOneWidget);
    expect(find.text('Showing 0 of 2 families'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear filters'));
    await tester.pump(chartSamplePumpDuration);

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(find.text('Distribution'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample family explorer type chips apply type filters', (
    WidgetTester tester,
  ) async {
    await _pumpExplorer(
      tester,
      families: testBaseFamilies,
      initialFamilyId: 'cartesian',
    );

    await tester.tap(find.byTooltip('Filter histogram'));
    await tester.pump(chartSamplePumpDuration);

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('Showing 1 of 2 families'), findsOneWidget);
    expect(find.text('Distribution'), findsWidgets);
    expect(find.text('Latency'), findsOneWidget);
    expect(find.text('Revenue Bars'), findsNothing);

    await tester.tap(find.text('All (2)'));
    await tester.pump(chartSamplePumpDuration);

    expect(find.text('Showing 2 families'), findsOneWidget);
    expect(find.text('Cartesian'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpExplorer(
  WidgetTester tester, {
  required List<ChartShowcaseFamily> families,
  String? initialFamilyId,
  double width = 820,
  double height = 720,
}) async {
  await pumpChartSampleBody(
    tester,
    width: width,
    height: height,
    child: ChartSampleFamilyExplorer(
      families: families,
      initialFamilyId: initialFamilyId,
      options: const ChartSampleShowcaseOptions(
        showSampleJson: false,
        showSampleCode: false,
      ),
    ),
  );
}

Future<void> _selectExplorerSort(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Sort chart families'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
