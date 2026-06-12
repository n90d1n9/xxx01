import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/line_sample_3.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  test('LineChartPainter repaints when animation changes', () {
    final series = [
      ChartSeries(
        name: 'Revenue',
        color: Colors.blue,
        points: [ChartPoint(1, 10), ChartPoint(2, 20)],
      ),
    ];
    final first = LineChartPainter(
      series: series,
      showGrid: true,
      showAxes: true,
      padding: const EdgeInsets.all(40),
      gridColor: Colors.grey,
      axisColor: Colors.black54,
      animationValue: 0.2,
      titleHeight: 20,
      legendHeight: 0,
    );
    final second = LineChartPainter(
      series: series,
      showGrid: true,
      showAxes: true,
      padding: const EdgeInsets.all(40),
      gridColor: Colors.grey,
      axisColor: Colors.black54,
      animationValue: 1,
      titleHeight: 20,
      legendHeight: 0,
    );

    expect(second.shouldRepaint(first), isTrue);
  });

  testWidgets('ModernLineChart renders line_sample_3 sample', (tester) async {
    await pumpShowcaseBody(
      tester,
      width: 520,
      height: 360,
      settle: true,
      child: ModernLineChart(
        title: 'Sample 3',
        xAxisLabel: 'X',
        yAxisLabel: 'Y',
        series: [
          ChartSeries(
            name: 'Revenue',
            color: Colors.blue,
            points: [
              ChartPoint(1, 10),
              ChartPoint(2, 15),
              ChartPoint(3, 8),
              ChartPoint(4, 22),
            ],
          ),
        ],
      ),
    );

    expect(find.byType(ModernLineChart), findsOneWidget);
    expect(find.text('Sample 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
