import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/dashboard_analytics.dart';

class HiringTrendsChart extends StatelessWidget {
  final List<HiringTrendPoint> hiringData;

  const HiringTrendsChart({super.key, required this.hiringData});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.show_chart_outlined,
      title: 'Hiring trends',
      subtitle: 'Monthly hiring volume across the selected period',
      emptyMessage: 'No hiring trend data available',
      children:
          hiringData.isEmpty
              ? []
              : [
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems:
                              (spots) =>
                                  spots.map((spot) {
                                    final point = hiringData[spot.x.toInt()];
                                    return LineTooltipItem(
                                      '${point.month}: ${point.hires.round()} hires',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine:
                            (value) => const FlLine(
                              color: HrisColors.border,
                              strokeWidth: 1,
                            ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget:
                                (value, meta) => SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    _monthLabel(value.toInt()),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: HrisColors.muted),
                                  ),
                                ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 32,
                            getTitlesWidget:
                                (value, meta) => SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    '${value.toInt()}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: HrisColors.muted),
                                  ),
                                ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: HrisColors.border),
                          left: BorderSide(color: HrisColors.border),
                        ),
                      ),
                      minX: 0,
                      maxX: hiringData.length - 1,
                      minY: 0,
                      maxY: 30,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots(),
                          isCurved: true,
                          color: HrisColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: HrisColors.primary.withValues(alpha: 0.14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
    );
  }

  List<FlSpot> _spots() {
    return List.generate(
      hiringData.length,
      (index) => FlSpot(index.toDouble(), hiringData[index].hires),
    );
  }

  String _monthLabel(int index) {
    if (index < 0 || index >= hiringData.length) return '';
    return hiringData[index].month;
  }
}
