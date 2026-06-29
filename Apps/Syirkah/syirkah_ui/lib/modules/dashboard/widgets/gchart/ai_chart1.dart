/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesEvolutionChart extends StatefulWidget {
  const SalesEvolutionChart({super.key});

  @override
  State<SalesEvolutionChart> createState() => _SalesEvolutionChartState();
}

class _SalesEvolutionChartState extends State<SalesEvolutionChart> {
  List<_ChartData> chartData = [
    _ChartData(DateTime(2023, 1), 876.271),
    _ChartData(DateTime(2023, 2), 879.470),
    _ChartData(DateTime(2023, 3), 863.888),
    _ChartData(DateTime(2023, 4), 778.524),
    _ChartData(DateTime(2023, 5), 751.417),
    _ChartData(DateTime(2023, 6), 942.550),
    _ChartData(DateTime(2023, 7), 667.649),
    _ChartData(DateTime(2023, 8), 721.025),
    _ChartData(DateTime(2023, 9), 814.464),
    _ChartData(DateTime(2023, 10), 766.248),
    _ChartData(DateTime(2023, 11), 812.066),
    _ChartData(DateTime(2023, 12), 961.631),
    _ChartData(DateTime(2024, 1), 1053.584),
    _ChartData(DateTime(2024, 2), 1022.580),
    _ChartData(DateTime(2024, 3), 999.642),
    _ChartData(DateTime(2024, 4), 964.746),
  ];

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            title: const TitlesData(text: 'Sales evolution'),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('MMM'),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            series: [//<ChartSeries<_ChartData, DateTime>>[
              LineSeries<_ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: '2023',
              ),
              LineSeries<_ChartData, DateTime>(
                dataSource: chartData.sublist(12),
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: '2024',
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
       
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
*/
