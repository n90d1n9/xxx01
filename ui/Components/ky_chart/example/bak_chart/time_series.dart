
import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeSeriesChart extends StatefulWidget {
  const TimeSeriesChart({super.key});

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  final List<FlSpot> points = [];
  Timer? timer;
  double lastValue = Random().nextDouble() * 1000;
  final DateTime startDate = DateTime(1997, 9, 3);

  @override
  void initState() {
    super.initState();
    // Initialize with 1000 data points
    for (int i = 0; i < 1000; i++) {
      addNewData();
    }
    // Start periodic updates
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      for (int i = 0; i < 5; i++) {
        setState(() {
          points.removeAt(0);
          addNewData();
        });
      }
    });
  }

  void addNewData() {
    final DateTime now = points.isEmpty 
        ? startDate 
        : DateTime.fromMillisecondsSinceEpoch(
            (points.last.x * 1000).toInt()).add(const Duration(days: 1));
    
    lastValue += (Random().nextDouble() * 21 - 10);
    points.add(FlSpot(
      now.millisecondsSinceEpoch.toDouble() / 1000,
      lastValue.roundToDouble(),
    ));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dynamic Data & Time Axis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      color: Colors.blue,
                    ),
                  ],
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            (value * 1000).toInt(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        interval: 86400 * 30, // Show date every 30 days
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            (spot.x * 1000).toInt(),
                          );
                          return LineTooltipItem(
                            '${date.day}/${date.month}/${date.year}\n${spot.y.round()}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}