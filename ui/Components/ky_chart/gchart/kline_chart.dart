import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import '../lib/model/chart_model.dart';
import '../lib/model/series.dart';

class KLineChart extends StatefulWidget {
  final ChartConfig config;
  final List<Series> series;
  const KLineChart({super.key, required this.series, required this.config});

  @override
  State<KLineChart> createState() => _KLineChartState();
}

class _KLineChartState extends State<KLineChart> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: _buildLineChartBars(),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(0));
                },
              ),
            ),
          ),
          gridData: const FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
          ),
          borderData: FlBorderData(show: true),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final country = countries[spot.barIndex];
                  final year = spot.x.toInt();
                  final income = spot.y;
                  return LineTooltipItem(
                    '$country ($year): $income',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineChartBars() {
    
    return widget.series.map((series) {
      print(series);

      // Filter data for each country from 1950 onwards
      //[[Income, Life Expectancy, Population, Country, Year],
      //[815, 34.05, 351014, Australia, 1800],
      //[1314, 39, 645526, Canada, 1800], [985, 32, 321675013, China, 1800],
      //[864, 32.2, 345043, Cuba, 1800], [1244, 36.5731262, 977662, Finland, 1800],
      //[1803, 33.96717024, 29355111, France, 1800],

      final countryData = _rawData
          .where((item) => item[3] == country && item[4] >= 1950)
          .toList();

      return LineChartBarData(
        isCurved: true,
        color: getRandomColor(),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: countryData.map((item) {
          return FlSpot(double.parse(item[4].toString()),
              double.parse(item[2].toString()));
        }).toList(),
      );
    }).toList();
  }
}
