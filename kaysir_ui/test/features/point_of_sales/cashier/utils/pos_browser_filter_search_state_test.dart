import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_browser_filter_search_state.dart';

void main() {
  test('builds search summary copy from generic counts and labels', () {
    const state = POSBrowserFilterSearchState<_Filter>(
      filter: _Filter.all,
      allFilter: _Filter.all,
      query: ' latte ',
      entryCount: 1,
      currentFilterEntryCount: 3,
      filters: _Filter.values,
      filterCounts: {_Filter.all: 1, _Filter.ready: 1, _Filter.blocked: 0},
      filterLabel: _label,
      singularNoun: 'item',
      pluralNoun: 'items',
    );

    expect(state.hasQuery, isTrue);
    expect(state.searchSummaryTitle, '1 matching item');
    expect(
      state.searchSummaryMessage,
      'Searching "latte" in All. Clear search to return to 3 items.',
    );
    expect(state.searchSummaryActionLabel, 'Clear');
  });

  test('recovers to the only matching non-all filter', () {
    const state = POSBrowserFilterSearchState<_Filter>(
      filter: _Filter.blocked,
      allFilter: _Filter.all,
      query: 'latte',
      entryCount: 0,
      currentFilterEntryCount: 2,
      filters: _Filter.values,
      filterCounts: {_Filter.all: 1, _Filter.ready: 1, _Filter.blocked: 0},
      filterLabel: _label,
      singularNoun: 'product',
      pluralNoun: 'products',
    );

    expect(state.searchRecoveryFilter, _Filter.ready);
    expect(state.hasSearchRecoveryAction, isTrue);
    expect(state.searchRecoveryActionLabel, 'Show Ready');
    expect(
      state.searchSummaryMessage,
      'No results in Blocked. 1 matching product available in Ready.',
    );
  });

  test('recovers to all when multiple non-all filters match', () {
    const state = POSBrowserFilterSearchState<_Filter>(
      filter: _Filter.blocked,
      allFilter: _Filter.all,
      query: 'terminal',
      entryCount: 0,
      currentFilterEntryCount: 2,
      filters: _Filter.values,
      filterCounts: {
        _Filter.all: 2,
        _Filter.ready: 1,
        _Filter.review: 1,
        _Filter.blocked: 0,
      },
      filterLabel: _label,
      singularNoun: 'save',
      pluralNoun: 'saves',
    );

    expect(state.searchRecoveryFilter, _Filter.all);
    expect(state.searchRecoveryActionLabel, 'Show all matches');
    expect(
      state.searchSummaryMessage,
      'No results in Blocked. 2 matching saves available in All.',
    );
  });

  test('does not recover when there is no query or current entries exist', () {
    const noQuery = POSBrowserFilterSearchState<_Filter>(
      filter: _Filter.blocked,
      allFilter: _Filter.all,
      query: '',
      entryCount: 0,
      currentFilterEntryCount: 2,
      filters: _Filter.values,
      filterCounts: {_Filter.all: 1, _Filter.ready: 1},
      filterLabel: _label,
      singularNoun: 'item',
      pluralNoun: 'items',
    );
    const hasEntries = POSBrowserFilterSearchState<_Filter>(
      filter: _Filter.blocked,
      allFilter: _Filter.all,
      query: 'latte',
      entryCount: 1,
      currentFilterEntryCount: 2,
      filters: _Filter.values,
      filterCounts: {_Filter.all: 1, _Filter.blocked: 1},
      filterLabel: _label,
      singularNoun: 'item',
      pluralNoun: 'items',
    );

    expect(noQuery.searchRecoveryFilter, isNull);
    expect(noQuery.shouldShowSearchSummary, isFalse);
    expect(hasEntries.searchRecoveryFilter, isNull);
    expect(hasEntries.hasSearchRecoveryAction, isFalse);
  });
}

enum _Filter { all, ready, review, blocked }

String _label(_Filter filter) {
  switch (filter) {
    case _Filter.all:
      return 'All';
    case _Filter.ready:
      return 'Ready';
    case _Filter.review:
      return 'Review';
    case _Filter.blocked:
      return 'Blocked';
  }
}
