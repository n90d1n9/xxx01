import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealtimeOverviewWidget extends StatelessWidget {
  const RealtimeOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 16.0, color: Colors.blue),
              SizedBox(width: 8.0),
              Text(
                'Realtime Overview',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            'Users in last 30 min',
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 4.0),
          Text(
            '65',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Users per minute',
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100.0,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: [
                ColumnSeries<ChartData, String>(
                  dataSource: <ChartData>[
                    ChartData('1', 10),
                    ChartData('2', 15),
                    ChartData('3', 12),
                    ChartData('4', 18),
                    ChartData('5', 20),
                    ChartData('6', 15),
                    ChartData('7', 12),
                    ChartData('8', 18),
                    ChartData('9', 20),
                    ChartData('10', 15),
                    ChartData('11', 12),
                    ChartData('12', 18),
                    ChartData('13', 20),
                    ChartData('14', 15),
                    ChartData('15', 12),
                    ChartData('16', 18),
                    ChartData('17', 20),
                    ChartData('18', 15),
                    ChartData('19', 12),
                    ChartData('20', 18),
                    ChartData('21', 20),
                    ChartData('22', 15),
                    ChartData('23', 12),
                    ChartData('24', 18),
                    ChartData('25', 20),
                    ChartData('26', 15),
                    ChartData('27', 12),
                    ChartData('28', 18),
                    ChartData('29', 20),
                    ChartData('30', 15),
                    ChartData('31', 12),
                    ChartData('32', 18),
                    ChartData('33', 20),
                    ChartData('34', 15),
                    ChartData('35', 12),
                    ChartData('36', 18),
                    ChartData('37', 20),
                    ChartData('38', 15),
                    ChartData('39', 12),
                    ChartData('40', 18),
                    ChartData('41', 20),
                    ChartData('42', 15),
                    ChartData('43', 12),
                    ChartData('44', 18),
                    ChartData('45', 20),
                    ChartData('46', 15),
                    ChartData('47', 12),
                    ChartData('48', 18),
                    ChartData('49', 20),
                    ChartData('50', 15),
                    ChartData('51', 12),
                    ChartData('52', 18),
                    ChartData('53', 20),
                    ChartData('54', 15),
                    ChartData('55', 12),
                    ChartData('56', 18),
                    ChartData('57', 20),
                    ChartData('58', 15),
                    ChartData('59', 12),
                    ChartData('60', 18),
                    ChartData('61', 20),
                    ChartData('62', 15),
                    ChartData('63', 12),
                    ChartData('64', 18),
                    ChartData('65', 20),
                  ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Users by device',
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: Row(
              children: [
                Expanded(
                  child: 
                  const CircularProgressIndicator(
                    value: 92.31,
                  )
                  /* CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 10.0,
                    percent: 0.9231,
                    center: Text(
                      '92.31%',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: Colors.blue,
                  ) */,
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16.0, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text('mobile'),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('92.31%'),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16.0, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text('desktop'),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('3.08%'),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16.0, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text('tablet'),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('3.08%'),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16.0, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text('(other)'),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('1.54%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}