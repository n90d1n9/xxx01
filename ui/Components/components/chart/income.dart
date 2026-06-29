import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IncomeStatementChart extends StatefulWidget {
  const IncomeStatementChart({Key? key}) : super(key: key);

  @override
  State<IncomeStatementChart> createState() => _IncomeStatementChartState();
}

class _IncomeStatementChartState extends State<IncomeStatementChart> {
  List<_ChartData> chartData = [
    _ChartData('Sales (Revenue)', 15500000, 14625000),
    _ChartData('Less: Cost of Goods Sold (COGS)', -9900000, -10500000),
    _ChartData('Gross Income', 5600000, 4125000),
    _ChartData('Less: Selling, General, Administrative Costs (SG&A)', -3300000, -2350000),
    _ChartData('Operating Income Before Depreciation (EBITDA)', 2300000, 1775000),
    _ChartData('Less: Depreciation, Amortization, Depletion', -11000, -10000),
    _ChartData('Operating Income (EBIT)', 2289000, 1765000),
    _ChartData('Less: Interest Expense', -93000, -89000),
    _ChartData('Non-operating Income', 2196000, 1676000),
    _ChartData('Less: Non-operating Expenses', -42000, -40000),
    _ChartData('Pretax Accounting Income', 2154000, 1636000),
    _ChartData('Less: Income Taxes', -1350000, -1240000),
    _ChartData('Income Before Extraordinary Items', 804000, 396000),
    _ChartData('Less: Preferred Stock Dividends', -87000, -85000),
    _ChartData('Income Available for Common Stockholders', 717000, 311000),
    _ChartData('Less: Extraordinary Items', -18000, -15000),
    _ChartData('Less: Discontinued Operations', -400000, -100000),
    _ChartData('Adjusted Net Income', 299000, 196000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Statement Chart'),
      ),
      body: Center(
        child: Container(
          height: 500,
          child: SfCartesianChart(
            title: ChartTitle(text: 'Income Statement 2021-2022'),
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'USD'),
              numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
            ),
            series: [
              ColumnSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.item,
                yValueMapper: (_ChartData data, _) => data.year2021,
                name: '2021',
                color: Colors.blue,
              ),
              ColumnSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.item,
                yValueMapper: (_ChartData data, _) => data.year2022,
                name: '2022',
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  final String item;
  final int year2021;
  final int year2022;

  _ChartData(this.item, this.year2021, this.year2022);
}