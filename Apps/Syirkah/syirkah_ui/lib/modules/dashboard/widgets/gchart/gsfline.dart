/*
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'gchart_model.dart';

class GSFLine extends StatefulWidget {
  const GSFLine({super.key, this.config});
  final ChartConfig? config;

  @override
  State<GSFLine> createState() => _GSFLineState();
}

class _GSFLineState extends State<GSFLine> {
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
          primaryXAxis: xType(widget.config!),
          tooltipBehavior: _tooltipBehavior,
          series: charts(widget.config!.series!)),
    );
  }

  List<CartesianSeries> charts(List<Series> series) {
    List<CartesianSeries> cs = [];
    //series.map((el) => cs.add(chart(el.data!)));
    for (var el in series) {
      cs.add(chart(el.data!));
    }
    return cs;
  }

  ChartAxis xType(ChartConfig config) {
    switch (config.xAxis!.type!) {
      case 'category':
        return const CategoryAxis();
      default:
        return const NumericAxis();
    }
  }

  chart(List<ChartData> data) {
    return LineSeries<ChartData, dynamic>(
        dataSource: data,
        xValueMapper: (ChartData x, _) => x.value,
        yValueMapper: (ChartData y, _) => y.value);
  }
}
*/
