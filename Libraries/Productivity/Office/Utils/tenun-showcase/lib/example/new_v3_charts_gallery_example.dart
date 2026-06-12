import 'package:flutter/material.dart';

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class NewV3ChartsGalleryExample extends StatelessWidget {
  const NewV3ChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    return ChartSampleFamilyGallery(
      family: ChartSamplesRegistry.v3VariantFamily,
      options: options,
    );
  }
}
