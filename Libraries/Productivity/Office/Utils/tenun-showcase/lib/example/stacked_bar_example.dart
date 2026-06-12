import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

class StackedBarExample extends StatefulWidget {
  const StackedBarExample({super.key});

  @override
  State<StackedBarExample> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends State<StackedBarExample> {
  late BarChartConfig _chartConfig;

  @override
  void initState() {
    super.initState();
    _chartConfig = _createSampleConfig();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 400,
      child: StackedBarChartWidget(config: _chartConfig),
    );
  }

  BarChartConfig _createSampleConfig({bool random = false}) {
    // Random data generator function
    double getValue(double base) {
      if (random) {
        return base + (random ? (math.Random().nextDouble() * 100 - 50) : 0);
      }
      return base;
    }

    // Create series data for the chart
    final series = [
      Series(
        name: 'Product Sales',
        type: ChartType.bar,
        stack: 'Revenue',
        data: [
          [0, getValue(320)], // [Jan, Value]
          [1, getValue(302)], // [Feb, Value]
          [2, getValue(341)], // [Mar, Value]
          [3, getValue(374)], // [Apr, Value]
          [4, getValue(390)], // [May, Value]
          [5, getValue(450)], // [Jun, Value]
        ],
        itemStyle: ItemStyle(),
      ),
      Series(
        name: 'Service Revenue',
        type: ChartType.bar,
        stack: 'Revenue',
        data: [
          [0, getValue(120)], // [Jan, Value]
          [1, getValue(132)], // [Feb, Value]
          [2, getValue(101)], // [Mar, Value]
          [3, getValue(134)], // [Apr, Value]
          [4, getValue(190)], // [May, Value]
          [5, getValue(230)], // [Jun, Value]
        ],
        itemStyle: ItemStyle(color: 'blue'),
      ),
      Series(
        name: 'Subscription',
        type: ChartType.bar,
        stack: 'Revenue',
        data: [
          [0, getValue(220)], // [Jan, Value]
          [1, getValue(232)], // [Feb, Value]
          [2, getValue(201)], // [Mar, Value]
          [3, getValue(234)], // [Apr, Value]
          [4, getValue(290)], // [May, Value]
          [5, getValue(330)], // [Jun, Value]
        ],
        itemStyle: ItemStyle(color: 'green'),
      ),
    ];

    // Create the x-axis with month labels
    final xAxis = XYAxis(
      type: AxisType.category,
      data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      axisLabel: AxisLabel(show: true, formatter: '{value}'),
    );

    // Create the y-axis for revenue values
    final yAxis = XYAxis(
      type: AxisType.value,
      name: 'Revenue',
      axisLabel: AxisLabel(show: true, formatter: '{value}'),
    );

    // Create grid configuration
    final grid = GridData(showHorizontalLines: true, showVerticalLines: false);

    // Create chart title
    final title = TitlesData(
      text: 'Monthly Revenue Breakdown',
      subtext: 'By Revenue Stream',
    );

    // Create tooltip configuration
    final tooltip = ChartTooltip(formatter: '{a}: {c}');

    // Create legend configuration
    final legend = ChartLegend(
      data: ['Product Sales', 'Service Revenue', 'Subscription'],
      orient: 'horizontal',
      align: 'left',
    );

    // Create the bar chart configuration
    return BarChartConfig(
      title: title,
      tooltip: tooltip,
      legend: legend,
      grid: grid,
      xAxis: xAxis,
      yAxis: yAxis,
      series: series,
      maxY: 1000, // Max Y value to show on chart
      alignment: BarChartAlignment.center,
      barWidth: 30,
      barBorderRadiusValue: 6.0,
      isStacked: true,
      isHorizontal: false,
    );
  }
}
