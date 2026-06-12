/// Presentation details for stock opname visible-row batch actions.
class InventoryStockOpnameBatchActionDetails {
  const InventoryStockOpnameBatchActionDetails({
    required this.isVisible,
    required this.canMatchVisible,
    required this.summaryLabel,
    required this.matchActionLabel,
  });

  final bool isVisible;
  final bool canMatchVisible;
  final String summaryLabel;
  final String matchActionLabel;
}

/// Resolves the visible-row batch action state for stock opname worksheets.
InventoryStockOpnameBatchActionDetails inventoryStockOpnameBatchActionDetails({
  required int visibleLineCount,
  required int matchableLineCount,
  required bool hasMatchVisibleHandler,
}) {
  if (visibleLineCount <= 0) {
    return const InventoryStockOpnameBatchActionDetails(
      isVisible: false,
      canMatchVisible: false,
      summaryLabel: '',
      matchActionLabel: 'Match visible',
    );
  }

  final safeMatchableLineCount =
      matchableLineCount < 0 ? 0 : matchableLineCount;
  final summaryLabel =
      safeMatchableLineCount == 0
          ? 'All visible rows matched'
          : safeMatchableLineCount == 1
          ? '1 row needs matching'
          : '$safeMatchableLineCount rows need matching';

  return InventoryStockOpnameBatchActionDetails(
    isVisible: true,
    canMatchVisible: safeMatchableLineCount > 0 && hasMatchVisibleHandler,
    summaryLabel: summaryLabel,
    matchActionLabel: 'Match visible',
  );
}
