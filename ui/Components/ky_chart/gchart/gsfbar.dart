import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'gchart_model.dart';

class GSFBar extends StatefulWidget {
  const GSFBar({super.key, this.config});
  final ChartConfig? config;

  @override
  State<GSFBar> createState() => _GSFBarState();
}

class _GSFBarState extends State<GSFBar> {
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
          primaryYAxis:
              const NumericAxis(minimum: 0, maximum: 40, interval: 10),
          tooltipBehavior: _tooltipBehavior,
          series: charts(widget.config!.series!)),
    );
  }

  List<CartesianSeries> charts(List<Series> series) {
    List<CartesianSeries> cs = [];
    for (var el in series) {
      cs.add(chartBar(el.data!));
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

  chartBar(List<ChartData> data) {
    return BarSeries<ChartData, dynamic>(
        dataSource: data,
        xValueMapper: (ChartData x, _) => x.value!,
        yValueMapper: (ChartData y, _) => y.value!,
        name: 'Gold',
        color: const Color.fromRGBO(8, 142, 255, 1));
  }
}
