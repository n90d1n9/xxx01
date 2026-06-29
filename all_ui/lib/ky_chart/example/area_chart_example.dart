import 'package:flutter/material.dart';

import '../charts/area/area_chart.dart';
import '../charts/area/area_chart_config.dart';
import '../model/grid.dart';
import '../model/label.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/tooltip.dart';
import '../model/title.dart';

class AreaChartExample extends StatelessWidget {
  const AreaChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final areaChartConfig = AreaChartConfig(
      title: ChartTitle(text: 'Monthly Revenue'),
      series: [
        Series(
          name: 'Revenue 2024',
          data: [
            {'x': 'Jan', 'y': 120},
            {'x': 'Feb', 'y': 132},
            {'x': 'Mar', 'y': 101},
            {'x': 'Apr', 'y': 134},
            {'x': 'May', 'y': 90},
            {'x': 'Jun', 'y': 230},
            {'x': 'Jul', 'y': 210},
            {'x': 'Aug', 'y': 190},
            {'x': 'Sep', 'y': 180},
            {'x': 'Oct', 'y': 160},
            {'x': 'Nov', 'y': 145},
            {'x': 'Dec', 'y': 190},
          ],
          itemStyle: ItemStyle(color: 'rgba(0, 0, 255, 0.5)'),
        ),
        Series(
          name: 'Revenue 2023',
          data: [
            {'x': 'Jan', 'y': 90},
            {'x': 'Feb', 'y': 110},
            {'x': 'Mar', 'y': 85},
            {'x': 'Apr', 'y': 105},
            {'x': 'May', 'y': 65},
            {'x': 'Jun', 'y': 180},
            {'x': 'Jul', 'y': 170},
            {'x': 'Aug', 'y': 150},
            {'x': 'Sep', 'y': 160},
            {'x': 'Oct', 'y': 140},
            {'x': 'Nov', 'y': 120},
            {'x': 'Dec', 'y': 160},
          ],
          itemStyle: ItemStyle(color: 'rgba(255, 0, 0, 0.5)'),
        ),
      ],
      curveSmoothness: 0.3,
      showDots: true,
      dotSize: 5.0,
      areaOpacity: 0.25,
      gradientArea: true,
      legend: ChartLegend(),
      tooltip: ChartTooltip(show: true),
      grid: Grid(show: true),
    );

    return SizedBox(
      height: 400,
      child: AreaChartWidget(config: areaChartConfig),
    );
  }
}
