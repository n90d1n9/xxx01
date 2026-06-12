import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_story_catalog_presets.dart';
import 'package:tenun_showcase/story/chart_story_contract_coverage.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';

void main() {
  test('catalog quick view presets match their declared filters', () {
    for (final preset in chartStoryCatalogPresets) {
      final entries = preset.entriesIn(chartStoryCatalog);

      expect(entries.every(preset.matchesEntry), isTrue);
      if (preset.hasFilters) {
        expect(entries, isNotEmpty, reason: '${preset.label} should resolve.');
      } else {
        expect(entries, hasLength(chartStoryCatalog.storyCount));
      }
    }
  });

  test('catalog quick view preset counts match catalog coverage', () {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final reviewGaps = _presetById('review-gaps');
    final jsonGaps = _presetById('json-gaps');
    final coreShapes = _presetById('core-shapes');

    expect(
      reviewGaps.entriesIn(chartStoryCatalog),
      hasLength(coverage.gapCount),
    );
    expect(
      jsonGaps.entriesIn(chartStoryCatalog),
      hasLength(coverage.totalCount - coverage.sampleJsonCount),
    );
    expect(
      coreShapes.entriesIn(chartStoryCatalog),
      hasLength(chartStoryCatalog.entriesForCategory('Core Shapes').length),
    );
  });
}

ChartStoryCatalogPreset _presetById(String id) {
  return chartStoryCatalogPresets.singleWhere((preset) => preset.id == id);
}
