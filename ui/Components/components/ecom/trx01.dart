import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TransactionChart extends StatefulWidget {
  const TransactionChart({Key? key}) : super(key: key);

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  List<_ChartData> chartData = [
    _ChartData(DateTime(2021, 5, 28), 180000, 'Pengeluaran'),
    _ChartData(DateTime(2021, 5, 31), 694700, 'Tutup Buku'),
    _ChartData(DateTime(2021, 6, 7), 360000, 'Pemasukan'),
    _ChartData(DateTime(2021, 6, 9), 180000, 'Pengeluaran'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akrilik Barokah'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            title: ChartTitle(text: 'Riwayat Transaksi'),
            primaryXAxis: DateTimeAxis(
              //dateFormat: DateFormat('dd MMM yyyy'),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Nominal (Rp)'),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            series: [
              ColumnSeries<_ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.date,
                yValueMapper: (_ChartData data, _) => data.amount,
                name: 'Transaksi',
                color: Colors.blue,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                 // labelAlignment: ChartAlignment.near,
                  textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.date, this.amount, this.type);

  final DateTime date;
  final int amount;
  final String type;
}