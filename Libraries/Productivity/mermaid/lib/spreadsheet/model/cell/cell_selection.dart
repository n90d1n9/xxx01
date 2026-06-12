import 'dart:math' as math;

import 'cell_address.dart';

class CellSelection {
  final CellAddress start;
  final CellAddress? end;

  CellSelection(this.start, [this.end]);

  // Add this factory constructor
  factory CellSelection.single(CellAddress address) {
    return CellSelection(address);
  }

  bool isRange() => end != null;

  List<CellAddress> getCells() {
    if (end == null) return [start];
    final cells = <CellAddress>[];
    final minRow = math.min(start.row, end!.row);
    final maxRow = math.max(start.row, end!.row);
    final minCol = math.min(start.col, end!.col);
    final maxCol = math.max(start.col, end!.col);
    for (int r = minRow; r <= maxRow; r++) {
      for (int c = minCol; c <= maxCol; c++) {
        cells.add(CellAddress(r, c));
      }
    }
    return cells;
  }
}
