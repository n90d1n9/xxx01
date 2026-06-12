import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

abstract final class BarChartSamples {
  static BarChartConfig simple({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Monthly Sales'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Sales',
          data: [
            [0, 120],
            [1, 200],
            [2, 150],
            [3, 80],
            [4, 70],
            [5, 110],
            [6, 130],
          ],
          color: Colors.blue,
        ),
      ],
      xAxis: XYAxis(data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']),
      yAxis: XYAxis(name: 'Units'),
      maxY: 250,
      barWidth: 30,
      barBorderRadiusValue: 4,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig grouped({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Quarterly Revenue by Region'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'North',
          data: [
            [0, 120],
            [1, 132],
            [2, 101],
            [3, 134],
          ],
          color: Colors.blue,
        ),
        Series(
          type: ChartType.bar,
          name: 'South',
          data: [
            [0, 220],
            [1, 182],
            [2, 191],
            [3, 234],
          ],
          color: Colors.green,
        ),
        Series(
          type: ChartType.bar,
          name: 'East',
          data: [
            [0, 150],
            [1, 212],
            [2, 201],
            [3, 154],
          ],
          color: Colors.orange,
        ),
      ],
      xAxis: XYAxis(data: ['Q1', 'Q2', 'Q3', 'Q4']),
      yAxis: XYAxis(name: 'Revenue (\$K)'),
      maxY: 300,
      barWidth: 12,
      barBorderRadiusValue: 4,
      isMultiBar: true,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig stacked({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Project Tasks Completion'),
      series: [
        Series(
          name: 'Completed',
          type: ChartType.bar,
          stack: 'total',
          data: [
            [0, 320],
            [1, 332],
            [2, 301],
            [3, 334],
            [4, 390],
          ],
          color: Colors.green,
        ),
        Series(
          name: 'In Progress',
          type: ChartType.bar,
          stack: 'total',
          data: [
            [0, 120],
            [1, 132],
            [2, 101],
            [3, 134],
            [4, 90],
          ],
          color: Colors.orange,
        ),
        Series(
          name: 'Pending',
          type: ChartType.bar,
          stack: 'total',
          data: [
            [0, 220],
            [1, 182],
            [2, 191],
            [3, 234],
            [4, 290],
          ],
          color: Colors.red,
        ),
      ],
      xAxis: XYAxis(data: ['Task A', 'Task B', 'Task C', 'Task D', 'Task E']),
      yAxis: XYAxis(name: 'Hours'),
      maxY: 800,
      barWidth: 40,
      barBorderRadiusValue: 4,
      isStacked: true,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip, formatter: '{a}: {c}'),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig horizontal({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Top Products by Sales'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Sales',
          data: [
            [0, 1820],
            [1, 2348],
            [2, 3100],
            [3, 1400],
            [4, 2900],
          ],
          color: Colors.purple,
        ),
      ],
      xAxis: XYAxis(type: AxisType.value, name: 'Units Sold'),
      yAxis: XYAxis(
        type: AxisType.category,
        data: ['Product A', 'Product B', 'Product C', 'Product D', 'Product E'],
      ),
      maxY: 3500,
      barWidth: 25,
      barBorderRadiusValue: 4,
      isHorizontal: true,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showVerticalLines: true),
    );
  }

  static BarChartConfig gradient({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Website Traffic Sources'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Visitors',
          data: [
            [0, 3200],
            [1, 5100],
            [2, 2800],
            [3, 4200],
            [4, 1900],
          ],
          color: const Color(0xFF5470C6),
          itemStyle: ItemStyle(color: '#5470C6'),
        ),
      ],
      xAxis: XYAxis(data: ['Direct', 'Organic', 'Referral', 'Social', 'Email']),
      yAxis: XYAxis(name: 'Visitors'),
      maxY: 6000,
      barWidth: 35,
      barBorderRadiusValue: 8,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig negative({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Profit & Loss by Quarter'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Profit/Loss',
          data: [
            [0, 120],
            [1, -80],
            [2, 200],
            [3, -50],
          ],
          color: Colors.blue,
        ),
      ],
      xAxis: XYAxis(data: ['Q1', 'Q2', 'Q3', 'Q4']),
      yAxis: XYAxis(name: 'Amount (\$K)'),
      maxY: 250,
      barWidth: 40,
      barBorderRadiusValue: 4,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig customColor({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Team Performance'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Score',
          data: [
            [0, 85],
            [1, 92],
            [2, 78],
            [3, 88],
            [4, 95],
          ],
          color: Colors.green,
        ),
      ],
      xAxis: XYAxis(data: ['Team A', 'Team B', 'Team C', 'Team D', 'Team E']),
      yAxis: XYAxis(name: 'Score'),
      maxY: 100,
      barWidth: 35,
      barBorderRadiusValue: 4,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }

  static BarChartConfig mixedBarLine({bool showTooltip = true}) {
    return BarChartConfig(
      title: TitlesData(text: 'Sales vs Target'),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Actual Sales',
          data: [
            [0, 220],
            [1, 182],
            [2, 191],
            [3, 234],
            [4, 290],
            [5, 330],
          ],
          color: Colors.blue,
        ),
      ],
      xAxis: XYAxis(data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']),
      yAxis: XYAxis(name: 'Units'),
      maxY: 400,
      barWidth: 30,
      barBorderRadiusValue: 4,
      legend: ChartLegend(show: true),
      tooltip: ChartTooltip(show: showTooltip),
      grid: GridData(show: true, showHorizontalLines: true),
    );
  }
}
