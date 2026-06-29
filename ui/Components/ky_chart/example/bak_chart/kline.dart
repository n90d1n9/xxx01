import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ky_chart/utils/fl_chart_helper.dart';
import 'package:ky_chart/model/chart_type.dart';
import 'package:ky_chart/utils/helper.dart';

import '../model/chart_model.dart';

class KLine extends StatelessWidget {
  final ChartConfig config;
  const KLine({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final axisLabels = config.xAxis!.data!;

    return LineChart(LineChartData(
      minX: 0,
      maxX: axisLabels.length - 1.0,
      minY: 0,
      maxY: config.maxY,
      lineBarsData: _getLineBarsData(),
      lineTouchData: _lineTouchData(config),
      gridData: gridData(config),
      titlesData: titlesData(config),
      borderData: borderData(config),
    ));
  }

  List<LineChartBarData> _getLineBarsData() {
    /*  List<List<double>> stackedValues = List.generate(
      config.xAxis!.data!.length,
      (index) => List.filled(config.series.length, 0.0),
    ); */

    return List.generate(config.series.length, (seriesIndex) {
      return LineChartBarData(
          spots: List.generate(config.xAxis!.data!.length, (xAxisIndex) {
            return FlSpot(xAxisIndex.toDouble(),
                config.series[seriesIndex].data![xAxisIndex]); 
          }),
          isCurved: false,
          color:
              config.series[seriesIndex].itemStyle!.color ?? getRandomColor(),
          belowBarData: BarAreaData(
            show: config.type == ChartType.lineArea ? true : false,
            color: config.series[seriesIndex].itemStyle!.color!.withOpacity(0.2)
                //getRandomColor().withOpacity(0.1),
          )
          // config.type == ChartType.lineArea ? _area(seriesIndex) : null,
          );
    }).reversed.toList(); // Reverse to match ECharts stacking order
  }

  _area(seriesIndex) => BarAreaData(
        show: true,
        color: config.series[seriesIndex].itemStyle!.color ??
            getRandomColor().withOpacity(0.1),
      );

  _lineTouchData(ChartConfig config) {
    final seriesData = config.series;
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final seriesIndex = seriesData.length - 1 - spot.barIndex;
            return LineTooltipItem(
              '${seriesData[seriesIndex].name}: ${spot.y.toInt()}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
