import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/helper.dart';
import 'bar_config.dart';

class BarChartWidget extends StatelessWidget {
  final BarChartConfig config;

  const BarChartWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final maxY =
        config.maxY > 0 ? config.maxY : config.getMaxSeriesValue() * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              config.title!.text!,
              style: TextStyle(
                fontSize: config.title!.fontSize,
                fontWeight: FontWeight.bold,
                color: config.title!.color,
              ),
            ),
          ),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: config.alignment,
              maxY: maxY,
              barGroups: _createBarGroups(),
              gridData: _createGridData(),
              titlesData: _createTitlesData(),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              barTouchData: _createBarTouchData(),
            ),
          ),
        ),
        if (config.legend != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _createLegend(),
          ),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    final groups = <BarChartGroupData>[];
    final seriesLength = config.series.length;

    if (config.series.isEmpty || config.series.first.data == null) {
      return groups;
    }

    final firstSeriesData = config.series.first.data as List<dynamic>;

    for (int i = 0; i < firstSeriesData.length; i++) {
      final rods = <BarChartRodData>[];

      for (int seriesIndex = 0; seriesIndex < seriesLength; seriesIndex++) {
        final series = config.series[seriesIndex];
        final seriesData = series.data as List<dynamic>;

        if (i < seriesData.length) {
          final value = seriesData[i] is num ? seriesData[i].toDouble() : 0.0;

          rods.add(
            BarChartRodData(
              toY: value,
              color: series.color ?? getDefaultSeriesColor(seriesIndex),
              width: config.barWidth,
              borderRadius: config.barBorderRadius,
            ),
          );
        }
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: rods,
        ),
      );
    }

    return groups;
  }

  FlGridData _createGridData() {
    return FlGridData(
      show: config.grid?.show ?? true,
      drawHorizontalLine: config.grid!.showHorizontalLines,
      drawVerticalLine: config.grid?.showVerticalLines ?? false,
      horizontalInterval: config.grid?.horizontalInterval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: stringToColor(config.grid!.horizontalColor),
          strokeWidth: config.grid?.horizontalWidth ?? 0.5,
          dashArray: config.grid?.horizontalDashArray,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: stringToColor(config.grid!.verticalColor),
          strokeWidth: config.grid?.verticalWidth ?? 0.5,
          dashArray: config.grid?.verticalDashArray,
        );
      },
    );
  }

  FlTitlesData _createTitlesData() {
    return FlTitlesData(
      bottomTitles: _createBottomTitles(),
      leftTitles: _createLeftTitles(),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  AxisTitles _createBottomTitles() {
    if (config.xAxis?.show == false) {
      return const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );
    }

    return AxisTitles(
      axisNameWidget: config.xAxis?.name != null
          ? Text(
              config.xAxis!.name!,
              style: TextStyle(
                color: stringToColor(config.xAxis!.nameColor),
                fontSize: config.xAxis?.nameSize,
              ),
            )
          : null,
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final int idx = value.toInt();
          String title = '';

          if (config.xAxis?.data != null &&
              config.xAxis!.data!.isNotEmpty &&
              idx < config.xAxis!.data!.length) {
            title = config.xAxis!.data![idx].toString();
          } else if (config.series.isNotEmpty &&
              config.series.first.dataLabels != null &&
              idx < config.series.first.dataLabels!.length) {
            title = config.series.first.dataLabels![idx].toString();
          } else {
            title = value.toInt().toString();
          }

          return Text(
            title,
            style: TextStyle(
              color: stringToColor(config.xAxis!.color),
              fontSize: config.xAxis?.fontSize ?? 10,
            ),
          );
        },
        reservedSize: 28,
      ),
    );
  }

  AxisTitles _createLeftTitles() {
    if (config.yAxis?.show == false) {
      return const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );
    }

    return AxisTitles(
      axisNameWidget: config.yAxis?.name != null
          ? Text(
              config.yAxis!.name!,
              style: TextStyle(
                color: stringToColor(config.yAxis!.nameColor),
                fontSize: config.yAxis?.nameSize,
              ),
            )
          : null,
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String title = '';

          if (config.yAxis?.formatter != null) {
            // Apply custom formatter
            title = config.yAxis!.formatter!(value);
          } else {
            title = value.toInt().toString();
          }

          return Text(
            title,
            style: TextStyle(
              color: stringToColor(config.yAxis!.color),
              fontSize: config.yAxis?.fontSize ?? 10,
            ),
          );
        },
        reservedSize: 40,
      ),
    );
  }

  BarTouchData _createBarTouchData() {
    return BarTouchData(
      enabled: config.tooltip?.show ?? true,
      touchTooltipData: BarTouchTooltipData(
        //tooltipBgColor:
        //  config.tooltip?.backgroundColor ?? Colors.white.withOpacity(0.8),
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final series = config.series[rodIndex];
          String label = series.name ?? '';

          if (series.dataLabels != null &&
              groupIndex < series.dataLabels!.length) {
            label = series.dataLabels![groupIndex].toString();
          }

          final value = rod.toY;
          String formattedValue = value.toString();

          if (config.tooltip?.formatter != null) {
            formattedValue = config.tooltip!.formatter!;
          } else if (config.tooltip?.numberFormat != null) {
            formattedValue = value.toStringAsFixed(1);
          }

          return BarTooltipItem(
            '$label: $formattedValue',
            TextStyle(
              color: stringToColor(config.tooltip!.textColor),
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget _createLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: config.series.map((series) {
        final color = series.color ?? Colors.blue;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              series.name ?? '',
              style: TextStyle(
                color: stringToColor(config.legend!.textColor),
                fontSize: config.legend?.fontSize ?? 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
