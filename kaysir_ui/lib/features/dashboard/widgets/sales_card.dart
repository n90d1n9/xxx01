import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';

class SalesChart extends StatelessWidget {
  final List<SalesDataPoint> salesData;
  final String currentLabel;
  final String previousLabel;

  const SalesChart({
    super.key,
    required this.salesData,
    this.currentLabel = 'Current',
    this.previousLabel = 'Previous',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine:
                (value) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
            getDrawingVerticalLine:
                (value) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  strokeWidth: 1,
                ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Text(DateFormat('EEE').format(day));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 44),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: salesData.first.date.millisecondsSinceEpoch.toDouble(),
          maxX: salesData.last.date.millisecondsSinceEpoch.toDouble(),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots:
                  salesData
                      .map(
                        (data) => FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.currentWeekSales.toDouble(),
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: const Color(0xFF2E7D32),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots:
                  salesData
                      .map(
                        (data) => FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.previousWeekSales.toDouble(),
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: const Color(0xFF1769AA),
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
                  final salesPoint = salesData.firstWhere(
                    (element) =>
                        element.date.millisecondsSinceEpoch.toDouble() ==
                        spot.x,
                  );
                  return LineTooltipItem(
                    '$currentLabel: ${currency.format(salesPoint.currentWeekSales)}\n'
                    '$previousLabel: ${currency.format(salesPoint.previousWeekSales)}',
                    TextStyle(color: colorScheme.onSurface),
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
