import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/dashboard_analytics.dart';

class DepartmentPerformanceChart extends StatelessWidget {
  final List<DepartmentPerformancePoint> departmentData;

  const DepartmentPerformanceChart({super.key, required this.departmentData});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.bar_chart_outlined,
      title: 'Department performance',
      subtitle: 'Current score compared with the previous period',
      emptyMessage: 'No department performance data available',
      children:
          departmentData.isEmpty
              ? []
              : [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ChartLegend(color: HrisColors.primary, label: 'Current'),
                    SizedBox(width: 12),
                    _ChartLegend(color: Colors.blueGrey, label: 'Previous'),
                  ],
                ),
                SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final point = departmentData[group.x.toInt()];
                            return BarTooltipItem(
                              '${point.department}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${rod.toY.round()}%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
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
                                    _shortLabel(value.toInt()),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: HrisColors.muted),
                                  ),
                                ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 38,
                            getTitlesWidget:
                                (value, meta) => SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    '${value.toInt()}%',
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
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        horizontalInterval: 20,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (value) => const FlLine(
                              color: HrisColors.border,
                              strokeWidth: 1,
                            ),
                      ),
                      barGroups: _barGroups(),
                    ),
                  ),
                ),
              ],
    );
  }

  List<BarChartGroupData> _barGroups() {
    return List.generate(departmentData.length, (index) {
      final point = departmentData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: point.current,
            color: HrisColors.primary,
            width: 14,
            borderRadius: BorderRadius.circular(3),
          ),
          BarChartRodData(
            toY: point.previous,
            color: Colors.blueGrey,
            width: 14,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    });
  }

  String _shortLabel(int index) {
    if (index < 0 || index >= departmentData.length) return '';
    final department = departmentData[index].department;
    return department.length <= 4 ? department : department.substring(0, 4);
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}
