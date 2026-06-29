import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syirkah/modules/dashboard/widgets/gchart/gchart_model.dart';


class GPie extends StatefulWidget {
const GPie({Key? key, required this.config}) : super(key: key);
  final ChartConfig? config;

  @override
  State<GPie> createState() => _GPieState();
}

class _GPieState extends State<GPie> {


  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> seriesdata = [];
    for (var el in widget.config!.series!) {
      for (var n in el.data!) {
        seriesdata.add(
          PieChartSectionData(
          color: n.color,
          value: n.value!,
          title: n.name,
        // showTitle: el.emphasis!.show?el.emphasis!.show:true,
         radius: el.itemStyle!.borderRadius,
        ));
      }
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 70,
        startDegreeOffset: -90,
        sections: seriesdata,
      ),
    );
  }
}
