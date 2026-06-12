import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'area_chart_data.dart';

class AreaVariantSection extends StatelessWidget {
  const AreaVariantSection({
    super.key,
    required this.title,
    required this.chart,
  });

  final String title;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(height: 300, child: chart),
        const SizedBox(height: 22),
      ],
    );
  }
}

class AreaSmoothVariantExample extends StatelessWidget {
  const AreaSmoothVariantExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TenunChartFromJson(
      jsonConfig: AreaChartSamples.smoothJson,
      padding: const EdgeInsets.all(8),
    );
  }
}

class AreaStraightVariantExample extends StatelessWidget {
  const AreaStraightVariantExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TenunChartFromJson(
      jsonConfig: AreaChartSamples.straightNoDotsJson,
      padding: const EdgeInsets.all(8),
    );
  }
}

class AreaPositiveNegativeVariantExample extends StatelessWidget {
  const AreaPositiveNegativeVariantExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TenunChartFromJson(
      jsonConfig: AreaChartSamples.positiveNegativeJson,
      padding: const EdgeInsets.all(8),
    );
  }
}

class AreaDenseVariantExample extends StatelessWidget {
  const AreaDenseVariantExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TenunChartFromJson(
      jsonConfig: AreaChartSamples.denseDailyJson,
      padding: const EdgeInsets.all(8),
    );
  }
}

class AreaConfigVariantExample extends StatelessWidget {
  const AreaConfigVariantExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TenunChart(
      config: AreaChartSamples.configObject,
      padding: const EdgeInsets.all(8),
    );
  }
}
