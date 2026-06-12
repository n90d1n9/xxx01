import 'package:flutter/material.dart';

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class AllChartsGalleryExample extends StatelessWidget {
  const AllChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    return ChartSampleFamilyGallery(
      family: ChartSamplesRegistry.canonicalMixedFamily,
      options: options,
    );
  }
}
