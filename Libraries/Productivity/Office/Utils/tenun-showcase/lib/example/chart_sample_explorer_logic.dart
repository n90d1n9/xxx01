import 'chart_samples_registry.dart';

enum ChartFamilySortMode { curated, name, samples, chartTypes }

class ChartFamilyExplorerStats {
  const ChartFamilyExplorerStats({
    required this.familyCount,
    required this.sampleCount,
    required this.typeCount,
  });

  final int familyCount;
  final int sampleCount;
  final int typeCount;
}

class ChartTypeFilterOption {
  const ChartTypeFilterOption({required this.type, required this.familyCount});

  final String type;
  final int familyCount;
}

class ChartTierFilterOption {
  const ChartTierFilterOption({
    required this.tierFilter,
    required this.familyCount,
  });

  final ChartShowcaseTierFilter tierFilter;
  final int familyCount;
}

class ChartFamilyExplorerSnapshot {
  const ChartFamilyExplorerSnapshot({
    required this.tierOptions,
    required this.typeOptions,
    required this.filteredFamilies,
    required this.totalStats,
    required this.visibleStats,
    required this.selectedFamily,
    required this.selectedSamples,
    required this.hasActiveFilters,
  });

  final List<ChartTierFilterOption> tierOptions;
  final List<ChartTypeFilterOption> typeOptions;
  final List<ChartShowcaseFamily> filteredFamilies;
  final ChartFamilyExplorerStats totalStats;
  final ChartFamilyExplorerStats visibleStats;
  final ChartShowcaseFamily? selectedFamily;
  final List<ChartShowcaseSample> selectedSamples;
  final bool hasActiveFilters;
}

ChartFamilyExplorerSnapshot chartFamilyExplorerSnapshot({
  required List<ChartShowcaseFamily> families,
  required String query,
  ChartShowcaseTierFilter selectedTierFilter = ChartShowcaseTierFilter.all,
  required String? selectedChartType,
  required String? selectedFamilyId,
  required ChartFamilySortMode sortMode,
}) {
  final tierOptions = chartTierFilterOptions(families);
  final tierScopedFamilies = chartShowcaseFamiliesForTier(
    families,
    selectedTierFilter,
  );
  final typeOptions = chartTypeFilterOptions(tierScopedFamilies);
  final hasActiveFilters = hasActiveChartFamilyFilters(
    query: query,
    selectedTierFilter: selectedTierFilter,
    selectedChartType: selectedChartType,
  );
  final filteredFamilies = filterChartFamilies(
    families: families,
    query: query,
    selectedTierFilter: selectedTierFilter,
    selectedChartType: selectedChartType,
    sortMode: sortMode,
  );
  final totalStats = chartFamilyExplorerStats(
    families: families,
    query: query,
    selectedChartType: selectedChartType,
    filterSamples: false,
  );
  final visibleStats = chartFamilyExplorerStats(
    families: filteredFamilies,
    query: query,
    selectedChartType: selectedChartType,
    filterSamples: hasActiveFilters,
  );
  final selectedFamily = selectedChartFamilyIn(
    families: filteredFamilies,
    selectedFamilyId: selectedFamilyId,
  );
  final selectedSamples = selectedFamily == null
      ? const <ChartShowcaseSample>[]
      : visibleChartSamplesForFamily(
          family: selectedFamily,
          query: query,
          selectedChartType: selectedChartType,
        );

  return ChartFamilyExplorerSnapshot(
    tierOptions: tierOptions,
    typeOptions: typeOptions,
    filteredFamilies: filteredFamilies,
    totalStats: totalStats,
    visibleStats: visibleStats,
    selectedFamily: selectedFamily,
    selectedSamples: selectedSamples,
    hasActiveFilters: hasActiveFilters,
  );
}

bool hasActiveChartFamilyFilters({
  required String query,
  ChartShowcaseTierFilter selectedTierFilter = ChartShowcaseTierFilter.all,
  required String? selectedChartType,
}) {
  return query.trim().isNotEmpty ||
      selectedTierFilter != ChartShowcaseTierFilter.all ||
      selectedChartType != null;
}

String? resolveChartFamilyId({
  required List<ChartShowcaseFamily> families,
  required String? requestedId,
}) {
  if (requestedId != null) {
    for (final family in families) {
      if (family.id == requestedId) {
        return family.id;
      }
    }
  }
  return families.isEmpty ? null : families.first.id;
}

bool chartFamilyIdExists({
  required List<ChartShowcaseFamily> families,
  required String? familyId,
}) {
  return familyId != null && families.any((family) => family.id == familyId);
}

