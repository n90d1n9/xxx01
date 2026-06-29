import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../charts/bar/bar_config.dart';
import '../charts/bar/multi_bar.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';
import '../model/label.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/title.dart';
import '../model/tooltip.dart';
import '../model/xyaxis.dart';

class MultiBarExample extends StatelessWidget {
  const MultiBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return /* Scaffold(
      appBar: AppBar(
        title: const Text('Stacked Bar Chart Demo'),
        elevation: 0,
      ),
      body:  
        Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Data by Region',
            style: Theme.of(context).textTheme.headlineSmall,
          ),*/
        SizedBox(
      height: 400,
      child: Expanded(
        child: MultiBarChartWidget(
          config: _createSampleConfig(),
        ),
      ),
      //],
      // ),
      // ),
    );
  }

  BarChartConfig _createSampleConfig() {
    // Create series data for the chart
    final series = [
      Series(
        name: 'Product A',
        type: ChartType.bar,
        stack: 'Products',
        data: [
          [0, 120], // [Q1, Sales]
          [1, 132], // [Q2, Sales]
          [2, 101], // [Q3, Sales]
          [3, 134], // [Q4, Sales]
        ],
      ),
      Series(
        name: 'Product B',
        type: ChartType.bar,
        stack: 'Products',
        data: [
          [0, 220], // [Q1, Sales]
          [1, 182], // [Q2, Sales]
          [2, 191], // [Q3, Sales]
          [3, 234], // [Q4, Sales]
        ],
        itemStyle: ItemStyle(),
      ),
      Series(
        name: 'Product C',
        type: ChartType.bar,
        stack: 'Products',
        data: [
          [0, 150], // [Q1, Sales]
          [1, 232], // [Q2, Sales]
          [2, 201], // [Q3, Sales]
          [3, 154], // [Q4, Sales]
        ],
        itemStyle: ItemStyle(),
      ),
    ];

    // Create the x-axis with quarter labels
    final xAxis = XYAxis(
      type: AxisType.category,
      data: ['Q1', 'Q2', 'Q3', 'Q4'],
      axisLabel: AxisLabel(
        show: true,
        formatter: '{value}',
      ),
    );

    // Create the y-axis for sales values
    final yAxis = XYAxis(
      type: AxisType.value,
      name: 'Sales',
      axisLabel: AxisLabel(
        show: true,
        formatter: '{value}',
      ),
    );

    // Create grid configuration
    final grid = Grid(
      showHorizontalLines: true,
      showVerticalLines: false,
    );

    // Create chart title
    final title = ChartTitle(
      text: 'Quarterly Sales Performance',
      subtext: 'By Product',
    );

    // Create tooltip configuration
    final tooltip = ChartTooltip(
      formatter: '{a}: {c}',
    );

    // Create legend configuration
    final legend = ChartLegend(
      data: ['Product A', 'Product B', 'Product C'],
      orient: 'horizontal',
      align: 'left',
    );

    // Create the bar chart configuration
    return BarChartConfig(
      type: ChartType.stackedBar,
      title: title,
      tooltip: tooltip,
      legend: legend,
      grid: grid,
      xAxis: xAxis,
      yAxis: yAxis,
      series: series,
      maxY: 650, // Max Y value to show on chart
      alignment: BarChartAlignment.center,
      barWidth: 16,
      barBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
      ),
      isStacked: true,
      isHorizontal: false,
    );
  }
}
