import 'package:flutter/material.dart';

import 'line_sampel_2_chart.dart';
import 'line_sampel_2_models.dart';

// Replace LineChartExample with a minimal, clean test page
class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final testSeries = [
      ChartSeries(
        name: 'Test',
        color: Colors.blue,
        points: [
          ChartPoint(1, 10, label: 'A'),
          ChartPoint(2, 30, label: 'B'),
          ChartPoint(3, 20, label: 'C'),
          ChartPoint(4, 50, label: 'D'),
          ChartPoint(5, 40, label: 'E'),
        ],
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Tooltip Test')),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 300,
          child: ModernLineChart(
            title: 'Test Chart',
            series: testSeries,
            xAxisLabel: 'X',
            yAxisLabel: 'Y',
            config: LineChartConfig(enableTooltip: true),
          ),
        ),
      ),
    );
  }
}
