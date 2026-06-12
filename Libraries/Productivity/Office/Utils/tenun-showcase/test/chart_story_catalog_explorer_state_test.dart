import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_selection.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_snapshot.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_state.dart';
import 'package:tenun_showcase/story/chart_story_catalog_presets.dart';
import 'package:tenun_showcase/story/chart_story_contract_coverage.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';

void main() {
  test('catalog explorer filters match quick view presets', () {
    final preset = chartStoryCatalogPresets.singleWhere(
      (preset) => preset.id == 'review-gaps',
    );
    final filters = ChartCatalogExplorerFilters(
      contractStatus: preset.contractStatus,
    );

    expect(filters.hasActiveFilters, isTrue);
    expect(filters.matchesPreset(preset), isTrue);
  });

  test('catalog explorer filters match tier quick view presets', () {
    final preset = chartStoryCatalogPresets.singleWhere(
      (preset) => preset.id == 'pro-tier',
    );
    final filters = ChartCatalogExplorerFilters(tier: preset.tier);
    final entries = filterChartCatalogEntries(chartStoryCatalog, filters);

    expect(filters.hasActiveFilters, isTrue);
    expect(filters.matchesPreset(preset), isTrue);
    expect(entries, isNotEmpty);
    expect(
      entries.every((entry) => entry.tierKey == ChartStoryTier.pro.key),
      isTrue,
    );
  });

  test('catalog explorer filters support contextual facet counts', () {
    const filters = ChartCatalogExplorerFilters(
      query: 'temperature heatmap',
      categoryLabel: 'Core Shapes',
      dataShape: 'Matrix',
    );

    final entries = filterChartCatalogEntries(chartStoryCatalog, filters);
    final entriesWithoutShape = filterChartCatalogEntries(
      chartStoryCatalog,
      filters,
      includeDataShape: false,
    );
    final shapeCounts = chartCatalogEntryCountsBy(
      (entry) => entry.dataShape,
      entries: entriesWithoutShape,
    );

    expect(entries, isNotEmpty);
    expect(entries.every((entry) => entry.dataShape == 'Matrix'), isTrue);
    expect(shapeCounts['Matrix'], greaterThanOrEqualTo(entries.length));
  });

  test('catalog explorer selection toggles facets and converts to filters', () {
    const selection = ChartCatalogExplorerSelection(
      categoryLabel: 'Core Shapes',
      dataShape: 'Matrix',
      contractStatus: ChartStoryContractStatusFilter.needsWork,
    );
    final clearedCategory = selection.toggleFacet(
      ChartCatalogExplorerFacet.category,
      'Core Shapes',
    );
    final selectedFamily = selection.toggleFacet(
      ChartCatalogExplorerFacet.family,
      'Heatmap',
    );
    final selectedTier = selection.toggleFacet(
      ChartCatalogExplorerFacet.tier,
      ChartStoryTier.pro.key,
    );
    final filters = selectedFamily.toFilters(query: 'temperature');

    expect(clearedCategory.categoryLabel, isNull);
    expect(selectedFamily.family, 'Heatmap');
    expect(selectedTier.tier, ChartStoryTier.pro.key);
    expect(filters.query, 'temperature');
    expect(filters.categoryLabel, 'Core Shapes');
    expect(filters.dataShape, 'Matrix');
    expect(filters.contractStatus, ChartStoryContractStatusFilter.needsWork);
    expect(filters.hasActiveFilters, isTrue);
  });

  test('catalog explorer sorting keeps catalog order by default', () {
    final catalogEntries = chartStoryCatalog.entries;

    expect(
      sortChartCatalogEntries(
        catalogEntries,
        ChartCatalogResultSortMode.catalog,
      ),
      same(catalogEntries),
    );
  });

  test('catalog explorer can sort entries by title', () {
    final sortedEntries = sortChartCatalogEntries(
      chartStoryCatalog.entries,
      ChartCatalogResultSortMode.title,
    );
    final firstTitle = sortedEntries.first.leaf ?? sortedEntries.first.name;
    final secondTitle = sortedEntries[1].leaf ?? sortedEntries[1].name;

    expect(
      firstTitle.toLowerCase().compareTo(secondTitle.toLowerCase()),
      lessThanOrEqualTo(0),
    );
  });

  test('catalog explorer can sort and group entries by tier', () {
    final sortedEntries = sortChartCatalogEntries(
      chartStoryCatalog.entries,
      ChartCatalogResultSortMode.tier,
    );
    final groups = groupChartCatalogEntries(
      chartStoryCatalog.entries,
      ChartCatalogResultGroupMode.tier,
    );

    expect(sortedEntries.first.tierKey, ChartStoryTier.core.key);
    expect(groups.map((group) => group.label), containsAll(['Core', 'Pro']));
    expect(
      groups.singleWhere((group) => group.label == 'Pro').entries,
      everyElement(
        isA<ChartStoryEntry>().having(
          (entry) => entry.tierKey,
          'tierKey',
          ChartStoryTier.pro.key,
        ),
      ),
    );
  });

  test('catalog explorer exposes tier keys and entries by tier', () {
    expect(chartStoryCatalog.tierKeys, [
      ChartStoryTier.core.key,
      ChartStoryTier.pro.key,
    ]);
    expect(
      chartStoryCatalog.entriesForTier(ChartStoryTier.pro.key),
      everyElement(
        isA<ChartStoryEntry>().having(
          (entry) => entry.tierKey,
          'tierKey',
          ChartStoryTier.pro.key,
        ),
      ),
    );
  });

  test('catalog explorer groups entries by contract readiness', () {
    final groups = groupChartCatalogEntries(
      chartStoryCatalog.entries,
      ChartCatalogResultGroupMode.contract,
    );
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final groupedCount = groups.fold<int>(
      0,
      (count, group) => count + group.entries.length,
    );

    expect(groupedCount, chartStoryCatalog.storyCount);
    expect(
      groups.singleWhere((group) => group.label == 'Ready').entries,
      hasLength(coverage.readyCount),
    );
  });

  test('catalog explorer snapshot centralizes derived result data', () {
    const filters = ChartCatalogExplorerFilters(
      query: 'temperature heatmap',
      categoryLabel: 'Core Shapes',
      dataShape: 'Matrix',
    );
    final snapshot = ChartCatalogExplorerSnapshot.fromCatalog(
      catalog: chartStoryCatalog,
      filters: filters,
      sortMode: ChartCatalogResultSortMode.title,
      maxVisibleEntries: 2,
    );
    final expectedEntries = filterChartCatalogEntries(
      chartStoryCatalog,
      filters,
    );

    expect(snapshot.matchingEntries, isNotEmpty);
    expect(snapshot.visibleEntryCount, lessThanOrEqualTo(2));
    expect(snapshot.matchingEntryCount, expectedEntries.length);
    expect(
      snapshot.tierCounts[ChartStoryTier.pro.key],
      greaterThanOrEqualTo(1),
    );
    expect(snapshot.dataShapeCounts['Matrix'], snapshot.matchingEntryCount);
    expect(snapshot.categoryCounts['Core Shapes'], snapshot.matchingEntryCount);
    expect(
      snapshot.contractStatusCounts[ChartStoryContractStatusFilter.all],
      snapshot.matchingEntryCount,
    );
  });
}
