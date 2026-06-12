import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_adjustment_draft.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_adjustment_dialog_state.dart';

void main() {
  test('stock adjustment state parses draft input', () {
    final draft = inventoryStockAdjustmentDraftFromInput(
      direction: InventoryStockAdjustmentDirection.increase,
      quantityText: ' 4 ',
      reason: '  Count verified  ',
    );

    expect(draft?.direction, InventoryStockAdjustmentDirection.increase);
    expect(draft?.quantity, 4);
    expect(draft?.reason, 'Count verified');
    expect(
      inventoryStockAdjustmentDraftFromInput(
        direction: InventoryStockAdjustmentDirection.increase,
        quantityText: 'abc',
        reason: '',
      ),
      isNull,
    );
  });

  test('stock adjustment state computes projected quantity', () {
    final decreaseDraft = InventoryStockAdjustmentDraft(
      direction: InventoryStockAdjustmentDirection.decrease,
      quantity: 8,
    );

    expect(
      inventoryStockAdjustmentProjectedQuantity(
        currentQuantity: 12,
        draft: decreaseDraft,
      ),
      4,
    );
    expect(
      inventoryStockAdjustmentProjectedQuantity(
        currentQuantity: 12,
        draft: null,
      ),
      12,
    );
  });

  test('stock adjustment state exposes direction copy', () {
    expect(
      inventoryStockAdjustmentDirectionLabel(
        InventoryStockAdjustmentDirection.increase,
      ),
      'Increase',
    );
    expect(
      inventoryStockAdjustmentDirectionVerb(
        InventoryStockAdjustmentDirection.decrease,
      ),
      'remove',
    );
  });
}
