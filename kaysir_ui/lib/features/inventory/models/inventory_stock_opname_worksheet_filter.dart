import 'inventory_stock_opname_session.dart';

/// Filter modes available for stock opname worksheet review.
enum InventoryStockOpnameWorksheetFilter {
  all,
  edited,
  invalid,
  variance,
  matched,
}

/// Sort modes available for stock opname worksheet review.
enum InventoryStockOpnameWorksheetSort {
  sheetOrder,
  productName,
  varianceMagnitude,
  editedFirst,
  invalidFirst,
}

/// Search and filter state for a stock opname worksheet.
class InventoryStockOpnameWorksheetFilterState {
  const InventoryStockOpnameWorksheetFilterState({
    this.query = '',
    this.filter = InventoryStockOpnameWorksheetFilter.all,
    this.sort = InventoryStockOpnameWorksheetSort.sheetOrder,
  });

  static const initial = InventoryStockOpnameWorksheetFilterState();

  final String query;
  final InventoryStockOpnameWorksheetFilter filter;
  final InventoryStockOpnameWorksheetSort sort;

  bool get hasQuery => query.trim().isNotEmpty;

  bool get hasActiveFilters =>
      hasQuery ||
      filter != InventoryStockOpnameWorksheetFilter.all ||
      sort != InventoryStockOpnameWorksheetSort.sheetOrder;

  InventoryStockOpnameWorksheetFilterState copyWith({
    String? query,
    InventoryStockOpnameWorksheetFilter? filter,
    InventoryStockOpnameWorksheetSort? sort,
  }) {
    return InventoryStockOpnameWorksheetFilterState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
}

/// Counts used by the stock opname worksheet review toolbar.
class InventoryStockOpnameWorksheetFilterCounts {
  const InventoryStockOpnameWorksheetFilterCounts({
    required this.total,
    required this.edited,
    required this.invalid,
    required this.variance,
    required this.matched,
    required this.filtered,
  });

