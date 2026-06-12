/// Summarizes editable stock opname count-sheet changes that are not yet saved.
class InventoryStockOpnameDraftStatus {
  const InventoryStockOpnameDraftStatus({
    required this.changedLineCount,
    required this.invalidActualQuantityLineCount,
  }) : assert(changedLineCount >= 0),
       assert(invalidActualQuantityLineCount >= 0);

  static const clean = InventoryStockOpnameDraftStatus(
    changedLineCount: 0,
    invalidActualQuantityLineCount: 0,
  );

  final int changedLineCount;
  final int invalidActualQuantityLineCount;

  int get affectedLineCount =>
      changedLineCount + invalidActualQuantityLineCount;

  bool get hasChangedLines => changedLineCount > 0;

  bool get hasInvalidActualQuantityDrafts => invalidActualQuantityLineCount > 0;

  bool get hasUnsavedChanges =>
      hasChangedLines || hasInvalidActualQuantityDrafts;
}
