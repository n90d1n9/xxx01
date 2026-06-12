class POSBrowserFilterSearchState<T extends Object> {
  final T filter;
  final T allFilter;
  final String query;
  final int entryCount;
  final int currentFilterEntryCount;
  final List<T> filters;
  final Map<T, int> filterCounts;
  final String Function(T filter) filterLabel;
  final String singularNoun;
  final String pluralNoun;

  const POSBrowserFilterSearchState({
    required this.filter,
    required this.allFilter,
    required this.query,
    required this.entryCount,
    required this.currentFilterEntryCount,
    required this.filters,
    required this.filterCounts,
    required this.filterLabel,
    required this.singularNoun,
    required this.pluralNoun,
  });

  bool get hasQuery => query.trim().isNotEmpty;

  bool get shouldShowSearchSummary => hasQuery;

  int countFor(T filter) {
    return filterCounts[filter] ?? 0;
  }

  String get searchSummaryTitle {
    if (entryCount == 0) return 'No matching $pluralNoun';

    return '$entryCount matching ${_noun(entryCount)}';
  }

  String get searchSummaryMessage {
    final currentLabel = filterLabel(filter);
    final recoveryFilter = searchRecoveryFilter;
    if (recoveryFilter != null) {
      final recoveryLabel = filterLabel(recoveryFilter);
      final matchCount = countFor(recoveryFilter);
      return 'No results in $currentLabel. $matchCount matching ${_noun(matchCount)} available in $recoveryLabel.';
    }

    return 'Searching "${query.trim()}" in $currentLabel. Clear search to return to $currentFilterEntryCount ${_noun(currentFilterEntryCount)}.';
  }

  String get searchSummaryActionLabel => 'Clear';

  T? get searchRecoveryFilter {
    if (!hasQuery || entryCount > 0) return null;

    final specificMatches = filters
        .where(
          (nextFilter) =>
              nextFilter != filter &&
              nextFilter != allFilter &&
              countFor(nextFilter) > 0,
        )
        .toList(growable: false);
    if (specificMatches.length == 1) return specificMatches.single;
    if (specificMatches.length > 1) return allFilter;

    final allMatchCount = countFor(allFilter);
    if (filter != allFilter && allMatchCount > 0) return allFilter;
    return null;
  }

  bool get hasSearchRecoveryAction => searchRecoveryFilter != null;

  String get searchRecoveryActionLabel {
    final recoveryFilter = searchRecoveryFilter;
    if (recoveryFilter == null) return 'Show matches';
    if (recoveryFilter == allFilter) return 'Show all matches';
    return 'Show ${filterLabel(recoveryFilter)}';
  }

  String _noun(int count) => count == 1 ? singularNoun : pluralNoun;
}
