import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro_enterprise_analytics.dart';

class HeatmapChartExample extends StatelessWidget {
  const HeatmapChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    registerTenunProEnterpriseAnalyticsCharts();

    final heatmapJson = <String, dynamic>{
      'type': 'heatmap',
      'title': {'text': 'Temperature Heatmap'},
      'xLabels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      'yLabels': ['Morning', 'Afternoon', 'Evening'],
      'series': [
        {
          'data': [
            [12.5, 11.0, 13.2, 14.1, 15.5],
            [24.8, 25.2, 28.6, 27.4, 26.3],
            [18.3, 17.5, 21.3, 20.2, 19.7],
          ],
        },
      ],
      'lowColor': '#BBDEFB',
      'highColor': '#F44336',
      'showValues': true,
      'legend': {'show': true},
      'tooltip': {'show': true},
    };

    return SizedBox(
      height: 400,
      child: TenunChartFromJson(jsonConfig: heatmapJson),
    );
  }
}
