import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

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
          ),*/ SizedBox(
      height: 400,
      child: MultiBarChartWidget(config: _createSampleConfig()),
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
      axisLabel: AxisLabel(show: true, formatter: '{value}'),
    );

    // Create the y-axis for sales values
    final yAxis = XYAxis(
      type: AxisType.value,
      name: 'Sales',
      axisLabel: AxisLabel(show: true, formatter: '{value}'),
    );

    // Create grid configuration
    final grid = GridData(showHorizontalLines: true, showVerticalLines: false);

    // Create chart title
    final title = TitlesData(
      text: 'Quarterly Sales Performance',
      subtext: 'By Product',
    );

    // Create tooltip configuration
    final tooltip = ChartTooltip(formatter: '{a}: {c}');

    // Create legend configuration
    final legend = ChartLegend(
      data: ['Product A', 'Product B', 'Product C'],
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
      maxY: 650, // Max Y value to show on chart
      alignment: BarChartAlignment.center,
      barWidth: 16,
      barBorderRadiusValue: 4.0,
      isStacked: true,
      isHorizontal: false,
    );
  }
}