ChartShowcaseTierFilter sanitizeSelectedTierFilter({
  required List<ChartShowcaseFamily> families,
  required ChartShowcaseTierFilter selectedTierFilter,
}) {
  if (selectedTierFilter == ChartShowcaseTierFilter.all) {
    return ChartShowcaseTierFilter.all;
  }
  return families.any((family) => selectedTierFilter.includes(family.tier))
      ? selectedTierFilter
      : ChartShowcaseTierFilter.all;
}

String? sanitizeSelectedChartType({
  required List<ChartShowcaseFamily> families,
  required String? selectedChartType,
}) {
  if (selectedChartType == null) {
    return null;
  }
  return chartTypeFilterOptions(
        families,
      ).any((option) => chartTypeMatches(option.type, selectedChartType))
      ? selectedChartType
      : null;
}

ChartShowcaseFamily? selectedChartFamilyIn({
  required List<ChartShowcaseFamily> families,
  required String? selectedFamilyId,
}) {
  for (final family in families) {
    if (family.id == selectedFamilyId) {
      return family;
    }
  }
  return families.isEmpty ? null : families.first;
}

String? resolveVisibleChartFamilyId({
  required List<ChartShowcaseFamily> families,
  required String query,
  ChartShowcaseTierFilter selectedTierFilter = ChartShowcaseTierFilter.all,
  required String? selectedChartType,
  required String? selectedFamilyId,
  required ChartFamilySortMode sortMode,
}) {
  return selectedChartFamilyIn(
    families: filterChartFamilies(
      families: families,
      query: query,
      selectedTierFilter: selectedTierFilter,
      selectedChartType: selectedChartType,
      sortMode: sortMode,
    ),
    selectedFamilyId: selectedFamilyId,
  )?.id;
}

