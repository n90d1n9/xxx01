import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stockopname.dart';
import 'package:kaysir/features/inventory/services/inventory_stock_opname_service.dart';

void main() {
  test('draft mutation stores count without stock updates or movements', () {
    final occurredAt = DateTime(2026, 5, 31, 8);
    final mutation = buildInventoryStockOpnameMutation(
      warehouseId: 'w1',
      conductedBy: '  Aisyah  ',
      lines: [_line(actualQuantity: 7)],
      status: StockOpnameStatus.draft,
      occurredAt: occurredAt,
    );

    expect(mutation.stockOpname.id, 'SO-${occurredAt.millisecondsSinceEpoch}');
    expect(mutation.stockOpname.conductedBy, 'Aisyah');
    expect(mutation.stockOpname.status, StockOpnameStatus.draft);
    expect(mutation.quantityUpdates, isEmpty);
    expect(mutation.movements, isEmpty);
  });

  test('completed mutation creates quantity updates and audit movements', () {
    final mutation = buildInventoryStockOpnameMutation(
      warehouseId: 'w1',
      conductedBy: 'Nina',
      lines: [
        _line(id: 'i1', actualQuantity: 7, notes: 'Shelf recount'),
        _line(id: 'i2', systemQuantity: 8, actualQuantity: 6),
        _line(id: 'i3', systemQuantity: 4, actualQuantity: 4),
      ],
      status: StockOpnameStatus.completed,
      occurredAt: DateTime(2026, 5, 31, 9),
    );

    expect(mutation.stockOpname.status, StockOpnameStatus.completed);
    expect(mutation.stockOpname.items, hasLength(3));
    expect(mutation.quantityUpdates, hasLength(2));
    expect(mutation.quantityUpdates[0].itemId, 'i1');
    expect(mutation.quantityUpdates[0].quantity, 7);
    expect(mutation.quantityUpdates[1].itemId, 'i2');
    expect(mutation.quantityUpdates[1].quantity, 6);
    expect(mutation.movements, hasLength(2));
    expect(mutation.movements[0].type, MovementType.stockOpname);
    expect(mutation.movements[0].quantity, 2);
    expect(mutation.movements[0].notes, 'Shelf recount');
    expect(mutation.movements[1].quantity, -2);
    expect(mutation.movements[1].notes, 'Stock opname shortage of 2 units');
  });

  test('applies stock opname mutation through injected state callbacks', () {
    final mutation = buildInventoryStockOpnameMutation(
      warehouseId: 'w1',
      conductedBy: 'Nina',
      lines: [_line(id: 'i1', actualQuantity: 7)],
      status: StockOpnameStatus.completed,
      occurredAt: DateTime(2026, 5, 31, 9),
    );
    final stockOpnames = <StockOpname>[];
    final quantityUpdates = <String, int>{};
    final movements = <InventoryMovement>[];

    final result = applyInventoryStockOpnameMutation(
      mutation: mutation,
      addStockOpname: stockOpnames.add,
      updateQuantity: (itemId, quantity) {
        quantityUpdates[itemId] = quantity;
      },
      addMovement: movements.add,
    );

    expect(stockOpnames.single.id, mutation.stockOpname.id);
    expect(quantityUpdates, {'i1': 7});
    expect(movements.single.type, MovementType.stockOpname);
    expect(result.quantityUpdateCount, 1);
    expect(result.movementCount, 1);
    expect(result.updatedInventory, isTrue);
  });

  test('applies draft stock opname without inventory side effects', () {
    final mutation = buildInventoryStockOpnameMutation(
      warehouseId: 'w1',
      conductedBy: 'Nina',
      lines: [_line()],
      status: StockOpnameStatus.draft,
      occurredAt: DateTime(2026, 5, 31, 9),
    );
    final stockOpnames = <StockOpname>[];

    final result = applyInventoryStockOpnameMutation(
      mutation: mutation,
      addStockOpname: stockOpnames.add,
      updateQuantity: (_, _) => fail('draft should not update quantities'),
      addMovement: (_) => fail('draft should not add movements'),
    );

    expect(stockOpnames.single.status, StockOpnameStatus.draft);
    expect(result.quantityUpdateCount, 0);
    expect(result.movementCount, 0);
    expect(result.updatedInventory, isFalse);
  });
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 5,
  String notes = '',
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
    notes: notes,
  );
}
