enum InventoryRestockIssue { invalidQuantity }

class InventoryRestockDraft {
  const InventoryRestockDraft({required this.quantity, this.notes = ''});

  final int quantity;
  final String notes;

  int projectedQuantity(int currentQuantity) {
    return currentQuantity + quantity;
  }

  double estimatedCost(double unitCost) {
    return unitCost * quantity;
  }
}

InventoryRestockIssue? validateInventoryRestockDraft(
  InventoryRestockDraft draft,
) {
  if (draft.quantity <= 0) {
    return InventoryRestockIssue.invalidQuantity;
  }

  return null;
}

String inventoryRestockIssueLabel(InventoryRestockIssue issue) {
  switch (issue) {
    case InventoryRestockIssue.invalidQuantity:
      return 'Enter a restock quantity greater than zero.';
  }
}
