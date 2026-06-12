import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import 'chart_story_catalog_explorer_state.dart';

class ChartCatalogExplorerSnapshot {
  const ChartCatalogExplorerSnapshot._({
    required this.matchingEntries,
    required this.visibleEntries,
    required this.tierCounts,
    required this.categoryCounts,
    required this.groupCounts,
    required this.sectionCounts,
    required this.dataShapeCounts,
    required this.familyCounts,
    required this.contractStatusCounts,
  });

  factory ChartCatalogExplorerSnapshot.fromCatalog({
    required ChartStoryCatalog catalog,
    required ChartCatalogExplorerFilters filters,
    required ChartCatalogResultSortMode sortMode,
    required int maxVisibleEntries,
  }) {
    final matchingEntries = sortChartCatalogEntries(
      filterChartCatalogEntries(catalog, filters),
      sortMode,
    );
    final visibleLimit = maxVisibleEntries < 0 ? 0 : maxVisibleEntries;

    return ChartCatalogExplorerSnapshot._(
      matchingEntries: List.unmodifiable(matchingEntries),
      visibleEntries: List.unmodifiable(matchingEntries.take(visibleLimit)),
      tierCounts: chartCatalogEntryCountsBy(
        (entry) => entry.tierKey,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeTier: false,
        ),
      ),
      categoryCounts: chartCatalogEntryCountsBy(
        (entry) => entry.categoryLabel,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeCategory: false,
        ),
      ),
      groupCounts: chartCatalogEntryCountsBy(
        (entry) => entry.groupId,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeGroup: false,
        ),
      ),
      sectionCounts: chartCatalogEntryCountsBy(
        (entry) => entry.section,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeSection: false,
        ),
      ),
      dataShapeCounts: chartCatalogEntryCountsBy(
        (entry) => entry.dataShape,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeDataShape: false,
        ),
      ),
      familyCounts: chartCatalogEntryCountsBy(
        (entry) => entry.family,
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeFamily: false,
        ),
      ),
      contractStatusCounts: chartCatalogEntryCountsByContractStatus(
        entries: filterChartCatalogEntries(
          catalog,
          filters,
          includeContractStatus: false,
        ),
      ),
    );
  }

  final List<ChartStoryEntry> matchingEntries;
  final List<ChartStoryEntry> visibleEntries;
  final Map<String, int> tierCounts;
  final Map<String, int> categoryCounts;
  final Map<String, int> groupCounts;
  final Map<String, int> sectionCounts;
  final Map<String, int> dataShapeCounts;
  final Map<String, int> familyCounts;
  final Map<ChartStoryContractStatusFilter, int> contractStatusCounts;

  int get matchingEntryCount => matchingEntries.length;

  int get visibleEntryCount => visibleEntries.length;

  int get hiddenEntryCount => matchingEntryCount - visibleEntryCount;

  bool get hasHiddenEntries => hiddenEntryCount > 0;
}
