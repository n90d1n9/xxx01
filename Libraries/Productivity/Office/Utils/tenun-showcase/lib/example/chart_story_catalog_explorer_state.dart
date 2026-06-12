import '../story/chart_story_catalog_presets.dart';
import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import '../story/chart_story_tier.dart';

enum ChartCatalogResultSortMode {
  catalog,
  title,
  tier,
  category,
  family,
  group,
}

enum ChartCatalogResultGroupMode {
  tier,
  category,
  group,
  section,
  dataShape,
  family,
  contract,
}

class ChartCatalogExplorerFilters {
  const ChartCatalogExplorerFilters({
    this.query = '',
    this.tier,
    this.categoryLabel,
    this.groupId,
    this.section,
    this.dataShape,
    this.family,
    this.contractStatus = ChartStoryContractStatusFilter.all,
  });

  final String query;
  final String? tier;
  final String? categoryLabel;
  final String? groupId;
  final String? section;
  final String? dataShape;
  final String? family;
  final ChartStoryContractStatusFilter contractStatus;

  bool get hasActiveFilters {
    return query.trim().isNotEmpty ||
        tier != null ||
        categoryLabel != null ||
        groupId != null ||
        section != null ||
        dataShape != null ||
        family != null ||
        contractStatus != ChartStoryContractStatusFilter.all;
  }

  bool matchesPreset(ChartStoryCatalogPreset preset) {
    return query.trim() == preset.query.trim() &&
        tier == preset.tier &&
        categoryLabel == preset.categoryLabel &&
        groupId == preset.groupId &&
        section == preset.section &&
        dataShape == preset.dataShape &&
        family == preset.family &&
        contractStatus == preset.contractStatus;
  }
}

class ChartCatalogResultGroup {
  const ChartCatalogResultGroup({required this.label, required this.entries});

  final String label;
  final List<ChartStoryEntry> entries;
}

List<ChartStoryEntry> filterChartCatalogEntries(
  ChartStoryCatalog catalog,
  ChartCatalogExplorerFilters filters, {
  bool includeCategory = true,
  bool includeTier = true,
  bool includeGroup = true,
  bool includeSection = true,
  bool includeDataShape = true,
  bool includeFamily = true,
  bool includeContractStatus = true,
}) {
  Iterable<ChartStoryEntry> entries = catalog.entriesMatchingQuery(
    filters.query,
  );

  final tier = filters.tier;
  if (includeTier && tier != null) {
    entries = entries.where((entry) => entry.tierKey == tier);
  }

  final category = filters.categoryLabel;
  if (includeCategory && category != null) {
    entries = entries.where((entry) => entry.categoryLabel == category);
  }

  final groupId = filters.groupId;
  if (includeGroup && groupId != null) {
    entries = entries.where((entry) => entry.groupId == groupId);
  }

  final section = filters.section;
  if (includeSection && section != null) {
    entries = entries.where((entry) => entry.section == section);
  }

  final dataShape = filters.dataShape;
  if (includeDataShape && dataShape != null) {
    entries = entries.where((entry) => entry.dataShape == dataShape);
  }

  final family = filters.family;
  if (includeFamily && family != null) {
    entries = entries.where((entry) => entry.family == family);
  }

  final contractStatus = filters.contractStatus;
  if (includeContractStatus &&
      contractStatus != ChartStoryContractStatusFilter.all) {
    entries = entries.where(
      (entry) => chartStoryMatchesContractStatus(entry, contractStatus),
    );
  }

  return entries.toList(growable: false);
}

List<ChartStoryEntry> sortChartCatalogEntries(
  List<ChartStoryEntry> entries,
  ChartCatalogResultSortMode sortMode,
) {
  if (sortMode == ChartCatalogResultSortMode.catalog) {
    return entries;
  }

  final sortedEntries = entries.toList(growable: false);
  sortedEntries.sort((a, b) {
    return switch (sortMode) {
      ChartCatalogResultSortMode.catalog => 0,
      ChartCatalogResultSortMode.title => compareChartCatalogEntryText(
        a.leaf ?? a.name,
        b.leaf ?? b.name,
        a,
        b,
      ),
      ChartCatalogResultSortMode.tier => compareChartCatalogEntryText(
        a.tierLabel,
        b.tierLabel,
        a,
        b,
      ),
      ChartCatalogResultSortMode.category => compareChartCatalogEntryText(
        a.categoryLabel,
        b.categoryLabel,
        a,
        b,
      ),
      ChartCatalogResultSortMode.family => compareChartCatalogEntryText(
        a.family ?? '',
        b.family ?? '',
        a,
        b,
      ),
      ChartCatalogResultSortMode.group => compareChartCatalogEntryText(
        a.groupLabel,
        b.groupLabel,
        a,
        b,
      ),
    };
  });

  return sortedEntries;
}

Map<String, int> chartCatalogEntryCountsBy(
  String? Function(ChartStoryEntry) valueOf, {
  required List<ChartStoryEntry> entries,
}) {
  final counts = <String, int>{};

  for (final entry in entries) {
    final value = valueOf(entry);
    if (value == null || value.isEmpty) {
      continue;
    }

    counts[value] = (counts[value] ?? 0) + 1;
  }

  return Map.unmodifiable(counts);
}

Map<ChartStoryContractStatusFilter, int>
chartCatalogEntryCountsByContractStatus({
  required List<ChartStoryEntry> entries,
}) {
  final counts = <ChartStoryContractStatusFilter, int>{};

  for (final status in chartStoryContractStatusFilters) {
    counts[status] = entries
        .where((entry) => chartStoryMatchesContractStatus(entry, status))
        .length;
  }

  return Map.unmodifiable(counts);
}

List<ChartCatalogResultGroup> groupChartCatalogEntries(
  List<ChartStoryEntry> entries,
  ChartCatalogResultGroupMode groupMode,
) {
  final groups = <String, List<ChartStoryEntry>>{};

  for (final entry in entries) {
    final label = chartCatalogResultGroupLabel(entry, groupMode);
    groups.putIfAbsent(label, () => []).add(entry);
  }

  return [
    for (final group in groups.entries)
      ChartCatalogResultGroup(
        label: group.key,
        entries: List.unmodifiable(group.value),
      ),
  ];
}

String chartCatalogResultGroupLabel(
  ChartStoryEntry entry,
  ChartCatalogResultGroupMode groupMode,
) {
  return switch (groupMode) {
    ChartCatalogResultGroupMode.tier => chartStoryTierLabelForKey(
      entry.tierKey,
    ),
    ChartCatalogResultGroupMode.category => entry.categoryLabel,
    ChartCatalogResultGroupMode.group => entry.groupLabel,
    ChartCatalogResultGroupMode.section => entry.section ?? 'No section',
    ChartCatalogResultGroupMode.dataShape => entry.dataShape ?? 'No data shape',
    ChartCatalogResultGroupMode.family => entry.family ?? 'No family',
    ChartCatalogResultGroupMode.contract => chartStoryContractReadinessLabel(
      entry,
    ),
  };
}

int compareChartCatalogEntryText(
  String first,
  String second,
  ChartStoryEntry firstEntry,
  ChartStoryEntry secondEntry,
) {
  final value = first.toLowerCase().compareTo(second.toLowerCase());
  if (value != 0) {
    return value;
  }

  return firstEntry.name.toLowerCase().compareTo(
    secondEntry.name.toLowerCase(),
  );
}
