import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_adjustment_draft.dart';

void main() {
  test('increase adjustment projects quantity and movement quantity', () {
    const draft = InventoryStockAdjustmentDraft(
      direction: InventoryStockAdjustmentDirection.increase,
      quantity: 4,
      reason: 'Cycle count correction',
    );

    expect(
      validateInventoryStockAdjustmentDraft(draft, currentQuantity: 3),
      isNull,
    );
    expect(draft.adjustedQuantity(3), 7);
    expect(draft.movementQuantity, 4);
    expect(draft.successLabel, 'Stock increased successfully');
  });

  test(
    'decrease adjustment projects quantity and negative movement quantity',
    () {
      const draft = InventoryStockAdjustmentDraft(
        direction: InventoryStockAdjustmentDirection.decrease,
        quantity: 2,
      );

      expect(
        validateInventoryStockAdjustmentDraft(draft, currentQuantity: 3),
        isNull,
      );
      expect(draft.adjustedQuantity(3), 1);
      expect(draft.movementQuantity, -2);
      expect(draft.successLabel, 'Stock decreased successfully');
    },
  );

  test('adjustment draft validates quantity and available stock', () {
    expect(
      validateInventoryStockAdjustmentDraft(
        const InventoryStockAdjustmentDraft(
          direction: InventoryStockAdjustmentDirection.increase,
          quantity: 0,
        ),
        currentQuantity: 3,
      ),
      InventoryStockAdjustmentIssue.invalidQuantity,
    );
    expect(
      validateInventoryStockAdjustmentDraft(
        const InventoryStockAdjustmentDraft(
          direction: InventoryStockAdjustmentDirection.decrease,
          quantity: 4,
        ),
        currentQuantity: 3,
      ),
      InventoryStockAdjustmentIssue.insufficientStock,
    );
    expect(
      inventoryStockAdjustmentIssueLabel(
        InventoryStockAdjustmentIssue.insufficientStock,
      ),
      'Decrease quantity cannot exceed available stock.',
    );
  });
}