List<ChartShowcaseFamily> filterChartFamilies({
  required List<ChartShowcaseFamily> families,
  required String query,
  ChartShowcaseTierFilter selectedTierFilter = ChartShowcaseTierFilter.all,
  required String? selectedChartType,
  required ChartFamilySortMode sortMode,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final matches = [
    for (final family in families)
      if (chartFamilyMatchesTier(family, selectedTierFilter) &&
          chartFamilyMatchesType(family, selectedChartType) &&
          (normalizedQuery.isEmpty ||
              chartFamilyMatchesQuery(family, normalizedQuery)))
        family,
  ];
  return sortChartFamilies(matches, sortMode);
}

bool chartFamilyMatchesTier(
  ChartShowcaseFamily family,
  ChartShowcaseTierFilter selectedTierFilter,
) {
  return selectedTierFilter.includes(family.tier);
}

bool chartFamilyMatchesQuery(ChartShowcaseFamily family, String query) {
  return family.id.toLowerCase().contains(query) ||
      family.title.toLowerCase().contains(query) ||
      family.description.toLowerCase().contains(query) ||
      family.tier.key.toLowerCase().contains(query) ||
      family.tierLabel.toLowerCase().contains(query) ||
      family.uniqueChartTypes.any(
        (type) => type.toLowerCase().contains(query),
      ) ||
      family.samples.any((sample) => chartSampleMatchesQuery(sample, query));
}

bool chartFamilyMatchesType(
  ChartShowcaseFamily family,
  String? selectedChartType,
) {
  if (selectedChartType == null) {
    return true;
  }
  return family.uniqueChartTypes.any(
    (type) => chartTypeMatches(type, selectedChartType),
  );
}

List<ChartShowcaseFamily> sortChartFamilies(
  List<ChartShowcaseFamily> families,
  ChartFamilySortMode sortMode,
) {
  if (sortMode == ChartFamilySortMode.curated) {
    return families;
  }

  final sorted = families.toList(growable: false);
  sorted.sort((a, b) {
    return switch (sortMode) {
      ChartFamilySortMode.curated => 0,
      ChartFamilySortMode.name => compareChartFamilyNames(a, b),
      ChartFamilySortMode.samples =>
        compareDescending(a.sampleCount, b.sampleCount) ??
            compareChartFamilyNames(a, b),
      ChartFamilySortMode.chartTypes =>
        compareDescending(
              a.uniqueChartTypes.length,
              b.uniqueChartTypes.length,
            ) ??
            compareChartFamilyNames(a, b),
    };
  });
  return sorted;
}

List<ChartShowcaseSample> visibleChartSamplesForFamily({
  required ChartShowcaseFamily family,
  required String query,
  required String? selectedChartType,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final typeFiltered = [
    for (final sample in family.samples)
      if (chartSampleMatchesType(sample, selectedChartType)) sample,
  ];
  if (normalizedQuery.isEmpty) {
    return typeFiltered;
  }

  final queryFiltered = [
    for (final sample in typeFiltered)
      if (chartSampleMatchesQuery(sample, normalizedQuery)) sample,
  ];
  return queryFiltered.isEmpty ? typeFiltered : queryFiltered;
}

bool chartSampleMatchesType(
  ChartShowcaseSample sample,
  String? selectedChartType,
) {
  if (selectedChartType == null) {
    return true;
  }
  final type = chartSampleType(sample);
  return type != null && chartTypeMatches(type, selectedChartType);
}

bool chartSampleMatchesQuery(ChartShowcaseSample sample, String query) {
  final type = chartSampleType(sample);
  return sample.title.toLowerCase().contains(query) ||
      (type != null && type.toLowerCase().contains(query));
}

ChartFamilyExplorerStats chartFamilyExplorerStats({
  required List<ChartShowcaseFamily> families,
  required String query,
  required String? selectedChartType,
  required bool filterSamples,
}) {
  final types = <String>{};
  var sampleCount = 0;

  for (final family in families) {
    final samples = filterSamples
        ? visibleChartSamplesForFamily(
            family: family,
            query: query,
            selectedChartType: selectedChartType,
          )
        : family.samples;
    sampleCount += samples.length;
    for (final sample in samples) {
      final type = chartSampleType(sample);
      if (type != null) {
        types.add(type.toLowerCase());
      }
    }
  }

  return ChartFamilyExplorerStats(
    familyCount: families.length,
    sampleCount: sampleCount,
    typeCount: types.length,
  );
}

List<ChartTypeFilterOption> chartTypeFilterOptions(
  List<ChartShowcaseFamily> families,
) {
  final displayTypes = <String, String>{};
  final familyCounts = <String, int>{};

  for (final family in families) {
    final seenInFamily = <String>{};
    for (final type in family.uniqueChartTypes) {
      final normalizedType = type.toLowerCase();
      if (!seenInFamily.add(normalizedType)) {
        continue;
      }
      displayTypes.putIfAbsent(normalizedType, () => type);
      familyCounts[normalizedType] = (familyCounts[normalizedType] ?? 0) + 1;
    }
  }

  final sortedTypes = familyCounts.keys.toList()
    ..sort((a, b) {
      final byCount = familyCounts[b]!.compareTo(familyCounts[a]!);
      if (byCount != 0) {
        return byCount;
      }
      return displayTypes[a]!.compareTo(displayTypes[b]!);
    });

  return [
    for (final type in sortedTypes)
      ChartTypeFilterOption(
        type: displayTypes[type]!,
        familyCount: familyCounts[type]!,
      ),
  ];
}

List<ChartTierFilterOption> chartTierFilterOptions(
  List<ChartShowcaseFamily> families,
) {
  final familyCounts = <ChartShowcaseTierFilter, int>{};
  for (final family in families) {
    final filter = switch (family.tier) {
      ChartShowcaseTier.core => ChartShowcaseTierFilter.core,
      ChartShowcaseTier.pro => ChartShowcaseTierFilter.pro,
      ChartShowcaseTier.custom => ChartShowcaseTierFilter.custom,
    };
    familyCounts[filter] = (familyCounts[filter] ?? 0) + 1;
  }

  return [
    for (final filter in ChartShowcaseTierFilter.values)
      if (filter != ChartShowcaseTierFilter.all &&
          (familyCounts[filter] ?? 0) > 0)
        ChartTierFilterOption(
          tierFilter: filter,
          familyCount: familyCounts[filter]!,
        ),
  ];
}

bool chartTypeMatches(String a, String b) => a.toLowerCase() == b.toLowerCase();

String? chartSampleType(ChartShowcaseSample sample) {
  final type = sample.json['type'];
  return type is String && type.isNotEmpty ? type : null;
}

String chartFamilySortModeLabel(ChartFamilySortMode mode) {
  return switch (mode) {
    ChartFamilySortMode.curated => 'Curated',
    ChartFamilySortMode.name => 'Name',
    ChartFamilySortMode.samples => 'Samples',
    ChartFamilySortMode.chartTypes => 'Types',
  };
}

int compareChartFamilyNames(ChartShowcaseFamily a, ChartShowcaseFamily b) {
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

int? compareDescending(int a, int b) {
  final compared = b.compareTo(a);
  return compared == 0 ? null : compared;
}

String chartExplorerStatValue({
  required int visible,
  required int total,
  required bool filtered,
}) {
  return filtered ? '$visible/$total' : '$visible';
}

String chartSampleResultLabel({
  required int visibleCount,
  required int totalCount,
}) {
  final totalLabel = totalCount == 1 ? 'sample' : 'samples';
  return 'Showing $visibleCount of $totalCount $totalLabel';
}

String chartFamilyResultLabel({
  required int visibleCount,
  required int totalCount,
  required bool filtered,
}) {
  final visibleLabel = visibleCount == 1 ? 'family' : 'families';
  if (!filtered) {
    return 'Showing $visibleCount $visibleLabel';
  }
  final totalLabel = totalCount == 1 ? 'family' : 'families';
  return 'Showing $visibleCount of $totalCount $totalLabel';
}
