import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import '../charts/scatter/scatter_chart.dart';
import '../charts/scatter/scatter_config.dart';
import '../model/chart_model.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';
import '../model/label.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/title.dart';
import '../model/tooltip.dart';
import '../model/xyaxis.dart';

// Example of usage
class ScatterChartExample extends StatelessWidget {
  const ScatterChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return /* Scaffold(
      appBar: AppBar(
        title: const Text('Scatter Chart Example'),
      ),
      body:  */
        Padding(
      padding: const EdgeInsets.all(16.0),
      child: ScatterBarChartWidget(
        config: ScatterChartConfig(
          title: ChartTitle(text: 'Interactive Scatter Chart'),
          tooltip: ChartTooltip(show: true),
          legend: ChartLegend(show: true),
          toolbox: ChartToolbox(show: true),
          grid: Grid(show: true),
          xAxis: XYAxis(show: true),
          yAxis: XYAxis(show: true),
          minX: 0,
          maxX: 100,
          minY: 0,
          maxY: 100,
          dotSize: 6,
          //type: ChartType.scatter,
          series: [
            Series(
              name: 'Series A',
              type: ChartType.scatter,
              itemStyle: ItemStyle(color: getStringRandomColor()),
              data: [
                {'x': 10, 'y': 30, 'value': 5},
                {'x': 20, 'y': 40, 'value': 10},
                {'x': 30, 'y': 20, 'value': 15},
                {'x': 40, 'y': 60, 'value': 20},
                {'x': 50, 'y': 50, 'value': 25},
              ],
            ),
            Series(
              name: 'Series B',
              type: ChartType.scatter,
              itemStyle: ItemStyle(color: getStringRandomColor()),
              data: [
                {'x': 15, 'y': 45, 'value': 8},
                {'x': 25, 'y': 35, 'value': 12},
                {'x': 35, 'y': 55, 'value': 16},
                {'x': 45, 'y': 25, 'value': 20},
                {'x': 55, 'y': 65, 'value': 24},
              ],
            ),
          ],
        ),
        height: 400,
      ),
      // ),
    );
  }
}
/* 
// These are mock classes to complement your provided classes
class ChartType {
  static const scatter = 'scatter';
  // Add other chart types as needed
}

class Series {
  final String? name;
  final String? type;
  final ItemStyle? itemStyle;
  final dynamic data;

  Series({
    this.name,
    this.type,
    this.itemStyle,
    this.data,
  });
}

class ItemStyle {
  final Color? color;

  ItemStyle({
    this.color,
  });
}

class Grid {
  final bool show;

  Grid({
    this.show = true,
  });
}

class ChartTitle {
  final String text;

  ChartTitle({
    required this.text,
  });
}

class ChartTooltip {
  final bool show;

  ChartTooltip({
    this.show = true,
  });
}

class ChartLegend {
  final bool show;

  ChartLegend({
    this.show = true,
  });
}

class ChartToolbox {
  final bool show;

  ChartToolbox({
    this.show = true,
  });
}
 */
