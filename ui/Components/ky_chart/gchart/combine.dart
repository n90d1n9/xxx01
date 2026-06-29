import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CombinedChart extends StatefulWidget {
  const CombinedChart({super.key});

  @override
  State<CombinedChart> createState() => _CombinedChartState();
}

class _CombinedChartState extends State<CombinedChart> {
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
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = '';
                        double value = 0;
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
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Precipitation (ml)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 50,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      axisNameWidget: const Text('Temperature (°C)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 5,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(
                    days.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: evaporationData[index],
                          color: Colors.blue,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: precipitationData[index],
                          color: Colors.green,
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [],
                    verticalLines: [],
                    extraLinesOnTop: true,
                  ),
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