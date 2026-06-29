import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/shared_dict.dart';

class MemoryUsageChart extends StatelessWidget {
  final List<SharedDictMetric> metrics;

  const MemoryUsageChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    // Sort metrics by usage percentage (descending)
    final sortedMetrics = [...metrics];
    sortedMetrics.sort(
      (a, b) => b.usagePercentage.compareTo(a.usagePercentage),
    );

    // Take top 10 for readability
    final topMetrics = sortedMetrics.take(10).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 10 Memory Dictionaries by Usage',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    //tooltipBgColor: Theme.of(context).colorScheme.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final metric = topMetrics[group.x.toInt()];
                      return BarTooltipItem(
                        '${metric.name}\n${metric.usagePercentage.toStringAsFixed(2)}%\n'
                        'Used: ${_formatBytes(metric.capacityBytes - metric.freeSpaceBytes)}\n'
                        'Capacity: ${_formatBytes(metric.capacityBytes)}',
                        TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= topMetrics.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _shortenName(topMetrics[value.toInt()].name),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    right: BorderSide(color: Colors.transparent, width: 0),
                    top: BorderSide(color: Colors.transparent, width: 0),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(topMetrics.length, (index) {
                  final metric = topMetrics[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: metric.usagePercentage,
                        color: _getUsageColor(metric.usagePercentage),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortenName(String name) {
    if (name.length <= 8) return name;
    return '${name.substring(0, 7)}...';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _getUsageColor(double usagePercentage) {
    if (usagePercentage > 80) return Colors.red;
    if (usagePercentage > 60) return Colors.orange;
    if (usagePercentage > 40) return Colors.amber;
    return Colors.green;
  }
}
