import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro_business_ai_ml.dart' hide FontWeight;

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class BusinessChartsExample extends StatelessWidget {
  const BusinessChartsExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    registerTenunProBusinessAiMlCharts();

    return Scaffold(
      appBar: AppBar(title: const Text('Business & Project Charts')),
      body: ChartSampleFamilyGallery(
        family: ChartSamplesRegistry.businessProjectFamily,
        options: options,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
