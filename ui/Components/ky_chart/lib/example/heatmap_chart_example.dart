import 'package:flutter/material.dart';
import 'package:ky_chart/charts/heatmap/heatmap_chart.dart';
import 'package:ky_chart/charts/heatmap/heatmap_config.dart';
import 'package:ky_chart/model/legend.dart';
import 'package:ky_chart/model/series.dart';
import 'package:ky_chart/model/title.dart';

class HeatmapChartExample extends StatelessWidget {
  const HeatmapChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final heatmapConfig = HeatmapChartConfig(
      title: ChartTitle(text: 'Temperature Heatmap'),
      series: [
        Series(
          name: 'Temperature',
          data: [
            {'x': 'Mon', 'y': 'Morning', 'value': 12.5},
            {'x': 'Mon', 'y': 'Afternoon', 'value': 24.8},
            {'x': 'Mon', 'y': 'Evening', 'value': 18.3},
            {'x': 'Tue', 'y': 'Morning', 'value': 11.0},
            {'x': 'Tue', 'y': 'Afternoon', 'value': 25.2},
            {'x': 'Tue', 'y': 'Evening', 'value': 17.5},
            {'x': 'Wed', 'y': 'Morning', 'value': 13.2},
            {'x': 'Wed', 'y': 'Afternoon', 'value': 28.6},
            {'x': 'Wed', 'y': 'Evening', 'value': 21.3},
            {'x': 'Thu', 'y': 'Morning', 'value': 14.1},
            {'x': 'Thu', 'y': 'Afternoon', 'value': 27.4},
            {'x': 'Thu', 'y': 'Evening', 'value': 20.2},
            {'x': 'Fri', 'y': 'Morning', 'value': 15.5},
            {'x': 'Fri', 'y': 'Afternoon', 'value': 26.3},
            {'x': 'Fri', 'y': 'Evening', 'value': 19.7},
          ],
        ),
      ],
      minColor: Colors.blue.shade100,
      maxColor: Colors.red,
      showLabels: true,
      enableTooltip: true,
      legend: ChartLegend(show: true),
    );

    return SizedBox(
      height: 400,
      child: HeatmapChartWidget(config: heatmapConfig),
    );
  }
}
