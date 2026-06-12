import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro_business_ai_ml.dart' hide FontWeight;

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class AIMLChartsExample extends StatelessWidget {
  const AIMLChartsExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    registerTenunProBusinessAiMlCharts();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const family = ChartSamplesRegistry.aiMLFamily;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI/ML Evaluation Charts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            for (final sample in family.samples)
              ChartSamplePanel(sample: sample, options: options),
          ],
        ),
      ),
    );
  }
}
