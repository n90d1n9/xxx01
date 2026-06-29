import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CombinedLineBarChart extends StatefulWidget {
  const CombinedLineBarChart({Key? key}) : super(key: key);

  @override
  State<CombinedLineBarChart> createState() => _CombinedLineBarChartState();
}

class _CombinedLineBarChartState extends State<CombinedLineBarChart> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  final List<double> evaporationData = [2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6];
  final List<double> precipitationData = [2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6];
  final List<double> temperatureData = [2.0, 2.2, 3.3, 4.5, 6.3, 10.2, 20.3];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 250,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        double value;
                        if (rodIndex == 0) {
                          label = 'Evaporation';
                          value = evaporationData[group.x.toInt()];
                        } else {
                          label = 'Precipitation';
                          value = precipitationData[group.x.toInt()];
                        }
                        return BarTooltipItem(
                          '$label\n${value.toStringAsFixed(1)} ml',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('Precipitation (ml)'),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('Temperature (°C)'),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 50,
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(
                    days.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: evaporationData[index],
                          color: Colors.blue.withOpacity(0.7),
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: precipitationData[index],
                          color: Colors.green.withOpacity(0.7),
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Separate LineChart for temperature
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        temperatureData.length,
                        (index) => FlSpot(index.toDouble(), temperatureData[index]),
                      ),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: -0.5,
                  maxX: days.length - 0.5,
                  minY: 0,
                  maxY: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Evaporation', Colors.blue),
        const SizedBox(width: 16),
        _buildLegendItem('Precipitation', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem('Temperature', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}