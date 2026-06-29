import 'package:flutter/material.dart';
import 'package:kayys_components/components/chart/bar/index.dart';
import 'package:kayys_components/components/chart/pie/index.dart';
import 'package:kayys_components/components/chart/radar/index.dart';
import 'package:kayys_components/components/chart/line/index.dart';

class Charts extends StatelessWidget {
  const Charts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LineChartSample1(),
        const LineChartSample2(),
         LineChartSample3(),
         LineChartSample4(),
        const LineChartSample5(),
         LineChartSample6(),
         LineChartSample7(),
        const LineChartSample8(),
         LineChartSample9(),
        const LineChartSample10(),
        const LineChartSample11(),

        const PieChartSample3(),
        const PieChartSample2(),
        const PieChartSample1(),

        BarChartSample1(),
        BarChartSample2(),
        const BarChartSample3(),
        const BarChartSample5(),
        const BarChartSample6(),
        BarChartSample7(),
        BarChartSample8(),

        RadarChartSample1(),
      ],
    );
  }
}