import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesEvolutionChart2 extends StatefulWidget {
  const SalesEvolutionChart2({super.key});

  @override
  State<SalesEvolutionChart2> createState() => _SalesEvolutionChartState();
}

class _SalesEvolutionChartState extends State<SalesEvolutionChart2> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
          gridData: const FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, titleMeta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Jan');
                    case 1:
                      return const Text('Feb');
                    case 2:
                      return const Text('Mar');
                    case 3:
                      return const Text('Apr');
                    case 4:
                      return const Text('May');
                    case 5:
                      return const Text('Jun');
                    case 6:
                      return const Text('Jul');
                    case 7:
                      return const Text('Aug');
                    case 8:
                      return const Text('Sep');
                    case 9:
                      return const Text('Oct');
                    case 10:
                      return const Text('Nov');
                    case 11:
                      return const Text('Dec');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, titleMeta) {
                  return Text('\$${value.toInt()}');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 11,
          minY: 600,
          maxY: 1100,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 876),
                FlSpot(1, 879),
                FlSpot(2, 863),
                FlSpot(3, 778),
                FlSpot(4, 751),
                FlSpot(5, 916),
                FlSpot(6, 942),
                FlSpot(7, 667),
                FlSpot(8, 721),
                FlSpot(9, 814),
                FlSpot(10, 766),
                FlSpot(11, 812),
              ],
              isCurved: true,
              color: Colors.lightBlue.shade100,
              barWidth: 3,
              dotData: const FlDotData(
                show: false,
              ),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 1053),
                FlSpot(1, 1022),
                FlSpot(2, 999),
                FlSpot(3, 964),
                FlSpot(4, 751),
                FlSpot(5, 942),
                FlSpot(6, 942),
                FlSpot(7, 667),
                FlSpot(8, 721),
                FlSpot(9, 814),
                FlSpot(10, 766),
                FlSpot(11, 961),
              ],
              isCurved: true,
              color: Colors.orange.shade100,
              barWidth: 3,
              dotData: const FlDotData(
                show: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}