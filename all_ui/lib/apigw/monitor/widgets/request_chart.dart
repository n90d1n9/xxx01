import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/request_provider.dart';

class RequestsChart extends ConsumerWidget {
  const RequestsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsHistory = ref.watch(requestsCounterProvider);

    if (requestsHistory.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('Waiting for requests data...')),
      );
    }

    // Calculate request rate
    List<FlSpot> rateSpots = [];
    for (int i = 1; i < requestsHistory.length; i++) {
      final prevTimestamp = requestsHistory[i - 1].timestamp;
      final currentTimestamp = requestsHistory[i].timestamp;
      final prevCount = requestsHistory[i - 1].count;
      final currentCount = requestsHistory[i].count;

      final durationInSeconds =
          currentTimestamp.difference(prevTimestamp).inMilliseconds / 1000;
      final requestDiff = currentCount - prevCount;

      // Calculate requests per second
      final rate = durationInSeconds > 0 ? requestDiff / durationInSeconds : 0;
      rateSpots.add(FlSpot((i - 1).toDouble(), rate.toDouble()));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              // lib/widgets/requests_chart.dart (continued)
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= rateSpots.length || value.toInt() < 0) {
                    return const SizedBox();
                  }

                  // Only show some labels to avoid overcrowding
                  if (value.toInt() % (rateSpots.length ~/ 5) != 0) {
                    return const SizedBox();
                  }

                  final index =
                      value.toInt() +
                      1; // +1 because rateSpots starts from index 1
                  if (index >= requestsHistory.length) {
                    return const SizedBox();
                  }

                  final time = requestsHistory[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm:ss').format(time),
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
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
          minX: 0,
          maxX: rateSpots.length.toDouble() - 1,
          minY: 0,
          maxY:
              rateSpots.fold<double>(
                0,
                (max, spot) => spot.y > max ? spot.y : max,
              ) *
              1.2,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              //tooltipBgColor: Theme.of(context).colorScheme.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt() + 1;
                  if (index >= requestsHistory.length || index < 0) {
                    return null;
                  }

                  return LineTooltipItem(
                    'Requests/sec: ${spot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: rateSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.orange,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
