import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_count_sheet_mutations.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';

void main() {
  test('parses valid non-negative actual quantities', () {
    expect(parseInventoryStockOpnameActualQuantity(' 12 '), 12);
    expect(parseInventoryStockOpnameActualQuantity('0'), 0);
    expect(parseInventoryStockOpnameActualQuantity('-1'), isNull);
    expect(parseInventoryStockOpnameActualQuantity('bad'), isNull);
  });

  test('updates one count sheet line without mutating source lines', () {
    final sourceLines = [_line(id: 'i1'), _line(id: 'i2')];

    final result = updateInventoryStockOpnameCountLine(
      lines: sourceLines,
      lineId: 'i1',
      update: (line) => line.copyWith(actualQuantity: 8),
    );

    expect(result.lineFound, isTrue);
    expect(result.lines.first.actualQuantity, 8);
    expect(sourceLines.first.actualQuantity, 5);
  });

  test('reports missing line updates without changing lines', () {
    final sourceLines = [_line(id: 'i1')];

    final result = updateInventoryStockOpnameCountLine(
      lines: sourceLines,
      lineId: 'missing',
      update: (line) => line.copyWith(actualQuantity: 8),
    );

    expect(result.lineFound, isFalse);
    expect(result.lines.single.actualQuantity, 5);
  });

  test('matches visible count sheet lines to system quantities', () {
    final result = matchInventoryStockOpnameSystemCounts(
      lines: [
        _line(id: 'i1', systemQuantity: 5, actualQuantity: 8),
        _line(id: 'i2', systemQuantity: 3, actualQuantity: 9),
        _line(id: 'i3', systemQuantity: 7, actualQuantity: 7),
      ],
      lineIds: ['i1', 'i3', 'missing'],
    );

    expect(result.targetLineIds, {'i1', 'i3'});
    expect(result.didChange, isTrue);
    expect(result.lines.map((line) => line.actualQuantity), [5, 9, 7]);
  });

  test(
    'does not flag batch match as changed when visible lines already match',
    () {
      final result = matchInventoryStockOpnameSystemCounts(
        lines: [_line(id: 'i1')],
        lineIds: ['i1'],
      );

      expect(result.targetLineIds, {'i1'});
      expect(result.didChange, isFalse);
    },
  );
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 5,
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
  );
}
