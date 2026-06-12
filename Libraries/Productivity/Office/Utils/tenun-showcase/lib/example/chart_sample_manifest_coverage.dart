import 'package:tenun/tenun.dart';

import 'chart_samples_registry.dart';

Iterable<String> showcaseChartTypesForFamilies(
  Iterable<ChartShowcaseFamily> families,
) sync* {
  for (final family in families) {
    yield* family.chartTypes;
  }
}

List<String> uniqueShowcaseChartTypesForFamilies(
  Iterable<ChartShowcaseFamily> families,
) {
  final seen = <String>{};
  final out = <String>[];

  for (final type in showcaseChartTypesForFamilies(families)) {
    final trimmed = type.trim();
    if (trimmed.isEmpty) continue;

    if (seen.add(normalizeChartTypeKey(trimmed))) {
      out.add(trimmed);
    }
  }

  return List<String>.unmodifiable(out);
}

ChartFamilyShowcaseCoverageReport chartSampleCoverageForFamilies(
  Iterable<ChartShowcaseFamily> families, {
  ChartFamilyManifest? manifest,
  bool unique = true,
}) {
  final exampleKeys = unique
      ? uniqueShowcaseChartTypesForFamilies(families)
      : showcaseChartTypesForFamilies(families);

  return (manifest ?? ChartFamilyManifests.available()).showcaseCoverage(
    exampleKeys,
  );
}

ChartFamilyShowcaseCoverageReport focusedChartSampleCoverage({
  ChartFamilyManifest? manifest,
  bool unique = true,
}) {
  return chartSampleCoverageForFamilies(
    ChartSamplesRegistry.focusedFamilies,
    manifest: manifest,
    unique: unique,
  );
}
