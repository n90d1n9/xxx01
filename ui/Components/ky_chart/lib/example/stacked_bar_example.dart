import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import '../charts/bar/bar_config.dart';
import '../charts/bar/stacked_bar_chart.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';
import '../model/label.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/title.dart';
import '../model/tooltip.dart';
import '../model/xyaxis.dart';

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
      child: Expanded(
        child: StackedBarChartWidget(
          config: _chartConfig,
        ),
      ),
    );
  }

  void _updateData() {
    setState(() {
      // Generate some random data for demonstration
      _chartConfig = _createSampleConfig(random: true);
    });
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
        itemStyle: ItemStyle(
          color: getStringRandomColor(),
        ),
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
        itemStyle: ItemStyle(
          color: getStringRandomColor(),
        ),
      ),
    ];

    // Create the x-axis with month labels
    final xAxis = XYAxis(
      type: AxisType.category,
      data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      axisLabel: AxisLabel(
        show: true,
        formatter: '{value}',
      ),
    );

    // Create the y-axis for revenue values
    final yAxis = XYAxis(
      type: AxisType.value,
      name: 'Revenue',
      axisLabel: AxisLabel(
        show: true,
        formatter: '{value}',
      ),
    );

    // Create grid configuration
    final grid = Grid(
      showHorizontalLines: true,
      showVerticalLines: false,
      lineStyle: ChartLineStyle(
        color: getStringRandomColor(),
        width: 1,
      ),
    );

    // Create chart title
    final title = ChartTitle(
      text: 'Monthly Revenue Breakdown',
      subtext: 'By Revenue Stream',
    );

    // Create tooltip configuration
    final tooltip = ChartTooltip(
      formatter: '{a}: {c}',
    );

    // Create legend configuration
    final legend = ChartLegend(
      data: ['Product Sales', 'Service Revenue', 'Subscription'],
      orient: 'horizontal',
      align: 'left',
    );

    // Create the bar chart configuration
    return BarChartConfig(
      type: ChartType.bar,
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
      barBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      isStacked: true,
      isHorizontal: false,
    );
  }
}
