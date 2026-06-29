/*
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'gchart_model.dart';

class GSFPie extends StatefulWidget {
  const GSFPie({super.key, this.config});
  final ChartConfig? config;

  @override
  State<GSFPie> createState() => _GSFPieState();
}

class _GSFPieState extends State<GSFPie> {
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          primaryYAxis:
              const NumericAxis(minimum: 0, maximum: 40, interval: 10),
          tooltipBehavior: _tooltipBehavior,
          series: charts(widget.config!.series!)),
    );
  }

  List<CartesianSeries> charts(List<Series> series) {
    List<CartesianSeries> cs = [];
    series.map((el) => cs.add(chartBar(el.data!)));
    return cs;
  }

  chartLine(List<ChartData> data) {
    return LineSeries<ChartData, dynamic>(
        dataSource: data,
        xValueMapper: (ChartData x, _) => x.value,
        yValueMapper: (ChartData y, _) => y.value);
  }

  chartBar(List<ChartData> data) {
    return PieSeries<ChartData, dynamic>(
      dataSource: data,
      xValueMapper: (ChartData x, _) => x.value!,
      yValueMapper: (ChartData y, _) => y.value!,
      name: 'Gold',
    );
  }
}
*/
