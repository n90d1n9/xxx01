import '../../cashier/utils/pos_browser_filter_search_state.dart';
import 'order_save_outbox.dart';
import 'order_save_outbox_display.dart';
import 'order_save_outbox_summary.dart';

class POSOrderSaveOutboxBrowserState {
  final POSOrderSaveOutboxViewFilter filter;
  final String query;
  final List<POSOrderSaveOutboxEntry> sortedEntries;
  final List<POSOrderSaveOutboxEntry> entries;
  final List<POSOrderSaveOutboxEntry> retryableEntries;
  final int hiddenRetryableCount;
  final int matchingHiddenRetryableCount;
  final Map<POSOrderSaveOutboxViewFilter, int> filterCounts;
  final POSBrowserFilterSearchState<POSOrderSaveOutboxViewFilter> searchState;

  const POSOrderSaveOutboxBrowserState._({
    required this.filter,
    required this.query,
    required this.sortedEntries,
    required this.entries,
    required this.retryableEntries,
    required this.hiddenRetryableCount,
    required this.matchingHiddenRetryableCount,
    required this.filterCounts,
    required this.searchState,
  });

  factory POSOrderSaveOutboxBrowserState.resolve({
    required POSOrderSaveOutbox outbox,
    required POSOrderSaveOutboxViewFilter filter,
    String query = '',
  }) {
    final normalizedQuery = query.trim();
    final sortedEntries = sortPOSOrderSaveOutboxEntries(outbox.entries);
    final entries = filterPOSOrderSaveOutboxEntries(
      sortedEntries,
      filter,
      query: normalizedQuery,
    );
    final retryableEntries = entries
        .where((entry) => entry.canRetry)
        .toList(growable: false);
    final totalRetryableCount =
        sortedEntries.where((entry) => entry.canRetry).length;
    final queryMatchedRetryableCount =
        normalizedQuery.isEmpty
            ? totalRetryableCount
            : filterPOSOrderSaveOutboxEntries(
              sortedEntries,
              POSOrderSaveOutboxViewFilter.all,
              query: normalizedQuery,
            ).where((entry) => entry.canRetry).length;
    final matchingHiddenRetryableCount =
        queryMatchedRetryableCount > retryableEntries.length
            ? queryMatchedRetryableCount - retryableEntries.length
            : 0;
    final filterCounts = {
      for (final nextFilter in POSOrderSaveOutboxViewFilter.values)
        nextFilter:
            filterPOSOrderSaveOutboxEntries(
              sortedEntries,
              nextFilter,
              query: normalizedQuery,
            ).length,
    };
    final searchState =
        POSBrowserFilterSearchState<POSOrderSaveOutboxViewFilter>(
          filter: filter,
          allFilter: POSOrderSaveOutboxViewFilter.all,
          query: normalizedQuery,
          entryCount: entries.length,
          currentFilterEntryCount:
              filterPOSOrderSaveOutboxEntries(sortedEntries, filter).length,
          filters: POSOrderSaveOutboxViewFilter.values,
          filterCounts: filterCounts,
          filterLabel: posOrderSaveOutboxViewFilterLabel,
          singularNoun: 'save',
          pluralNoun: 'saves',
        );

    return POSOrderSaveOutboxBrowserState._(
      filter: filter,
      query: normalizedQuery,
      sortedEntries: sortedEntries,
      entries: entries,
      retryableEntries: retryableEntries,
      hiddenRetryableCount: totalRetryableCount - retryableEntries.length,
      matchingHiddenRetryableCount: matchingHiddenRetryableCount,
      filterCounts: Map.unmodifiable(filterCounts),
      searchState: searchState,
    );
  }

  bool get hasQuery => searchState.hasQuery;

  bool get shouldShowSearchSummary => searchState.shouldShowSearchSummary;

  int get currentFilterEntryCount => searchState.currentFilterEntryCount;

  String get searchSummaryTitle => searchState.searchSummaryTitle;

