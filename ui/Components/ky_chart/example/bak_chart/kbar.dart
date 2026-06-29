import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ky_chart/utils/fl_chart_helper.dart';

import '../model/chart_model.dart';

class KBar extends StatelessWidget {
  final ChartConfig config;
  const KBar({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: config.maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${config.series[rodIndex].name}\n${rod.toY.round()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        barGroups: List.generate(config.xAxis!.data!.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: List.generate(config.series.length, (seriesIndex) {
              final series = config.series[seriesIndex];
              return BarChartRodData(
                toY: series.data![index].toDouble(),
                color: series.itemStyle!.color!,
                width: 16,
                borderRadius: BorderRadius.zero,
              );
            }),
          );
        }),
        gridData: gridData(config),
        titlesData: titlesData(config),
        borderData: borderData(config),
      ),
    );
  }
}
