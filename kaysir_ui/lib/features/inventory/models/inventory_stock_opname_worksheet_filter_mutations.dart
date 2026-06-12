import 'inventory_stock_opname_draft_review.dart';
import 'inventory_stock_opname_worksheet_filter.dart';

/// Result of a stock opname worksheet filter state transition.
class InventoryStockOpnameWorksheetFilterMutationResult {
  const InventoryStockOpnameWorksheetFilterMutationResult({
    required this.state,
    required this.didChange,
    this.shouldClearSearch = false,
  });

  final InventoryStockOpnameWorksheetFilterState state;
  final bool didChange;
  final bool shouldClearSearch;
}

/// Applies a worksheet search query change.
InventoryStockOpnameWorksheetFilterMutationResult
updateInventoryStockOpnameWorksheetSearchQuery({
  required InventoryStockOpnameWorksheetFilterState state,
  required String query,
}) {
  final nextState = state.copyWith(query: query);
  return InventoryStockOpnameWorksheetFilterMutationResult(
    state: nextState,
    didChange: nextState.query != state.query,
  );
}

/// Applies a worksheet row-state filter change.
InventoryStockOpnameWorksheetFilterMutationResult
updateInventoryStockOpnameWorksheetFilter({
  required InventoryStockOpnameWorksheetFilterState state,
  required InventoryStockOpnameWorksheetFilter filter,
}) {
  final nextState = state.copyWith(filter: filter);
  return InventoryStockOpnameWorksheetFilterMutationResult(
    state: nextState,
    didChange: nextState.filter != state.filter,
  );
}

/// Applies a worksheet sort change.
InventoryStockOpnameWorksheetFilterMutationResult
updateInventoryStockOpnameWorksheetSort({
  required InventoryStockOpnameWorksheetFilterState state,
  required InventoryStockOpnameWorksheetSort sort,
}) {
  final nextState = state.copyWith(sort: sort);
  return InventoryStockOpnameWorksheetFilterMutationResult(
    state: nextState,
    didChange: nextState.sort != state.sort,
  );
}

/// Resets worksheet filters and reports whether the search controller must clear.
InventoryStockOpnameWorksheetFilterMutationResult
resetInventoryStockOpnameWorksheetFilters({
  required InventoryStockOpnameWorksheetFilterState state,
  required String searchText,
}) {
  return InventoryStockOpnameWorksheetFilterMutationResult(
    state: InventoryStockOpnameWorksheetFilterState.initial,
    didChange: state.hasActiveFilters,
    shouldClearSearch: searchText.isNotEmpty,
  );
}

/// Moves the worksheet state to the filter needed for reviewing a draft issue.
InventoryStockOpnameWorksheetFilterMutationResult
revealInventoryStockOpnameDraftReviewTarget({
  required InventoryStockOpnameWorksheetFilterState state,
  required InventoryStockOpnameDraftReviewTarget target,
}) {
  final filterChanged = state.filter != target.filter;
  final queryChanged = state.query.isNotEmpty;
  if (!filterChanged && !queryChanged) {
    return InventoryStockOpnameWorksheetFilterMutationResult(
      state: state,
      didChange: false,
    );
  }

  return InventoryStockOpnameWorksheetFilterMutationResult(
    state: state.copyWith(query: '', filter: target.filter),
    didChange: true,
    shouldClearSearch: queryChanged,
  );
}
