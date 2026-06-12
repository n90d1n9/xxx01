import 'package:flutter/material.dart';

import 'line_sample_3_chart.dart';
import 'line_sample_3_models.dart';

// Example usage widget
class ChartExample extends StatelessWidget {
  const ChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for single line
    final singleSeries = [
      ChartSeries(
        name: 'Revenue',
        color: const Color(0xFF3B82F6),
        points: [
          ChartPoint(1, 10),
          ChartPoint(2, 15),
          ChartPoint(3, 8),
          ChartPoint(4, 22),
          ChartPoint(5, 18),
          ChartPoint(6, 25),
          ChartPoint(7, 30),
          ChartPoint(8, 27),
          ChartPoint(9, 35),
          ChartPoint(10, 32),
        ],
      ),
    ];

    // Sample data for multiple lines
    final multiSeries = [
      ChartSeries(
        name: 'Revenue',
        color: const Color(0xFF3B82F6),
        strokeWidth: 2.5,
        points: [
          ChartPoint(1, 10),
          ChartPoint(2, 15),
          ChartPoint(3, 8),
          ChartPoint(4, 22),
          ChartPoint(5, 18),
          ChartPoint(6, 25),
          ChartPoint(7, 30),
        ],
      ),
      ChartSeries(
        name: 'Profit',
        color: const Color(0xFF10B981),
        strokeWidth: 2.5,
        points: [
          ChartPoint(1, 5),
          ChartPoint(2, 8),
          ChartPoint(3, 6),
          ChartPoint(4, 12),
          ChartPoint(5, 15),
          ChartPoint(6, 18),
          ChartPoint(7, 20),
        ],
      ),
      ChartSeries(
        name: 'Expenses',
        color: const Color(0xFFEF4444),
        strokeWidth: 2.5,
        points: [
          ChartPoint(1, 8),
          ChartPoint(2, 12),
          ChartPoint(3, 10),
          ChartPoint(4, 16),
          ChartPoint(5, 14),
          ChartPoint(6, 19),
          ChartPoint(7, 22),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Modern Line Chart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Single line chart
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ModernLineChart(
                  series: singleSeries,
                  title: 'Single Line Chart',
                  xAxisLabel: 'Time (months)',
                  yAxisLabel: 'Revenue (k)',
                  showGrid: true,
                  showAxes: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Multi line chart
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ModernLineChart(
                  series: multiSeries,
                  title: 'Multi-line Chart',
                  xAxisLabel: 'Time (months)',
                  yAxisLabel: 'Amount (k)',
                  showGrid: true,
                  showAxes: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
