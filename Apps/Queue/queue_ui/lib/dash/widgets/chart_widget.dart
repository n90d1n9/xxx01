import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartType { line, bar, pie }

class ChartWidget extends StatelessWidget {
  final ChartType chartType;
  final Map<String, dynamic> chartData;
  final bool isDarkMode;

  const ChartWidget({
    super.key,
    required this.chartType,
    required this.chartData,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.pie:
        return _buildPieChart(context);
      default:
        return const Center(child: Text('Unsupported chart type'));
    }
  }

  Widget _buildLineChart(BuildContext context) {
    final labels = List<String>.from(chartData['labels'] ?? []);
    final datasets = List<Map<String, dynamic>>.from(
      chartData['datasets'] ?? [],
    );

    if (labels.isEmpty || datasets.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= labels.length) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    //axisSide: meta.axisSide,
                    space: 8.0,
                    meta: meta,
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    //axisSide: meta.axisSide,
                    space: 8.0,
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.black12,
            ),
          ),
          minX: 0,
          maxX: labels.length - 1.0,
          minY: 0,
          lineBarsData:
              datasets.map((dataset) {
                final List<dynamic> data = List<dynamic>.from(
                  dataset['data'] ?? [],
                );
                final color = Color(dataset['color'] as int);

                return LineChartBarData(
                  spots:
                      data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.15),
                  ),
                );
              }).toList(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              //tooltipBgColor: isDarkMode ? Colors.grey[800]! : Colors.white,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final dataset = datasets[barSpot.barIndex];
                  final label = dataset['label'] as String;
                  return LineTooltipItem(
                    '$label: ${barSpot.y.toInt()}',
                    TextStyle(
                      color: Color(dataset['color'] as int),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final labels = List<String>.from(chartData['labels'] ?? []);
    final datasets = List<Map<String, dynamic>>.from(
      chartData['datasets'] ?? [],
    );

    if (labels.isEmpty || datasets.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              datasets
                  .expand((dataset) => List<double>.from(dataset['data'] ?? []))
                  .fold(0.0, (max, value) => value > max ? value : max) *
              1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              //tooltipBgColor: isDarkMode ? Colors.grey[800]! : Colors.white,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dataset = datasets[rodIndex];
                return BarTooltipItem(
                  '${dataset['label']}: ${rod.toY.toInt()}',
                  TextStyle(
                    color: Color(dataset['color'] as int),
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < 0 || value.toInt() >= labels.length) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    //axisSide: meta.axisSide,
                    space: 8,
                    meta: meta,
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    //axisSide: meta.axisSide,
                    space: 8.0,
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.black12,
            ),
          ),
          barGroups:
              labels.asMap().entries.map((entry) {
                final x = entry.key;
                return BarChartGroupData(
                  x: x,
                  barRods:
                      datasets.asMap().entries.map((datasetEntry) {
                        final i = datasetEntry.key;
                        final dataset = datasetEntry.value;
                        final List<double> data = List<double>.from(
                          dataset['data'] ?? [],
                        );
                        if (x >= data.length) {
                          return BarChartRodData(
                            toY: 0,
                            color: Colors.transparent,
                            width: 16,
                          );
                        }
                        return BarChartRodData(
                          toY: data[x],
                          color: Color(dataset['color'] as int),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        );
                      }).toList(),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final datasets = List<Map<String, dynamic>>.from(
      chartData['datasets'] ?? [],
    );

    if (datasets.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final dataset = datasets.first;
    final data = List<double>.from(dataset['data'] ?? []);
    final colors = List<int>.from(dataset['colors'] ?? []);
    final labels = List<String>.from(dataset['labels'] ?? []);

    if (data.isEmpty || colors.isEmpty || labels.isEmpty) {
      return const Center(child: Text('Incomplete chart data'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections:
                  data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final value = entry.value;
                    final color =
                        i < colors.length ? Color(colors[i]) : Colors.grey;
                    final label = i < labels.length ? labels[i] : 'Unknown';

                    return PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${value.toInt()}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children:
                    data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final color =
                          i < colors.length ? Color(colors[i]) : Colors.grey;
                      final label = i < labels.length ? labels[i] : 'Unknown';

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
