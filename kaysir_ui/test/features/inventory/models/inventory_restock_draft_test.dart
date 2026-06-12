import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_restock_draft.dart';

void main() {
  test('restock draft projects quantity and estimated cost', () {
    const draft = InventoryRestockDraft(
      quantity: 6,
      notes: 'Supplier delivery',
    );

    expect(validateInventoryRestockDraft(draft), isNull);
    expect(draft.projectedQuantity(2), 8);
    expect(draft.estimatedCost(25), 150);
  });

  test('restock draft rejects invalid quantity', () {
    const draft = InventoryRestockDraft(quantity: 0);

    final issue = validateInventoryRestockDraft(draft);

    expect(issue, InventoryRestockIssue.invalidQuantity);
    expect(
      inventoryRestockIssueLabel(issue!),
      'Enter a restock quantity greater than zero.',
    );
  });
}
