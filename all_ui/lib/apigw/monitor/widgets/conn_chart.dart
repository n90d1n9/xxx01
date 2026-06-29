import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/http_conn_history.dart';
import '../states/api_provider.dart';

class ConnectionsChart extends ConsumerWidget {
  const ConnectionsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionHistory = ref.watch(httpConnectionsHistoryProvider);

    if (connectionHistory.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Waiting for connection data...')),
      );
    }

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
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= connectionHistory.length ||
                      value.toInt() < 0) {
                    return const SizedBox();
                  }

                  // Only show some labels to avoid overcrowding
                  if (value.toInt() % (connectionHistory.length ~/ 5) != 0) {
                    return const SizedBox();
                  }

                  final time = connectionHistory[value.toInt()].timestamp;
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
          maxX: connectionHistory.length.toDouble() - 1,
          minY: 0,
          maxY:
              connectionHistory
                  .fold<int>(
                    0,
                    (max, entry) =>
                        entry.connections.active > max
                            ? entry.connections.active
                            : max,
                  )
                  .toDouble() *
              1.2,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Theme.of(context).colorScheme.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= connectionHistory.length || index < 0) {
                    return null;
                  }

                  final entry = connectionHistory[index];
                  String label;

                  if (spot.barIndex == 0) {
                    label = 'Active: ${entry.connections.active}';
                  } else if (spot.barIndex == 1) {
                    label = 'Writing: ${entry.connections.writing}';
                  } else if (spot.barIndex == 2) {
                    label = 'Reading: ${entry.connections.reading}';
                  } else {
                    label = 'Waiting: ${entry.connections.waiting}';
                  }

                  return LineTooltipItem(
                    label,
                    TextStyle(
                      color: getLineColor(spot.barIndex),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            _createLineChartBarData(
              connectionHistory,
              0,
              (conn) => conn.active.toDouble(),
            ),
            _createLineChartBarData(
              connectionHistory,
              1,
              (conn) => conn.writing.toDouble(),
            ),
            _createLineChartBarData(
              connectionHistory,
              2,
              (conn) => conn.reading.toDouble(),
            ),
            _createLineChartBarData(
              connectionHistory,
              3,
              (conn) => conn.waiting.toDouble(),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLineChartBarData(
    List<HttpConnectionsHistoryEntry> history,
    int barIndex,
    double Function(dynamic conn) valueSelector,
  ) {
    return LineChartBarData(
      spots: List.generate(history.length, (index) {
        return FlSpot(
          index.toDouble(),
          valueSelector(history[index].connections),
        );
      }),
      isCurved: true,
      curveSmoothness: 0.3,
      color: getLineColor(barIndex),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: getLineColor(barIndex).withValues(alpha: 0.1),
      ),
    );
  }

  Color getLineColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.deepPurple;
      case 2:
        return Colors.teal;
      case 3:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
