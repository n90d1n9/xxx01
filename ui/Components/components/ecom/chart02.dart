import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({Key? key}) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  List<_ChartData> chartDataPiutang = [
    _ChartData(DateTime(2023, 5, 9), 800000),
    _ChartData(DateTime(2023, 5, 14), 800000),
    _ChartData(DateTime(2023, 5, 19), 800000),
    _ChartData(DateTime(2023, 5, 24), 800000),
    _ChartData(DateTime(2023, 5, 29), 800000),
    _ChartData(DateTime(2023, 6, 3), 100000),
  ];

  List<_ChartData> chartDataHutang = [
    _ChartData(DateTime(2023, 5, 9), 5000000),
    _ChartData(DateTime(2023, 5, 14), 5000000),
    _ChartData(DateTime(2023, 5, 19), 4000000),
    _ChartData(DateTime(2023, 5, 24), 3000000),
    _ChartData(DateTime(2023, 5, 29), 3000000),
    _ChartData(DateTime(2023, 6, 3), 4000000),
  ];
  
  var locale = 'id_ID';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piutang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.yMMMMEEEEd(locale),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    numberFormat: NumberFormat.currency(
                      locale: locale,
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ),
                  ),
                  series: [
                    AreaSeries<_ChartData, DateTime>(
                      dataSource: chartDataPiutang,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 153, 204, 255),
                          Color.fromARGB(255, 102, 153, 204),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Rp 0',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hutang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child:  SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.yMMMMEEEEd(locale),// .MONTH_DAY //.EEEE,// ('dd MMM'),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    numberFormat: NumberFormat.currency(
                      locale: locale,
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ),
                  ),
                  series: [
                    AreaSeries<_ChartData, DateTime>(
                      dataSource: chartDataHutang,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 153, 204, 255),
                          Color.fromARGB(255, 102, 153, 204),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Rp 1,720,000',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final DateTime x;
  final int y;
}