  final int total;
  final int edited;
  final int invalid;
  final int variance;
  final int matched;
  final int filtered;
}

/// Applies the worksheet review query and filter mode to stock opname lines.
List<InventoryStockOpnameLine> filterInventoryStockOpnameWorksheetLines({
  required List<InventoryStockOpnameLine> lines,
  required Set<String> editedLineIds,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameWorksheetFilterState state,
}) {
  final filteredLines = [
    for (final line in lines)
      if (_matchesWorksheetFilter(
            line: line,
            editedLineIds: editedLineIds,
            invalidLineIds: invalidLineIds,
            filter: state.filter,
          ) &&
          _matchesWorksheetQuery(line, state.query))
        line,
  ];

  return sortInventoryStockOpnameWorksheetLines(
    lines: filteredLines,
    editedLineIds: editedLineIds,
    invalidLineIds: invalidLineIds,
    sort: state.sort,
  );
}

/// Sorts stock opname worksheet rows for review without mutating row content.
List<InventoryStockOpnameLine> sortInventoryStockOpnameWorksheetLines({
  required List<InventoryStockOpnameLine> lines,
  required Set<String> editedLineIds,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameWorksheetSort sort,
}) {
  if (sort == InventoryStockOpnameWorksheetSort.sheetOrder) {
    return List.unmodifiable(lines);
  }

  final indexedLines = [
    for (var index = 0; index < lines.length; index += 1)
      _IndexedWorksheetLine(index: index, line: lines[index]),
  ]..sort((left, right) {
    final result = _compareWorksheetLines(
      left: left.line,
      right: right.line,
      editedLineIds: editedLineIds,
      invalidLineIds: invalidLineIds,
      sort: sort,
    );
    if (result != 0) return result;

    return left.index.compareTo(right.index);
  });

  return List.unmodifiable([
    for (final indexedLine in indexedLines) indexedLine.line,
  ]);
}

/// User-facing label for a stock opname worksheet sort option.
String inventoryStockOpnameWorksheetSortLabel(
  InventoryStockOpnameWorksheetSort sort,
) {
  switch (sort) {
    case InventoryStockOpnameWorksheetSort.sheetOrder:
      return 'Sheet order';
    case InventoryStockOpnameWorksheetSort.productName:
      return 'Product A-Z';
    case InventoryStockOpnameWorksheetSort.varianceMagnitude:
      return 'Largest variance';
    case InventoryStockOpnameWorksheetSort.editedFirst:
      return 'Edited first';
    case InventoryStockOpnameWorksheetSort.invalidFirst:
      return 'Invalid first';
  }
}

/// Builds toolbar counts for all rows and currently visible worksheet rows.
InventoryStockOpnameWorksheetFilterCounts
summarizeInventoryStockOpnameWorksheetFilters({
  required List<InventoryStockOpnameLine> lines,
  required Set<String> editedLineIds,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameWorksheetFilterState state,
}) {
  var edited = 0;
  var invalid = 0;
  var variance = 0;
  var matched = 0;

  for (final line in lines) {
    if (editedLineIds.contains(line.id)) edited += 1;
    if (invalidLineIds.contains(line.id)) invalid += 1;
    if (line.hasVariance) {
      variance += 1;
    } else {
      matched += 1;
    }
  }

  final filtered =
      filterInventoryStockOpnameWorksheetLines(
        lines: lines,
        editedLineIds: editedLineIds,
        invalidLineIds: invalidLineIds,
        state: state,
      ).length;

  return InventoryStockOpnameWorksheetFilterCounts(
    total: lines.length,
    edited: edited,
    invalid: invalid,
    variance: variance,
    matched: matched,
    filtered: filtered,
  );
}

bool _matchesWorksheetFilter({
  required InventoryStockOpnameLine line,
  required Set<String> editedLineIds,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameWorksheetFilter filter,
}) {
  switch (filter) {
    case InventoryStockOpnameWorksheetFilter.all:
      return true;
    case InventoryStockOpnameWorksheetFilter.edited:
      return editedLineIds.contains(line.id);
    case InventoryStockOpnameWorksheetFilter.invalid:
      return invalidLineIds.contains(line.id);
    case InventoryStockOpnameWorksheetFilter.variance:
      return line.hasVariance;
    case InventoryStockOpnameWorksheetFilter.matched:
      return !line.hasVariance;
  }
}

bool _matchesWorksheetQuery(InventoryStockOpnameLine line, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  return [
    line.productName,
    line.skuLabel,
    line.notes,
    line.systemQuantity.toString(),
    line.actualQuantity.toString(),
  ].any((candidate) => candidate.toLowerCase().contains(normalizedQuery));
}

int _compareWorksheetLines({
  required InventoryStockOpnameLine left,
  required InventoryStockOpnameLine right,
  required Set<String> editedLineIds,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameWorksheetSort sort,
}) {
  switch (sort) {
    case InventoryStockOpnameWorksheetSort.sheetOrder:
      return 0;
    case InventoryStockOpnameWorksheetSort.productName:
      return _compareProductIdentity(left, right);
    case InventoryStockOpnameWorksheetSort.varianceMagnitude:
      return _compareDescendingInt(
        left.discrepancy.abs(),
        right.discrepancy.abs(),
      );
    case InventoryStockOpnameWorksheetSort.editedFirst:
      return _compareFlagFirst(
        editedLineIds.contains(left.id),
        editedLineIds.contains(right.id),
      );
    case InventoryStockOpnameWorksheetSort.invalidFirst:
      return _compareFlagFirst(
        invalidLineIds.contains(left.id),
        invalidLineIds.contains(right.id),
      );
  }
}

int _compareProductIdentity(
  InventoryStockOpnameLine left,
  InventoryStockOpnameLine right,
) {
  final productCompare = left.productName.toLowerCase().compareTo(
    right.productName.toLowerCase(),
  );
  if (productCompare != 0) return productCompare;

  final skuCompare = left.skuLabel.toLowerCase().compareTo(
    right.skuLabel.toLowerCase(),
  );
  if (skuCompare != 0) return skuCompare;

  return left.id.compareTo(right.id);
}

int _compareDescendingInt(int left, int right) {
  return right.compareTo(left);
}

int _compareFlagFirst(bool left, bool right) {
  if (left == right) return 0;

  return left ? -1 : 1;
}

class _IndexedWorksheetLine {
  const _IndexedWorksheetLine({required this.index, required this.line});

  final int index;
  final InventoryStockOpnameLine line;
}
