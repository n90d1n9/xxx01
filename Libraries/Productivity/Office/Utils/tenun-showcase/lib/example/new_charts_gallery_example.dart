import 'package:flutter/material.dart';

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class NewChartsGalleryExample extends StatelessWidget {
  const NewChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    return ChartSampleFamilyGallery(
      family: ChartSamplesRegistry.statTradingGraphFamily,
      options: options,
    );
  }
}
