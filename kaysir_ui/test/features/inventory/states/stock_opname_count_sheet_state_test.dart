import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/states/stock_opname_count_sheet_state.dart';

void main() {
  test('stock opname count sheet state tracks edited and invalid drafts', () {
    final state = InventoryStockOpnameCountSheetState(lines: [_line()]);

    expect(state.hasUnsavedChanges, isFalse);
    expect(state.draftStatus.hasUnsavedChanges, isFalse);

    expect(state.updateActualQuantity(lineId: 'i1', value: '9'), isTrue);
    expect(state.lines.single.actualQuantity, 9);
    expect(state.changedLineIds, {'i1'});
    expect(state.draftStatus.changedLineCount, 1);
    expect(state.draftReviewTarget?.lineId, 'i1');

    expect(state.updateActualQuantity(lineId: 'i1', value: 'bad'), isTrue);
    expect(state.lines.single.actualQuantity, 9);
    expect(state.invalidActualQuantityLineIds, {'i1'});
    expect(state.draftStatus.invalidActualQuantityLineCount, 1);

    expect(state.markSaved(), isTrue);
    expect(state.hasUnsavedChanges, isFalse);
    expect(state.invalidActualQuantityLineIds, isEmpty);
    expect(state.draftReviewTarget, isNull);
  });

  test('stock opname count sheet state ignores missing line mutations', () {
    final state = InventoryStockOpnameCountSheetState(lines: [_line()]);

    expect(
      state.updateActualQuantity(lineId: 'missing', value: 'bad'),
      isFalse,
    );
    expect(state.updateNotes(lineId: 'missing', value: 'Recounted'), isFalse);
    expect(state.matchSystemCount('missing'), isFalse);
    expect(state.hasUnsavedChanges, isFalse);
  });

  test(
    'stock opname count sheet state matches visible lines and clears invalids',
    () {
      final state = InventoryStockOpnameCountSheetState(
        lines: [
          _line(id: 'i1', systemQuantity: 5, actualQuantity: 8),
          _line(id: 'i2', systemQuantity: 3, actualQuantity: 9),
        ],
      );

      expect(
        state.updateActualQuantity(lineId: 'i1', value: 'invalid'),
        isTrue,
      );

      final didMatch = state.matchSystemCounts(['i1']);

      expect(didMatch, isTrue);
      expect(state.lines.map((line) => line.actualQuantity), [5, 9]);
      expect(state.invalidActualQuantityLineIds, isEmpty);
      expect(state.draftStatus.changedLineCount, 1);
    },
  );

  test(
    'stock opname count sheet state replaces lines with a clean baseline',
    () {
      final state = InventoryStockOpnameCountSheetState(lines: [_line()]);

      state.updateNotes(lineId: 'i1', value: 'Shelf recount');
      state.replaceWithCleanLines([_line(id: 'i2', systemQuantity: 2)]);

      expect(state.lines.single.id, 'i2');
      expect(state.hasUnsavedChanges, isFalse);
      expect(state.changedLineIds, isEmpty);
    },
  );
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int? actualQuantity,
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity ?? systemQuantity,
  );
}
