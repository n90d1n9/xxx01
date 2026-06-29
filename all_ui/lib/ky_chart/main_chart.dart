import 'package:flutter/material.dart';

import 'example/area_chart_example.dart';
import 'example/candlestick_chart_example.dart';
import 'example/heatmap_chart_example.dart';
import 'example/multi_bar_example.dart';
import 'example/scatter_chart_example.dart';
import 'example/stacked_bar_example.dart';

void main(List<String> args) {
  runApp(const MaterialApp(home: MyChartExample()));
}

class MyChartExample extends StatelessWidget {
  const MyChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Chart Example')),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            // ScatterChartExample(),
            //StackedBarExample(),
            //MultiBarExample(),
            //CandlestickChartExample(),
            AreaChartExample(),
            //HeatmapChartExample(),
          ],
        ),
      ),
    );
  }
}
