import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/helper.dart';
import 'line_config.dart';

class LineChartWidget extends StatelessWidget {
  final LineChartConfig config;

  const LineChartWidget({
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
          child: LineChart(
            LineChartData(
              maxY: maxY,
              lineBarsData: _createLineData(),
              gridData: _createGridData(),
              titlesData: _createTitlesData(),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              lineTouchData: _createLineTouchData(),
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

  List<LineChartBarData> _createLineData() {
    final lineBars = <LineChartBarData>[];

    for (int i = 0; i < config.series.length; i++) {
      final series = config.series[i];

      if (series.data == null || series.data!.isEmpty) {
        continue;
      }

      final spots = <FlSpot>[];

      for (int j = 0; j < series.data!.length; j++) {
        final value = series.data![j] is num ? series.data![j].toDouble() : 0.0;
        spots.add(FlSpot(j.toDouble(), value));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: config.curveSmoothness > 0,
          curveSmoothness: config.curveSmoothness,
          color: series.color ?? getDefaultSeriesColor(i),
          barWidth: series.width ?? 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: config.showDots,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: config.dotSize / 2,
              color: series.color ?? getDefaultSeriesColor(i),
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: config.showBelowArea,
            color: (series.color ?? getDefaultSeriesColor(i)).withOpacity(0.2),
          ),
        ),
      );
    }

    return lineBars;
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
          return Text(
            config.yAxis?.formatter != null
                ? config.yAxis!.formatter!(value)
                : value.toStringAsFixed(config.yAxis?.precision ?? 0),
            style: TextStyle(
              color: stringToColor(config.yAxis!.color),
              fontSize: config.yAxis?.fontSize ?? 10,
            ),
          );
        },
        reservedSize: 40,
        interval: config.yAxis!.interval?.toDouble(),
      ),
    );
  }

  LineTouchData _createLineTouchData() {
    if (config.tooltip?.show == false) {
      return const LineTouchData(enabled: false);
    }

    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        //tooltipBgColor: config.tooltip?.backgroundColor ?? Colors.blueGrey.shade800,
        tooltipRoundedRadius: config.tooltip?.borderRadius ?? 8,
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final seriesIndex = spot.barIndex;
            final series = config.series[seriesIndex];
            final dataIndex = spot.spotIndex;

            String label = '';
            if (series.dataLabels != null &&
                dataIndex < series.dataLabels!.length) {
              label = series.dataLabels![dataIndex].toString();
            } else if (config.xAxis?.data != null &&
                dataIndex < config.xAxis!.data!.length) {
              label = config.xAxis!.data![dataIndex].toString();
            } else {
              label = 'Point ${dataIndex + 1}';
            }

            final value = spot.y;
            final valueFormatted = config.tooltip?.valueFormatter != null
                ? config.tooltip!.valueFormatter!(value)
                : value.toStringAsFixed(config.tooltip?.precision ?? 1);

            return LineTooltipItem(
              '${series.name ?? 'Series ${seriesIndex + 1}'}\n$label: $valueFormatted',
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: config.tooltip?.fontSize ?? 12,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _createLegend() {
    final legend = config.legend!;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(
        config.series.length,
        (index) {
          final series = config.series[index];
          final color = series.color ?? getDefaultSeriesColor(index);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: legend.iconSize,
                height: legend.iconSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular((legend.iconSize) / 2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                series.name ?? 'Series ${index + 1}',
                style: TextStyle(
                  fontSize: legend.fontSize,
                  color: stringToColor(legend.textColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
