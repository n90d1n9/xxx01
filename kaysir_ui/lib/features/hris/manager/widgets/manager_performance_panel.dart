import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/hris_ui.dart';
import '../models/manager_models.dart';

class ManagerPerformancePanel extends StatelessWidget {
  final TeamMetricSnapshot metrics;

  const ManagerPerformancePanel({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Team performance',
      subtitle: 'Weekly delivery pulse and health indicators',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Productivity',
              value: '${metrics.productivity}%',
            ),
            HrisMetricStripItem(
              label: 'Satisfaction',
              value: '${metrics.satisfaction}%',
            ),
            HrisMetricStripItem(
              label: 'Completion',
              value: '${metrics.taskCompletion}%',
            ),
          ],
        ),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine:
                    (value) => FlLine(
                      color: HrisColors.border,
                      strokeWidth: value == 0 ? 0 : 1,
                    ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      if (value < 0 || value >= days.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        days[value.toInt()],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: HrisColors.muted,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    metrics.weeklyData.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      metrics.weeklyData[index].toDouble(),
                    ),
                  ),
                  isCurved: true,
                  color: HrisColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: HrisColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