  String get searchSummaryMessage => searchState.searchSummaryMessage;

  String get searchSummaryActionLabel => searchState.searchSummaryActionLabel;

  POSOrderSaveOutboxViewFilter? get searchRecoveryFilter {
    return searchState.searchRecoveryFilter;
  }

  bool get hasSearchRecoveryAction => searchState.hasSearchRecoveryAction;

  String get searchRecoveryActionLabel => searchState.searchRecoveryActionLabel;

  bool get hasHiddenRetryableEntries => hiddenRetryableCount > 0;

  bool get hasMatchingHiddenRetryableEntries {
    return hasQuery && matchingHiddenRetryableCount > 0;
  }

  bool get shouldPreserveSearchForHiddenRetryableAction {
    return filter != POSOrderSaveOutboxViewFilter.attention &&
        hasMatchingHiddenRetryableEntries;
  }

  String get hiddenRetryableTitle {
    final count =
        hasMatchingHiddenRetryableEntries
            ? matchingHiddenRetryableCount
            : hiddenRetryableCount;
    final noun = count == 1 ? 'save' : 'saves';
    final qualifier = hasMatchingHiddenRetryableEntries ? ' matching' : '';
    return '$count$qualifier failed $noun hidden';
  }

  String get hiddenRetryableMessage {
    if (hasQuery && filter == POSOrderSaveOutboxViewFilter.attention) {
      return 'Clear or change the search to see all failed saves.';
    }
    if (hasMatchingHiddenRetryableEntries) {
      return 'Switch to Attention to see failed saves matching this search.';
    }
    if (hasQuery) {
      return 'Current search hides failed saves. Clear search or switch to Attention.';
    }
    return 'Switch to Attention to review failed saves before closing the register.';
  }

  String get hiddenRetryableActionLabel {
    if (filter == POSOrderSaveOutboxViewFilter.attention) {
      return 'Clear search';
    }
    return hasMatchingHiddenRetryableEntries
        ? 'Show matching failed'
        : 'Show failed';
  }

  int countFor(POSOrderSaveOutboxViewFilter filter) {
    return filterCounts[filter] ?? 0;
  }

  String labelFor(POSOrderSaveOutboxViewFilter filter) {
    return '${posOrderSaveOutboxViewFilterLabel(filter)} (${countFor(filter)})';
  }

  String get emptyTitle {
    if (hasQuery) return 'No matching order saves';

    switch (filter) {
      case POSOrderSaveOutboxViewFilter.attention:
        return 'No orders need attention';
      case POSOrderSaveOutboxViewFilter.queued:
        return 'No queued order saves';
      case POSOrderSaveOutboxViewFilter.syncing:
        return 'No orders are syncing';
      case POSOrderSaveOutboxViewFilter.synced:
        return 'No synced order saves';
      case POSOrderSaveOutboxViewFilter.all:
        return 'No order saves';
    }
  }

  String get emptyMessage {
    if (hasQuery) {
      return 'Try a different order, terminal, status, or error term.';
    }

    switch (filter) {
      case POSOrderSaveOutboxViewFilter.attention:
        return 'Failed order saves will appear here for retry.';
      case POSOrderSaveOutboxViewFilter.queued:
        return 'Completed orders waiting to sync will appear here.';
      case POSOrderSaveOutboxViewFilter.syncing:
        return 'In-flight order saves will appear here while syncing.';
      case POSOrderSaveOutboxViewFilter.synced:
        return 'Successfully synced saves can be reviewed before cleanup.';
      case POSOrderSaveOutboxViewFilter.all:
        return 'Completed orders will appear here when they enter the sync queue.';
    }
  }
}

POSOrderSaveOutboxViewFilter initialPOSOrderSaveOutboxBrowserFilter(
  POSOrderSaveOutboxSummary summary,
) {
  return summary.failedCount > 0
      ? POSOrderSaveOutboxViewFilter.attention
      : POSOrderSaveOutboxViewFilter.all;
}
