import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_count_sheet_snapshot.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';

void main() {
  test('stock opname line snapshot trims notes before comparison', () {
    final snapshot = InventoryStockOpnameLineSnapshot.fromLine(
      _line(notes: ' Shelf recount '),
    );

    expect(snapshot.matches(_line(notes: 'Shelf recount')), isTrue);
    expect(snapshot.matches(_line(actualQuantity: 7)), isFalse);
  });

  test('count sheet snapshot reports edited and removed rows', () {
    final snapshot = InventoryStockOpnameCountSheetSnapshot.fromLines([
      _line(id: 'i1', actualQuantity: 5),
      _line(id: 'i2', actualQuantity: 8),
      _line(id: 'i3', actualQuantity: 3),
    ]);

    final currentLines = [
      _line(id: 'i1', actualQuantity: 7),
      _line(id: 'i2', actualQuantity: 8),
    ];

    expect(snapshot.changedLineIds(currentLines), {'i1'});
    expect(snapshot.changedLineCount(currentLines), 2);
    expect(snapshot.firstChangedLineId(currentLines), 'i1');
  });

  test('count sheet snapshot treats new rows as changed', () {
    final snapshot = InventoryStockOpnameCountSheetSnapshot.fromLines([
      _line(id: 'i1'),
    ]);

    final currentLines = [_line(id: 'i1'), _line(id: 'i2')];

    expect(snapshot.changedLineIds(currentLines), {'i2'});
    expect(snapshot.changedLineCount(currentLines), 1);
    expect(snapshot.firstChangedLineId(currentLines), 'i2');
  });
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int actualQuantity = 5,
  String notes = '',
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: 5,
    actualQuantity: actualQuantity,
    notes: notes,
  );
}
