import 'package:flutter/material.dart';

import 'chart_sample_showcase.dart';
import 'chart_samples_registry.dart';

class HierarchyChartsGalleryExample extends StatelessWidget {
  const HierarchyChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) => _ShapeGallery(
    family: ChartSamplesRegistry.hierarchyFamily,
    options: options,
  );
}

class FlowChartsGalleryExample extends StatelessWidget {
  const FlowChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) =>
      _ShapeGallery(family: ChartSamplesRegistry.flowFamily, options: options);
}

class RadialChartsGalleryExample extends StatelessWidget {
  const RadialChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) => _ShapeGallery(
    family: ChartSamplesRegistry.radialDataShapeFamily,
    options: options,
  );
}

class GeoChartsGalleryExample extends StatelessWidget {
  const GeoChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) =>
      _ShapeGallery(family: ChartSamplesRegistry.geoFamily, options: options);
}

class TextTimelineChartsGalleryExample extends StatelessWidget {
  const TextTimelineChartsGalleryExample({
    super.key,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) => _ShapeGallery(
    family: ChartSamplesRegistry.textTimelineFamily,
    options: options,
  );
}

class _ShapeGallery extends StatelessWidget {
  final ChartShowcaseFamily family;
  final ChartSampleShowcaseOptions options;

  const _ShapeGallery({required this.family, required this.options});

  @override
  Widget build(BuildContext context) {
    return ChartSampleFamilyGallery(family: family, options: options);
  }
}
