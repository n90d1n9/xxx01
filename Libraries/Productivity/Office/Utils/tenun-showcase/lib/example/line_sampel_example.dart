import 'package:flutter/material.dart';

import 'line_sampel_chart.dart';
import 'line_sampel_models.dart';

// Example usage widget
class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final singleSeries = [
      ChartSeries(
        name: 'Revenue',
        color: Colors.blue,
        strokeWidth: 3,
        fill: true,
        points: [
          ChartPoint(1, 10),
          ChartPoint(2, 25),
          ChartPoint(3, 15),
          ChartPoint(4, 35),
          ChartPoint(5, 28),
          ChartPoint(6, 42),
          ChartPoint(7, 38),
        ],
      ),
    ];

    final multiSeries = [
      ChartSeries(
        name: 'Series 1',
        color: Colors.blue,
        strokeWidth: 2,
        points: [
          ChartPoint(1, 10),
          ChartPoint(2, 25),
          ChartPoint(3, 15),
          ChartPoint(4, 35),
          ChartPoint(5, 28),
        ],
      ),
      ChartSeries(
        name: 'Series 2',
        color: Colors.red,
        strokeWidth: 2,
        points: [
          ChartPoint(1, 5),
          ChartPoint(2, 15),
          ChartPoint(3, 25),
          ChartPoint(4, 20),
          ChartPoint(5, 35),
        ],
      ),
      ChartSeries(
        name: 'Series 3',
        color: Colors.green,
        strokeWidth: 2,
        points: [
          ChartPoint(1, 8),
          ChartPoint(2, 12),
          ChartPoint(3, 18),
          ChartPoint(4, 15),
          ChartPoint(5, 22),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Line Charts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Single line chart
            SizedBox(
              height: 300,
              child: ModernLineChart(
                title: 'Single Line Chart',
                series: singleSeries,
                xAxisLabel: 'Time',
                yAxisLabel: 'Value',
                config: const LineChartConfig(
                  type: ChartType.single,
                  showLegend: false,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Multi-line chart
            SizedBox(
              height: 300,
              child: ModernLineChart(
                title: 'Multi-line Chart',
                series: multiSeries,
                xAxisLabel: 'Time',
                yAxisLabel: 'Value',
                config: const LineChartConfig(type: ChartType.multiline),
              ),
            ),
            const SizedBox(height: 32),

            // Stacked chart
            SizedBox(
              height: 300,
              child: ModernLineChart(
                title: 'Stacked Area Chart',
                series: multiSeries,
                xAxisLabel: 'Time',
                yAxisLabel: 'Cumulative Value',
                config: const LineChartConfig(type: ChartType.stacked),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
