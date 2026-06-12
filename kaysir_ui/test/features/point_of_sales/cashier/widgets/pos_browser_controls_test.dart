import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_browser_filter_search_state.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_controls.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_segmented_filter_bar.dart';

void main() {
  test('search summary factory wires generic recovery callbacks', () {
    var cleared = false;
    _FilterValue? recoveredFilter;
    const state = POSBrowserFilterSearchState<_FilterValue>(
      filter: _FilterValue.archived,
      allFilter: _FilterValue.all,
      query: 'latte',
      entryCount: 0,
      currentFilterEntryCount: 2,
      filters: _FilterValue.values,
      filterCounts: {
        _FilterValue.all: 1,
        _FilterValue.stocked: 1,
        _FilterValue.archived: 0,
      },
      filterLabel: _filterLabel,
      singularNoun: 'product',
      pluralNoun: 'products',
    );

    final summary = POSBrowserSearchSummary.fromFilterSearchState(
      state: state,
      onClear: () => cleared = true,
      onRecoverFilter: (filter) => recoveredFilter = filter,
    );

    expect(summary.title, 'No matching products');
    expect(summary.recoveryActionLabel, 'Show Stocked');

    summary.onClear();
    summary.onRecover?.call();

    expect(cleared, isTrue);
    expect(recoveredFilter, _FilterValue.stocked);
  });

  testWidgets('browser controls compose filters, search, and summary actions', (
    tester,
  ) async {
    final controller = TextEditingController();
    final selectedFilters = <_FilterValue>[];
    final searchChanges = <String>[];
    var cleared = false;
    var recovered = false;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSBrowserControls<_FilterValue>(
            searchController: controller,
            searchHintText: 'Search products',
            onSearchChanged: searchChanges.add,
            selectedFilter: _FilterValue.all,
            filterOptions: const [
              POSSegmentedFilterOption(
                value: _FilterValue.all,
                label: 'All',
                count: 6,
                icon: Icons.list_alt_outlined,
              ),
              POSSegmentedFilterOption(
                value: _FilterValue.stocked,
                label: 'Stocked',
                count: 4,
                icon: Icons.inventory_2_outlined,
              ),
            ],
            onFilterSelected: selectedFilters.add,
            searchSummary: POSBrowserSearchSummary(
              title: '1 matching product',
              message: 'Searching "latte" in All.',
              clearActionLabel: 'Clear',
              clearActionKey: const ValueKey('clear-search'),
              recoveryActionLabel: 'Show stocked',
              recoveryActionKey: const ValueKey('recover-search'),
              onClear: () => cleared = true,
              onRecover: () => recovered = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('All (6)'), findsOneWidget);
    expect(find.text('Stocked (4)'), findsOneWidget);
    expect(find.text('Search products'), findsOneWidget);
    expect(find.text('1 matching product'), findsOneWidget);

    await tester.tap(find.text('Stocked (4)'));
    await tester.enterText(find.byType(TextField), 'latte');
    await tester.tap(find.byKey(const ValueKey('clear-search')));
    await tester.tap(find.byKey(const ValueKey('recover-search')));

    expect(selectedFilters, [_FilterValue.stocked]);
    expect(searchChanges, ['latte']);
    expect(cleared, isTrue);
    expect(recovered, isTrue);
  });

  testWidgets('browser controls support search-only surfaces', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSBrowserControls<_FilterValue>(
            searchController: controller,
            searchHintText: 'Search customers',
            onSearchChanged: (_) {},
            selectedFilter: _FilterValue.all,
            filterOptions: const [],
            onFilterSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Search customers'), findsOneWidget);
    expect(find.byType(SegmentedButton<_FilterValue>), findsNothing);
    expect(find.text('Clear'), findsNothing);
  });
}

enum _FilterValue { all, stocked, archived }

String _filterLabel(_FilterValue value) {
  switch (value) {
    case _FilterValue.all:
      return 'All';
    case _FilterValue.stocked:
      return 'Stocked';
    case _FilterValue.archived:
      return 'Archived';
  }
}
