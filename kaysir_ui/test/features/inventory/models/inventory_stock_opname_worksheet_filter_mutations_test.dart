import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_draft_review.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter_mutations.dart';

void main() {
  test('worksheet filter mutations report no-op changes', () {
    final result = updateInventoryStockOpnameWorksheetSearchQuery(
      state: const InventoryStockOpnameWorksheetFilterState(query: 'lap'),
      query: 'lap',
    );

    expect(result.didChange, isFalse);
    expect(result.state.query, 'lap');
  });

  test('worksheet filter mutations update query filter and sort', () {
    final queryResult = updateInventoryStockOpnameWorksheetSearchQuery(
      state: InventoryStockOpnameWorksheetFilterState.initial,
      query: 'cable',
    );
    final filterResult = updateInventoryStockOpnameWorksheetFilter(
      state: queryResult.state,
      filter: InventoryStockOpnameWorksheetFilter.variance,
    );
    final sortResult = updateInventoryStockOpnameWorksheetSort(
      state: filterResult.state,
      sort: InventoryStockOpnameWorksheetSort.varianceMagnitude,
    );

    expect(queryResult.didChange, isTrue);
    expect(filterResult.didChange, isTrue);
    expect(sortResult.didChange, isTrue);
    expect(sortResult.state.query, 'cable');
    expect(
      sortResult.state.filter,
      InventoryStockOpnameWorksheetFilter.variance,
    );
    expect(
      sortResult.state.sort,
      InventoryStockOpnameWorksheetSort.varianceMagnitude,
    );
  });

  test('worksheet filter reset reports clear-search intent', () {
    final result = resetInventoryStockOpnameWorksheetFilters(
      state: const InventoryStockOpnameWorksheetFilterState(
        filter: InventoryStockOpnameWorksheetFilter.edited,
      ),
      searchText: 'lap',
    );

    expect(result.didChange, isTrue);
    expect(result.shouldClearSearch, isTrue);
    expect(result.state, InventoryStockOpnameWorksheetFilterState.initial);
  });

  test('draft review reveal clears query and switches filter', () {
    final result = revealInventoryStockOpnameDraftReviewTarget(
      state: const InventoryStockOpnameWorksheetFilterState(query: 'cable'),
      target: const InventoryStockOpnameDraftReviewTarget(
        lineId: 'i1',
        filter: InventoryStockOpnameWorksheetFilter.invalid,
      ),
    );

    expect(result.didChange, isTrue);
    expect(result.shouldClearSearch, isTrue);
    expect(result.state.query, isEmpty);
    expect(result.state.filter, InventoryStockOpnameWorksheetFilter.invalid);
  });

  test(
    'draft review reveal is a no-op when filter and query already match',
    () {
      final result = revealInventoryStockOpnameDraftReviewTarget(
        state: const InventoryStockOpnameWorksheetFilterState(
          filter: InventoryStockOpnameWorksheetFilter.edited,
        ),
        target: const InventoryStockOpnameDraftReviewTarget(
          lineId: 'i1',
          filter: InventoryStockOpnameWorksheetFilter.edited,
        ),
      );

      expect(result.didChange, isFalse);
      expect(result.shouldClearSearch, isFalse);
    },
  );
}
