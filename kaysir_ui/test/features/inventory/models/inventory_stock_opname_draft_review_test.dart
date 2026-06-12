import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_count_sheet_snapshot.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_draft_review.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';

void main() {
  test('draft review target prioritizes invalid lines', () {
    final snapshot = InventoryStockOpnameCountSheetSnapshot.fromLines([
      _line(id: 'i1', actualQuantity: 5),
      _line(id: 'i2', actualQuantity: 5),
    ]);

    final target = resolveInventoryStockOpnameDraftReviewTarget(
      lines: [_line(id: 'i1', actualQuantity: 7), _line(id: 'i2')],
      invalidLineIds: {'i2'},
      snapshot: snapshot,
    );

    expect(target?.lineId, 'i2');
    expect(target?.filter, InventoryStockOpnameWorksheetFilter.invalid);
  });

  test('draft review target falls back to first edited line', () {
    final snapshot = InventoryStockOpnameCountSheetSnapshot.fromLines([
      _line(id: 'i1', actualQuantity: 5),
      _line(id: 'i2', actualQuantity: 5),
    ]);

    final target = resolveInventoryStockOpnameDraftReviewTarget(
      lines: [_line(id: 'i1'), _line(id: 'i2', actualQuantity: 8)],
      invalidLineIds: const {},
      snapshot: snapshot,
    );

    expect(target?.lineId, 'i2');
    expect(target?.filter, InventoryStockOpnameWorksheetFilter.edited);
  });

  test('draft review target is null when sheet is clean', () {
    final lines = [_line(id: 'i1'), _line(id: 'i2')];
    final snapshot = InventoryStockOpnameCountSheetSnapshot.fromLines(lines);

    expect(
      resolveInventoryStockOpnameDraftReviewTarget(
        lines: lines,
        invalidLineIds: const {},
        snapshot: snapshot,
      ),
      isNull,
    );
  });
}

InventoryStockOpnameLine _line({String id = 'i1', int actualQuantity = 5}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: 5,
    actualQuantity: actualQuantity,
  );
}
