import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cell/cell_address.dart';
import '../model/cell/cell_selection.dart';
import '../state/spreadsheet_provider.dart';
import 'spreadsheet_cell.dart';

class SpreadsheetGrid extends ConsumerStatefulWidget {
  final ScrollController horizontalController;
  final ScrollController verticalController;
  final int rows = 100;
  final int cols = 26;

  const SpreadsheetGrid({
    Key? key,
    required this.horizontalController,
    required this.verticalController,
  }) : super(key: key);

  @override
  ConsumerState<SpreadsheetGrid> createState() => _SpreadsheetGridState();
}

class _SpreadsheetGridState extends ConsumerState<SpreadsheetGrid> {
  CellAddress? _rangeStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final position = details.localPosition;
        final addr = _getCellFromPosition(position);
        if (addr != null) {
          _rangeStart = addr;
          ref.read(selectedCellProvider.notifier).state = CellSelection(addr);
        }
      },
      onPanUpdate: (details) {
        if (_rangeStart != null) {
          final position = details.localPosition;
          final addr = _getCellFromPosition(position);
          if (addr != null) {
            ref.read(selectedCellProvider.notifier).state = CellSelection(
              _rangeStart!,
              addr,
            );
          }
        }
      },
      onPanEnd: (details) {
        _rangeStart = null;
      },
      child: SingleChildScrollView(
        controller: widget.verticalController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          controller: widget.horizontalController,
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              _buildHeaderRow(),
              ...List.generate(widget.rows, (row) => _buildRow(row)),
            ],
          ),
        ),
      ),
    );
  }

  CellAddress? _getCellFromPosition(Offset position) {
    const rowHeight = 40.0;
    const colWidth = 100.0;
    const headerHeight = 30.0;
    const rowHeaderWidth = 50.0;

    if (position.dy < headerHeight || position.dx < rowHeaderWidth) {
      return null;
    }

    final row = ((position.dy - headerHeight) / rowHeight).floor();
    final col = ((position.dx - rowHeaderWidth) / colWidth).floor();

    if (row >= 0 && row < widget.rows && col >= 0 && col < widget.cols) {
      return CellAddress(row, col);
    }
    return null;
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        ...List.generate(
          widget.cols,
          (col) => Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[400]!),
            ),
            alignment: Alignment.center,
            child: Text(
              CellAddress.colToLabel(col),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int row) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[400]!),
          ),
          alignment: Alignment.center,
          child: Text(
            '${row + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        ...List.generate(
          widget.cols,
          (col) => SpreadsheetCell(address: CellAddress(row, col)),
        ),
      ],
    );
  }
}
