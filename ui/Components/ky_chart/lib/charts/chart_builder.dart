import 'package:flutter/material.dart';

import 'base_chart_config.dart';

class TenunChart extends StatelessWidget {
  final BaseChartConfig config;

  const TenunChart({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ChartFactory.createChart(config);
  }
}

class ChartFactory {
  static Widget createChart(BaseChartConfig config) {
    return config.buildChart();
  }
}
