import 'inventory_stock_opname_session.dart';

/// Result of applying a single count-sheet line mutation.
class InventoryStockOpnameLineMutationResult {
  const InventoryStockOpnameLineMutationResult({
    required this.lines,
    required this.lineFound,
  });

  final List<InventoryStockOpnameLine> lines;
  final bool lineFound;
}

/// Result of applying a batch count-sheet mutation.
class InventoryStockOpnameBatchMutationResult {
  const InventoryStockOpnameBatchMutationResult({
    required this.lines,
    required this.didChange,
    required this.targetLineIds,
  });

  final List<InventoryStockOpnameLine> lines;
  final bool didChange;
  final Set<String> targetLineIds;
}

/// Parses a draft actual quantity entered in the stock opname worksheet.
int? parseInventoryStockOpnameActualQuantity(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) return null;
  return parsed;
}

/// Returns whether a count-sheet line id exists in the current worksheet.
bool inventoryStockOpnameLineExists({
  required Iterable<InventoryStockOpnameLine> lines,
  required String lineId,
}) {
  return lines.any((line) => line.id == lineId);
}

/// Applies an update to one count-sheet line without mutating the original list.
InventoryStockOpnameLineMutationResult updateInventoryStockOpnameCountLine({
  required List<InventoryStockOpnameLine> lines,
  required String lineId,
  required InventoryStockOpnameLine Function(InventoryStockOpnameLine line)
  update,
}) {
  final lineIndex = lines.indexWhere((line) => line.id == lineId);
  if (lineIndex == -1) {
    return InventoryStockOpnameLineMutationResult(
      lines: List.unmodifiable(lines),
      lineFound: false,
    );
  }

  final updatedLines = [...lines];
  updatedLines[lineIndex] = update(updatedLines[lineIndex]);
  return InventoryStockOpnameLineMutationResult(
    lines: List.unmodifiable(updatedLines),
    lineFound: true,
  );
}

/// Matches one count-sheet line back to its system quantity.
InventoryStockOpnameLineMutationResult matchInventoryStockOpnameSystemCount({
  required List<InventoryStockOpnameLine> lines,
  required String lineId,
}) {
  return updateInventoryStockOpnameCountLine(
    lines: lines,
    lineId: lineId,
    update: (line) => line.copyWith(actualQuantity: line.systemQuantity),
  );
}

/// Matches all target count-sheet lines back to their system quantities.
InventoryStockOpnameBatchMutationResult matchInventoryStockOpnameSystemCounts({
  required List<InventoryStockOpnameLine> lines,
  required Iterable<String> lineIds,
}) {
  final targetLineIds = {
    for (final lineId in lineIds)
      if (inventoryStockOpnameLineExists(lines: lines, lineId: lineId)) lineId,
  };
  if (targetLineIds.isEmpty) {
    return InventoryStockOpnameBatchMutationResult(
      lines: List.unmodifiable(lines),
      didChange: false,
      targetLineIds: const {},
    );
  }

  var didChange = false;
  final updatedLines = [
    for (final line in lines)
      if (targetLineIds.contains(line.id))
        _matchInventoryStockOpnameSystemCountLine(
          line,
          onChanged: () => didChange = true,
        )
      else
        line,
  ];

  return InventoryStockOpnameBatchMutationResult(
    lines: List.unmodifiable(updatedLines),
    didChange: didChange,
    targetLineIds: Set.unmodifiable(targetLineIds),
  );
}

InventoryStockOpnameLine _matchInventoryStockOpnameSystemCountLine(
  InventoryStockOpnameLine line, {
  required void Function() onChanged,
}) {
  if (line.actualQuantity == line.systemQuantity) return line;

  onChanged();
  return line.copyWith(actualQuantity: line.systemQuantity);
}
