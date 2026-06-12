import 'inventory_stock_opname_count_sheet_snapshot.dart';
import 'inventory_stock_opname_session.dart';
import 'inventory_stock_opname_worksheet_filter.dart';

/// Worksheet target used when guiding users to the first draft issue.
class InventoryStockOpnameDraftReviewTarget {
  const InventoryStockOpnameDraftReviewTarget({
    required this.lineId,
    required this.filter,
  });

  final String lineId;
  final InventoryStockOpnameWorksheetFilter filter;
}

/// Resolves the first line and filter to show when reviewing draft issues.
InventoryStockOpnameDraftReviewTarget?
resolveInventoryStockOpnameDraftReviewTarget({
  required Iterable<InventoryStockOpnameLine> lines,
  required Set<String> invalidLineIds,
  required InventoryStockOpnameCountSheetSnapshot snapshot,
}) {
  for (final line in lines) {
    if (invalidLineIds.contains(line.id)) {
      return InventoryStockOpnameDraftReviewTarget(
        lineId: line.id,
        filter: InventoryStockOpnameWorksheetFilter.invalid,
      );
    }
  }

  final firstChangedLineId = snapshot.firstChangedLineId(lines);
  if (firstChangedLineId == null) return null;

  return InventoryStockOpnameDraftReviewTarget(
    lineId: firstChangedLineId,
    filter: InventoryStockOpnameWorksheetFilter.edited,
  );
}
