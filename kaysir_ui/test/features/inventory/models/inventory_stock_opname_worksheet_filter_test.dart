import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';

void main() {
  test('stock opname worksheet filter counts row states', () {
    final counts = summarizeInventoryStockOpnameWorksheetFilters(
      lines: [
        _line(id: 'i1', actualQuantity: 7),
        _line(id: 'i2'),
        _line(id: 'i3', actualQuantity: 0),
      ],
      editedLineIds: {'i1'},
      invalidLineIds: {'i3'},
      state: InventoryStockOpnameWorksheetFilterState.initial,
    );

    expect(counts.total, 3);
    expect(counts.edited, 1);
    expect(counts.invalid, 1);
    expect(counts.variance, 2);
    expect(counts.matched, 1);
    expect(counts.filtered, 3);
  });

  test('stock opname worksheet filter applies modes and query', () {
    final lines = [
      _line(id: 'i1', productName: 'Laptop', skuLabel: 'LT-001'),
      _line(id: 'i2', productName: 'Cable', skuLabel: 'CB-001'),
      _line(
        id: 'i3',
        productName: 'Mouse',
        skuLabel: 'MS-001',
        actualQuantity: 4,
        notes: 'Shelf recount',
      ),
    ];

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: {'i1', 'i3'},
          invalidLineIds: {'i2'},
          state: const InventoryStockOpnameWorksheetFilterState(
            filter: InventoryStockOpnameWorksheetFilter.edited,
          ),
        ),
      ),
      ['i1', 'i3'],
    );

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: {'i1', 'i3'},
          invalidLineIds: {'i2'},
          state: const InventoryStockOpnameWorksheetFilterState(
            query: 'shelf',
            filter: InventoryStockOpnameWorksheetFilter.variance,
          ),
        ),
      ),
      ['i3'],
    );

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: {'i1', 'i3'},
          invalidLineIds: {'i2'},
          state: const InventoryStockOpnameWorksheetFilterState(
            filter: InventoryStockOpnameWorksheetFilter.invalid,
          ),
        ),
      ),
      ['i2'],
    );
  });

  test('stock opname worksheet filter sorts review rows', () {
    final lines = [
      _line(id: 'i1', productName: 'Laptop', actualQuantity: 5),
      _line(id: 'i2', productName: 'Cable', actualQuantity: 2),
      _line(id: 'i3', productName: 'Mouse', actualQuantity: 11),
    ];

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: const {},
          invalidLineIds: const {},
          state: const InventoryStockOpnameWorksheetFilterState(
            sort: InventoryStockOpnameWorksheetSort.productName,
          ),
        ),
      ),
      ['i2', 'i1', 'i3'],
    );

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: const {},
          invalidLineIds: const {},
          state: const InventoryStockOpnameWorksheetFilterState(
            sort: InventoryStockOpnameWorksheetSort.varianceMagnitude,
          ),
        ),
      ),
      ['i3', 'i2', 'i1'],
    );

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: {'i2'},
          invalidLineIds: {'i3'},
          state: const InventoryStockOpnameWorksheetFilterState(
            sort: InventoryStockOpnameWorksheetSort.invalidFirst,
          ),
        ),
      ),
      ['i3', 'i1', 'i2'],
    );

    expect(
      _ids(
        filterInventoryStockOpnameWorksheetLines(
          lines: lines,
          editedLineIds: {'i2'},
          invalidLineIds: {'i3'},
          state: const InventoryStockOpnameWorksheetFilterState(
            sort: InventoryStockOpnameWorksheetSort.editedFirst,
          ),
        ),
      ),
      ['i2', 'i1', 'i3'],
    );
  });
}

List<String> _ids(List<InventoryStockOpnameLine> lines) {
  return [for (final line in lines) line.id];
}

InventoryStockOpnameLine _line({
  required String id,
  String productName = 'Laptop',
  String skuLabel = 'LT-001',
  int systemQuantity = 5,
  int actualQuantity = 5,
  String notes = '',
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: id,
    productName: productName,
    skuLabel: skuLabel,
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
    notes: notes,
  );
}
