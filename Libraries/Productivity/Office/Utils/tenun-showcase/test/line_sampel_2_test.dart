import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/line_sampel_2.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  test('DataWindow keeps only the latest points', () {
    final window = DataWindow(3);

    for (int i = 0; i < 5; i++) {
      window.addPoint(ChartPoint(i.toDouble(), i * 10));
    }

    expect(window.points, hasLength(3));
    expect(window.points.first.x, 2);
    expect(window.points.last.y, 40);

    window.clear();
    expect(window.points, isEmpty);
  });

  test('LineChartProvider calculates bounds and manages viewport state', () {
    final provider = LineChartProvider();
    addTearDown(provider.dispose);

    provider.setData([
      ChartSeries(
        name: 'Signal',
        color: Colors.blue,
        points: List.generate(
          160,
          (index) => ChartPoint(index.toDouble(), (index % 12).toDouble()),
        ),
      ),
    ]);

    expect(provider.error, isNull);
    expect(provider.dataBounds, isNotNull);
    expect(provider.optimizedSeries, hasLength(1));
    expect(provider.optimizedSeries.single.points, isNotEmpty);

    provider.updateZoom(3, Offset.zero);
    expect(provider.zoomLevel, 3);

    provider.updatePan(const Offset(8, -4));
    expect(provider.panOffset, const Offset(8, -4));

    provider.resetZoomAndPan();
    expect(provider.zoomLevel, 1);
    expect(provider.panOffset, Offset.zero);
  });

  test('TooltipDetector respects the supplied hit tolerance', () {
    final series = [
      ChartSeries(
        name: 'Signal',
        color: Colors.blue,
        points: [ChartPoint(0, 0), ChartPoint(10, 10)],
      ),
    ];
    final bounds = ChartBounds(minX: 0, maxX: 10, minY: 0, maxY: 10);
    const chartArea = Rect.fromLTWH(0, 0, 100, 100);

    final near = TooltipDetector.detectNearestPoint(
      tapPosition: const Offset(1, 99),
      series: series,
      chartArea: chartArea,
      bounds: bounds,
      tolerance: 4,
    );
    final far = TooltipDetector.detectNearestPoint(
      tapPosition: const Offset(12, 88),
      series: series,
      chartArea: chartArea,
      bounds: bounds,
      tolerance: 4,
    );

    expect(near?.point.x, 0);
    expect(far, isNull);
  });

  testWidgets('ModernLineChart renders a simple legacy sample', (tester) async {
    await pumpShowcaseBody(
      tester,
      width: 520,
      height: 360,
      settle: true,
      child: ModernLineChart(
        title: 'Legacy Sample',
        xAxisLabel: 'X',
        yAxisLabel: 'Y',
        series: [
          ChartSeries(
            name: 'A',
            color: Colors.blue,
            points: [
              ChartPoint(1, 10, label: 'A'),
              ChartPoint(2, 30, label: 'B'),
              ChartPoint(3, 20, label: 'C'),
            ],
          ),
        ],
      ),
    );

    expect(find.byType(ModernLineChart), findsOneWidget);
    expect(find.text('Legacy Sample'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
