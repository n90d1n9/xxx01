import 'inventory_stock_opname_session.dart';

/// Saved baseline for comparing editable stock opname line changes.
class InventoryStockOpnameLineSnapshot {
  const InventoryStockOpnameLineSnapshot({
    required this.actualQuantity,
    required this.notes,
  });

  factory InventoryStockOpnameLineSnapshot.fromLine(
    InventoryStockOpnameLine line,
  ) {
    return InventoryStockOpnameLineSnapshot(
      actualQuantity: line.actualQuantity,
      notes: line.notes.trim(),
    );
  }

  final int actualQuantity;
  final String notes;

  bool matches(InventoryStockOpnameLine line) {
    return actualQuantity == line.actualQuantity && notes == line.notes.trim();
  }
}

/// Immutable count-sheet baseline used to detect edited and removed rows.
class InventoryStockOpnameCountSheetSnapshot {
  const InventoryStockOpnameCountSheetSnapshot._(this._linesById);

  static const empty = InventoryStockOpnameCountSheetSnapshot._({});

  factory InventoryStockOpnameCountSheetSnapshot.fromLines(
    Iterable<InventoryStockOpnameLine> lines,
  ) {
    return InventoryStockOpnameCountSheetSnapshot._(
      Map.unmodifiable({
        for (final line in lines)
          line.id: InventoryStockOpnameLineSnapshot.fromLine(line),
      }),
    );
  }

  final Map<String, InventoryStockOpnameLineSnapshot> _linesById;

  bool hasLineChanged(InventoryStockOpnameLine line) {
    final snapshot = _linesById[line.id];
    return snapshot == null || !snapshot.matches(line);
  }

  Set<String> changedLineIds(Iterable<InventoryStockOpnameLine> lines) {
    return Set.unmodifiable([
      for (final line in lines)
        if (hasLineChanged(line)) line.id,
    ]);
  }

  int changedLineCount(Iterable<InventoryStockOpnameLine> lines) {
    final currentLines = List<InventoryStockOpnameLine>.unmodifiable(lines);
    final currentLineIds = {for (final line in currentLines) line.id};
    var changedLineCount = changedLineIds(currentLines).length;

    for (final snapshotLineId in _linesById.keys) {
      if (!currentLineIds.contains(snapshotLineId)) {
        changedLineCount += 1;
      }
    }

    return changedLineCount;
  }

  String? firstChangedLineId(Iterable<InventoryStockOpnameLine> lines) {
    for (final line in lines) {
      if (hasLineChanged(line)) return line.id;
    }
    return null;
  }
}
