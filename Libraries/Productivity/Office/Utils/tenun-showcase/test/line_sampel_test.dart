import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/line_sampel.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  test('LineChartPainter requests repaint for legacy chart updates', () {
    final series = [
      ChartSeries(
        name: 'Revenue',
        color: Colors.blue,
        points: [ChartPoint(1, 10), ChartPoint(2, 25)],
      ),
    ];
    final first = LineChartPainter(
      series: series,
      config: const LineChartConfig(type: ChartType.single),
      animationValue: 0.4,
    );
    final second = LineChartPainter(
      series: series,
      config: const LineChartConfig(type: ChartType.single),
      animationValue: 1,
    );

    expect(second.shouldRepaint(first), isTrue);
  });

  testWidgets('ModernLineChart renders line_sampel sample', (tester) async {
    await pumpShowcaseBody(
      tester,
      width: 520,
      height: 360,
      settle: true,
      child: ModernLineChart(
        title: 'Legacy Line',
        xAxisLabel: 'X',
        yAxisLabel: 'Y',
        series: [
          ChartSeries(
            name: 'Revenue',
            color: Colors.blue,
            fill: true,
            points: [
              ChartPoint(1, 10),
              ChartPoint(2, 25),
              ChartPoint(3, 15),
              ChartPoint(4, 35),
            ],
          ),
        ],
      ),
    );

    expect(find.byType(ModernLineChart), findsOneWidget);
    expect(find.text('Legacy Line'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
