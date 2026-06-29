import 'package:flutter/material.dart';

import 'base_chart_config.dart';

class KChart extends StatelessWidget {
  final BaseChartConfig config;

  const KChart({super.key, required this.config});

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
