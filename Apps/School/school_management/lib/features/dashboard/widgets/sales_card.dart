import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';

class SalesChart extends StatelessWidget {
  final List<SalesDataPoint> salesData;

  const SalesChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(DateFormat('EEE').format(day));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: salesData.first.date.millisecondsSinceEpoch.toDouble(),
          maxX: salesData.last.date.millisecondsSinceEpoch.toDouble(),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: salesData
                  .map((data) => FlSpot(
                      data.date.millisecondsSinceEpoch.toDouble(),
                      data.currentWeekSales.toDouble()))
                  .toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: salesData
                  .map((data) => FlSpot(
                      data.date.millisecondsSinceEpoch.toDouble(),
                      data.previousWeekSales.toDouble()))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final salesPoint = salesData.firstWhere((element) =>
                      element.date.millisecondsSinceEpoch.toDouble() == spot.x);
                  return LineTooltipItem(
                    'Current Week: \$${salesPoint.currentWeekSales.toStringAsFixed(0)}\nPrevious Week: \$${salesPoint.previousWeekSales.toStringAsFixed(0)}',
                    const TextStyle(color: Colors.black),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
