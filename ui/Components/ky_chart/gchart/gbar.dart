import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'gchart_model.dart';

class GBar extends StatefulWidget {
  const GBar({super.key, required this.config});
  final ChartConfig? config;

  @override
  State<GBar> createState() => _GBarState();
}

class _GBarState extends State<GBar> {
  var isTouched = false;
  var width = 20.0;
  var touchedBarColor = Colors.cyan[200];
  var barColor = Colors.pink[900];
  var y = 10.0;
  var barBackgroundColor = Colors.red[200];

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> seriesdata = [];
    var i = 0;
    for (var el in widget.config!.series!) {
      List<BarChartRodData> bcrd = [];
      for (var n in el.data!) {
        bcrd.add(
          BarChartRodData(
            toY: isTouched ? n.value! + 1 : n.value!,
            color: isTouched ? touchedBarColor : barColor,
            width: width,
            borderSide: isTouched
                ? BorderSide(color: touchedBarColor!)
                : const BorderSide(color: Colors.yellow, width: 0),
            backDrawRodData: BackgroundBarChartRodData(
                show: true, toY: 20, color: n.color //barBackgroundColor,
                ),
          ),
        );
      }
      seriesdata.add(BarChartGroupData(x: i, barRods: bcrd));
      i++;
    }
    return BarChart(
      BarChartData(
          barGroups: seriesdata,
          barTouchData:
              BarTouchData(touchCallback: (FlTouchEvent event, response) {
            setState(() {
              if (!event.isInterestedForInteractions) {
                isTouched = true;
              }
            });
          })),
    );
  }
}
