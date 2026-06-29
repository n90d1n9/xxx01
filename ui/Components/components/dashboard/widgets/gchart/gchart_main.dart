import 'package:flutter/material.dart';
/* import 'package:kasir/modules/dashboard/widgets/gchart/gbar.dart';
import 'package:kasir/modules/dashboard/widgets/gchart/gchart_model.dart';
import 'package:kasir/modules/dashboard/widgets/gchart/gpie.dart';
 */
import 'gchart_model.dart';
import 'gsfarea.dart';
import 'gsfbar.dart';
import 'gsfline.dart';
import 'gsfpie.dart';

class GChart extends StatelessWidget {
  //final ChartConfig config;
  final Map<dynamic, dynamic> config;
  final GChartType type;
  final double? width;
  final double? height;
  const GChart({
    super.key,
    required this.config,
    this.type = GChartType.pie,
    this.width = 200,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    ChartConfig chartConfig = ChartConfig(
        xAxis: XAxis(
          type: config['xAxis']['type'],
          data: config['xAxis']['data'],
        ),
        yAxis: YAxis(
          type: config['xAxis']['type'],
          data: config['xAxis']['data'],
        ),
        /* tooltip: GTooltip(
            trigger: config['tooltip']['trigger']),  *///config['tooltip'],
       // legend: Legend(data: config['legend']['data']),
        series: series(config),
        // maxY: config['maxY'] ?? parse2double(config['maxY']),
        maxValueY: maxSeries(config['series']));

    switch (type) {
      case GChartType.bar:
        return SizedBox(
            //width: width, height: height, child: GBar(config: chartConfig));
            width: width,
            height: height,
            child: GSFBar(config: chartConfig));
      case GChartType.line:
        return SizedBox(
            //width: width, height: height, child: GLine(config: chartConfig));
            width: width,
            height: height,
            child: GSFLine(config: chartConfig));
      case GChartType.pie:
        return SizedBox(
            //width: width, height: height, child: GPie(config: chartConfig));
            width: width,
            height: height,
            child: GSFPie(config: chartConfig));
      case GChartType.area:
        return SizedBox(
            //width: width, height: height, child: GPie(config: chartConfig));
            width: width,
            height: height,
            child: GSFArea(config: chartConfig));
      default:
        return const Text('No Chart');
    }
  }

  List<Series> series(Map data) {
    List<Series> dataSeries = [];
    for (var el in data['series']) {
      dataSeries.add(Series(
          data: chartData(el['data']), name: el['name'], type: el['type']));
    }
    return dataSeries;
  }

  List<ChartData> chartData(List data) {
    List<ChartData> cd = [];
    for (var el in data) {
      if (data is List<int>) {
        int n = el;
        cd.add(ChartData(value: n.toDouble()));
      } else {
        int n = el['value'];
        cd.add(ChartData(
            value: n.toDouble(), name: el['name'], color: el['color']));
      }
    }
    return cd;
  }

  double maxSeries(data) {
    List<double> series = [];
    for (var el in data) {
      series.add(maxData(el['data']));
    }
    double max = maxData(series);
    return max;
  }

  double maxData(data) {
    var max = 0.0;
    if (data != null && data.isNotEmpty) {
      if (data is List<int>) {
        data.sort((int a, int b) => a.compareTo(b));

        int last = data.last;
        max = last.toDouble();
      } else if (data is List<double>) {
        data.sort((double a, double b) => a.compareTo(b));

        double last = data.last;
        max = last;
      } else {
        data.sort((a, b) {
          // double x = a['value'];
          a['value'].compareTo(b['value']);
        });

        int last = data.last;
        max = last.toDouble();
      }
    }
    return max;
  }

  double parse2double(data) {
    return data ?? (data is int) ? data.toDouble() : data;
  }
}
