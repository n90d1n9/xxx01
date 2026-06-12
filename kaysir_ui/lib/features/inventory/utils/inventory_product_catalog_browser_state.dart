import '../../point_of_sales/cashier/utils/pos_browser_filter_search_state.dart';
import '../models/inventory_product_catalog.dart';

class InventoryProductCatalogBrowserState {
  final InventoryProductCatalogFilter filter;
  final String query;
  final List<InventoryProductCatalogRecord> records;
  final List<InventoryProductCatalogRecord> entries;
  final Map<InventoryProductCatalogFilter, int> filterCounts;
  final POSBrowserFilterSearchState<InventoryProductCatalogFilter> searchState;

  const InventoryProductCatalogBrowserState._({
    required this.filter,
    required this.query,
    required this.records,
    required this.entries,
    required this.filterCounts,
    required this.searchState,
  });

  factory InventoryProductCatalogBrowserState.resolve({
    required List<InventoryProductCatalogRecord> records,
    required InventoryProductCatalogFilter filter,
    String query = '',
  }) {
    final normalizedQuery = query.trim();
    final entries = filterInventoryProductCatalogRecords(
      records: records,
      query: normalizedQuery,
      filter: filter,
    );
    final filterCounts = {
      for (final nextFilter in InventoryProductCatalogFilter.values)
        nextFilter:
            filterInventoryProductCatalogRecords(
              records: records,
              query: normalizedQuery,
              filter: nextFilter,
            ).length,
    };
    final searchState =
        POSBrowserFilterSearchState<InventoryProductCatalogFilter>(
          filter: filter,
          allFilter: InventoryProductCatalogFilter.all,
          query: normalizedQuery,
          entryCount: entries.length,
          currentFilterEntryCount:
              filterInventoryProductCatalogRecords(
                records: records,
                query: '',
                filter: filter,
              ).length,
          filters: InventoryProductCatalogFilter.values,
          filterCounts: filterCounts,
          filterLabel: inventoryProductCatalogFilterLabel,
          singularNoun: 'product',
          pluralNoun: 'products',
        );

    return InventoryProductCatalogBrowserState._(
      filter: filter,
      query: normalizedQuery,
      records: List.unmodifiable(records),
      entries: entries,
      filterCounts: Map.unmodifiable(filterCounts),
      searchState: searchState,
    );
  }

  bool get hasQuery => searchState.hasQuery;

  bool get shouldShowSearchSummary => searchState.shouldShowSearchSummary;

  int countFor(InventoryProductCatalogFilter filter) {
    return filterCounts[filter] ?? 0;
  }

  int get currentFilterEntryCount => searchState.currentFilterEntryCount;

  String get searchSummaryTitle => searchState.searchSummaryTitle;

  String get searchSummaryMessage => searchState.searchSummaryMessage;

  String get searchSummaryActionLabel => searchState.searchSummaryActionLabel;

  InventoryProductCatalogFilter? get searchRecoveryFilter {
    return searchState.searchRecoveryFilter;
  }

  bool get hasSearchRecoveryAction => searchState.hasSearchRecoveryAction;

  String get searchRecoveryActionLabel => searchState.searchRecoveryActionLabel;
}
