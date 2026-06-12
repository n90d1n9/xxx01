import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_pro/tenun_pro.dart';
import 'package:tenun_showcase/example/interaction_reliability_lab_config.dart';
import 'package:tenun_showcase/example/interaction_reliability_lab_data.dart';
import 'package:tenun_showcase/example/interaction_reliability_lab_example.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  Future<void> pumpLab(WidgetTester tester) async {
    await pumpShowcaseBody(
      tester,
      physicalSize: const Size(1400, 1200),
      width: 1200,
      height: 900,
      settle: true,
      child: const InteractionReliabilityLabExample(),
    );
  }

  testWidgets('toggles data mode and sampling controls', (
    WidgetTester tester,
  ) async {
    await pumpLab(tester);

    expect(find.text('Interaction Reliability Lab'), findsOneWidget);
    expect(find.textContaining('Sampling Threshold:'), findsOneWidget);

    final dataModeDropdown = find.byType(
      DropdownButtonFormField<ChartDataMode>,
    );
    expect(dataModeDropdown, findsOneWidget);

    await tester.tap(dataModeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('regular').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Sampling Threshold:'), findsNothing);

    await tester.tap(dataModeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('large').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Sampling Threshold:'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Tooltip'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('drilldown tap shows back button and reset returns root', (
    WidgetTester tester,
  ) async {
    await pumpLab(tester);

    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);

    final drillChart = find.byWidgetPredicate(
      (w) => w is ZoomableTenunChart && w.drillController != null,
      description: 'drilldown zoomable chart',
    );
    expect(drillChart, findsOneWidget);

    final drillWidget = tester.widget<ZoomableTenunChart>(drillChart);
    final tempZoom = ChartZoomController();
    drillWidget.onTap?.call(0.5, tempZoom);
    await tester.pumpAndSettle();
    tempZoom.dispose();

    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);

    expect(tester.takeException(), isNull);
  });

  test('data helpers generate, aggregate, trim, and coerce drill data', () {
    final series = buildInteractionReliabilitySeries(120);
    expect(series.signal, hasLength(120));
    expect(series.volume, hasLength(120));

    final aggregated = aggregateInteractionReliabilityData(
      List<double>.generate(12, (index) => index + 1.0),
      buckets: 3,
    );
    expect(aggregated, <double>[2.5, 6.5, 10.5]);

    final trimmed = trimInteractionReliabilityData(
      List<double>.generate(10, (index) => index.toDouble()),
      maxPoints: 4,
    );
    expect(trimmed, <double>[0, 3, 6, 9]);

    final config = buildInteractionCartesianConfig(
      type: ChartType.line,
      title: 'Helper Test',
      seriesName: 'Series',
      values: const [1, 2, 3],
      colorValue: 0xFF2563EB,
      dataMode: ChartDataMode.regular,
      samplingThreshold: 100,
      samplingStrategy: null,
      showLegend: true,
      showTooltip: true,
    );
    final level = DrillDownLevel(
      id: 'mixed',
      label: 'Mixed',
      data: const [1, 'skip', 2.5],
      config: config,
    );

    expect(extractInteractionDrillData(level), <double>[1, 2.5]);
  });

  test('sampling payload mirrors chart data mode controls', () {
    final largePayload = buildInteractionSamplingPayload(
      dataMode: ChartDataMode.large,
      samplingThreshold: 500,
      samplingStrategy: SamplingStrategy.minMax,
    );
    final largeSampling = largePayload['sampling'] as Map<String, dynamic>;

    expect(largePayload['dataMode'], 'large');
    expect(largeSampling['enabled'], isTrue);
    expect(largeSampling['threshold'], 500);
    expect(largeSampling['strategy'], 'minMax');

    final regularPayload = buildInteractionSamplingPayload(
      dataMode: ChartDataMode.regular,
      samplingThreshold: 500,
      samplingStrategy: null,
    );
    final regularSampling = regularPayload['sampling'] as Map<String, dynamic>;

    expect(regularPayload['dataMode'], 'regular');
    expect(regularSampling['enabled'], isFalse);
    expect(regularSampling.containsKey('strategy'), isFalse);
  });
}
