import '../models/inventory_stock_opname_count_sheet_mutations.dart';
import '../models/inventory_stock_opname_count_sheet_snapshot.dart';
import '../models/inventory_stock_opname_draft_review.dart';
import '../models/inventory_stock_opname_draft_status.dart';
import '../models/inventory_stock_opname_session.dart';

/// Owns stock opname count-sheet lines, draft validity, and saved baselines.
///
/// This state object keeps count-sheet mutation rules independent from Flutter
/// form wiring so the stock opname form controller can focus on orchestration.
class InventoryStockOpnameCountSheetState {
  InventoryStockOpnameCountSheetState({
    Iterable<InventoryStockOpnameLine> lines = const [],
  }) : _lines = List.unmodifiable(lines) {
    _markCurrentCountSheetClean();
  }

  List<InventoryStockOpnameLine> _lines;
  InventoryStockOpnameCountSheetSnapshot _savedCountSheetSnapshot =
      InventoryStockOpnameCountSheetSnapshot.empty;
  final Set<String> _invalidActualQuantityLineIds = <String>{};

  List<InventoryStockOpnameLine> get lines => _lines;

  Set<String> get invalidActualQuantityLineIds =>
      Set.unmodifiable(_invalidActualQuantityLineIds);

  Set<String> get changedLineIds =>
      _savedCountSheetSnapshot.changedLineIds(_lines);

  InventoryStockOpnameDraftStatus get draftStatus {
    return InventoryStockOpnameDraftStatus(
      changedLineCount: _savedCountSheetSnapshot.changedLineCount(_lines),
      invalidActualQuantityLineCount: _invalidActualQuantityLineIds.length,
    );
  }

  bool get hasUnsavedChanges => draftStatus.hasUnsavedChanges;

  InventoryStockOpnameDraftReviewTarget? get draftReviewTarget {
    return resolveInventoryStockOpnameDraftReviewTarget(
      lines: _lines,
      invalidLineIds: _invalidActualQuantityLineIds,
      snapshot: _savedCountSheetSnapshot,
    );
  }

  /// Replaces the visible count sheet and treats it as the saved baseline.
  void replaceWithCleanLines(Iterable<InventoryStockOpnameLine> lines) {
    _lines = List.unmodifiable(lines);
    _invalidActualQuantityLineIds.clear();
    _markCurrentCountSheetClean();
  }

  /// Applies a typed actual quantity draft to one count-sheet line.
  bool updateActualQuantity({required String lineId, required String value}) {
    final parsed = parseInventoryStockOpnameActualQuantity(value);
    if (parsed == null) {
      if (_lineExists(lineId) && _invalidActualQuantityLineIds.add(lineId)) {
        return true;
      }
      return false;
    }

    final hadInvalidDraft = _invalidActualQuantityLineIds.remove(lineId);
    final result = updateInventoryStockOpnameCountLine(
      lines: _lines,
      lineId: lineId,
      update: (currentLine) => currentLine.copyWith(actualQuantity: parsed),
    );
    if (result.lineFound) {
      _lines = result.lines;
      return true;
    }
    return hadInvalidDraft;
  }

  /// Updates the operator note for one count-sheet line.
  bool updateNotes({required String lineId, required String value}) {
    final result = updateInventoryStockOpnameCountLine(
      lines: _lines,
      lineId: lineId,
      update: (currentLine) => currentLine.copyWith(notes: value),
    );
    if (!result.lineFound) return false;

    _lines = result.lines;
    return true;
  }

  /// Matches one line back to its current system quantity.
  bool matchSystemCount(String lineId) {
    final hadInvalidDraft = _invalidActualQuantityLineIds.remove(lineId);
    final result = matchInventoryStockOpnameSystemCount(
      lines: _lines,
      lineId: lineId,
    );
    if (result.lineFound) {
      _lines = result.lines;
      return true;
    }
    return hadInvalidDraft;
  }

  /// Matches visible worksheet lines back to their current system quantities.
  bool matchSystemCounts(Iterable<String> lineIds) {
    final result = matchInventoryStockOpnameSystemCounts(
      lines: _lines,
      lineIds: lineIds,
    );
    if (result.targetLineIds.isEmpty) return false;

    final invalidDraftCountBefore = _invalidActualQuantityLineIds.length;
    _invalidActualQuantityLineIds.removeAll(result.targetLineIds);
    final didChange =
        result.didChange ||
        invalidDraftCountBefore != _invalidActualQuantityLineIds.length;
    if (!didChange) return false;

    _lines = result.lines;
    return true;
  }

  /// Marks the current count sheet as saved and clears invalid draft flags.
  bool markSaved() {
    final hadUnsavedChanges = hasUnsavedChanges;
    _invalidActualQuantityLineIds.clear();
    _markCurrentCountSheetClean();
    return hadUnsavedChanges;
  }

  bool _lineExists(String lineId) {
    return inventoryStockOpnameLineExists(lines: _lines, lineId: lineId);
  }

  void _markCurrentCountSheetClean() {
    _savedCountSheetSnapshot = InventoryStockOpnameCountSheetSnapshot.fromLines(
      _lines,
    );
  }
}
