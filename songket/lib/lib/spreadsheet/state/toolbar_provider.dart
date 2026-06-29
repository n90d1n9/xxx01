import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cell/cell_address.dart';
import '../model/cell/cell_data.dart';
import '../model/cell/cell_selection.dart';
import '../model/cell/cell_style.dart';
import '../model/cell/cell_validation.dart';
import 'spreadsheet_provider.dart';

final toolbarControllerProvider = Provider((ref) {
  return ToolbarController(ref);
});

class ToolbarController {
  final Ref ref;

  ToolbarController(this.ref);

  void toggleBold(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(bold: !current.style.bold),
          );
    }
  }

  void toggleItalic(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(italic: !current.style.italic),
          );
    }
  }

  void toggleUnderline(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(underline: !current.style.underline),
          );
    }
  }

  void setAlign(CellSelection selection, TextAlign align) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(addr, current.style.copyWith(align: align));
    }
  }

  void setBackground(CellSelection selection, Color color) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(backgroundColor: color),
          );
    }
  }

  void copy(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    final clipboard = <CellAddress, CellData>{};

    final minRow = cells.map((c) => c.row).reduce(math.min);
    final minCol = cells.map((c) => c.col).reduce(math.min);

    for (final addr in cells) {
      final cellData = data[addr];
      if (cellData != null) {
        clipboard[CellAddress(addr.row - minRow, addr.col - minCol)] = cellData;
      }
    }
    ref.read(clipboardProvider.notifier).state = clipboard;
  }

  void cut(CellSelection selection) {
    copy(selection);
    final cells = selection.getCells();
    ref.read(spreadsheetProvider.notifier).clearCells(cells);
  }

  void paste(CellSelection selection) {
    final clipboard = ref.read(clipboardProvider);
    if (clipboard == null) return;
    ref
        .read(spreadsheetProvider.notifier)
        .pasteCells(clipboard, selection.start);
  }

  void toggleWrapText(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(wrapText: !current.style.wrapText),
          );
    }
  }

  void mergeCells(CellSelection selection) {
    if (!selection.isRange()) return;

    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    final values = cells
        .map((addr) => data[addr]?.value ?? '')
        .where((v) => v.isNotEmpty)
        .join(' ');

    ref
        .read(spreadsheetProvider.notifier)
        .updateCellValue(selection.start, values);

    for (int i = 1; i < cells.length; i++) {
      ref.read(spreadsheetProvider.notifier).clearCell(cells[i]);
    }
  }

  void insertFunction(CellAddress addr, String function) {
    final formula = '=$function()';
    ref.read(spreadsheetProvider.notifier).updateCellValue(addr, formula);
  }

  // Font
  void setFontSize(CellSelection selection, double size) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(addr, current.style.copyWith(fontSize: size));
    }
  }

  void increaseFontSize(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      final currentSize = current.style.fontSize;
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(fontSize: currentSize + 1),
          );
    }
  }

  void decreaseFontSize(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      final currentSize = current.style.fontSize;
      if (currentSize > 8) {
        ref
            .read(spreadsheetProvider.notifier)
            .updateCellStyle(
              addr,
              current.style.copyWith(fontSize: currentSize - 1),
            );
      }
    }
  }

  // Border Management
  void setBorder(
    CellSelection selection, {
    bool top = false,
    bool bottom = false,
    bool left = false,
    bool right = false,
  }) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(
            addr,
            current.style.copyWith(
              borderTop: top,
              borderBottom: bottom,
              borderLeft: left,
              borderRight: right,
            ),
          );
    }
  }

  void setAllBorders(CellSelection selection) {
    setBorder(selection, top: true, bottom: true, left: true, right: true);
  }

  void clearBorders(CellSelection selection) {
    setBorder(selection);
  }

  //--------------
  /// Insert rows above selection
  void insertRowsAbove(CellSelection selection) {
    final row = selection.start.row;
    final count = selection.isRange()
        ? selection.end!.row - selection.start.row + 1
        : 1;
    ref.read(spreadsheetProvider.notifier).insertRows(row, count);
  }

  /// Insert rows below selection
  void insertRowsBelow(CellSelection selection) {
    final row = selection.start.row;
    final count = selection.isRange()
        ? selection.end!.row - selection.start.row + 1
        : 1;
    ref.read(spreadsheetProvider.notifier).insertRows(row + 1, count);
  }

  /// Delete selected rows
  void deleteRows(CellSelection selection) {
    final startRow = selection.start.row;
    final endRow = selection.isRange()
        ? selection.end!.row
        : selection.start.row;
    ref.read(spreadsheetProvider.notifier).deleteRows(startRow, endRow);
  }

  /// Insert columns left of selection
  void insertColumnsLeft(CellSelection selection) {
    final col = selection.start.col;
    final count = selection.isRange()
        ? selection.end!.col - selection.start.col + 1
        : 1;
    ref.read(spreadsheetProvider.notifier).insertColumns(col, count);
  }

  /// Insert columns right of selection
  void insertColumnsRight(CellSelection selection) {
    final col = selection.start.col;
    final count = selection.isRange()
        ? selection.end!.col - selection.start.col + 1
        : 1;
    ref.read(spreadsheetProvider.notifier).insertColumns(col + 1, count);
  }

  /// Delete selected columns
  void deleteColumns(CellSelection selection) {
    final startCol = selection.start.col;
    final endCol = selection.isRange()
        ? selection.end!.col
        : selection.start.col;
    ref.read(spreadsheetProvider.notifier).deleteColumns(startCol, endCol);
  }

  /// Auto-fit column width
  void autoFitColumn(CellSelection selection) {
    final col = selection.start.col;
    ref.read(spreadsheetProvider.notifier).autoFitColumn(col, ref);
  }

  /// Auto-fit row height
  void autoFitRow(CellSelection selection) {
    final row = selection.start.row;
    ref.read(spreadsheetProvider.notifier).autoFitRow(row, ref);
  }

  /// Hide selected rows
  void hideRows(CellSelection selection) {
    final startRow = selection.start.row;
    final endRow = selection.isRange()
        ? selection.end!.row
        : selection.start.row;
    for (int row = startRow; row <= endRow; row++) {
      ref.read(spreadsheetProvider.notifier).hideRow(row, ref);
    }
  }

  /// Show selected rows
  void showRows(CellSelection selection) {
    final startRow = selection.start.row;
    final endRow = selection.isRange()
        ? selection.end!.row
        : selection.start.row;
    for (int row = startRow; row <= endRow; row++) {
      ref.read(spreadsheetProvider.notifier).showRow(row, ref);
    }
  }

  /// Hide selected columns
  void hideColumns(CellSelection selection) {
    final startCol = selection.start.col;
    final endCol = selection.isRange()
        ? selection.end!.col
        : selection.start.col;
    for (int col = startCol; col <= endCol; col++) {
      ref.read(spreadsheetProvider.notifier).hideColumn(col, ref);
    }
  }

  /// Show selected columns
  void showColumns(CellSelection selection) {
    final startCol = selection.start.col;
    final endCol = selection.isRange()
        ? selection.end!.col
        : selection.start.col;
    for (int col = startCol; col <= endCol; col++) {
      ref.read(spreadsheetProvider.notifier).showColumn(col, ref);
    }
  }

  //----------------------
  // Insert

  void insertRowAbove(CellSelection selection) {
    final row = selection.start.row;
    ref.read(spreadsheetProvider.notifier).insertRow(row);
  }

  void insertRowBelow(CellSelection selection) {
    final row = selection.start.row;
    ref.read(spreadsheetProvider.notifier).insertRow(row + 1);
  }

  void deleteRow(CellSelection selection) {
    final row = selection.start.row;
    ref.read(spreadsheetProvider.notifier).deleteRow(row);
  }

  void insertColumnLeft(CellSelection selection) {
    final col = selection.start.col;
    ref.read(spreadsheetProvider.notifier).insertColumn(col);
  }

  void insertColumnRight(CellSelection selection) {
    final col = selection.start.col;
    ref.read(spreadsheetProvider.notifier).insertColumn(col + 1);
  }

  void deleteColumn(CellSelection selection) {
    final col = selection.start.col;
    ref.read(spreadsheetProvider.notifier).deleteColumn(col);
  }

  // Sort Data
  void sortRange(CellSelection selection, {bool ascending = true}) {
    if (!selection.isRange()) return;

    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);

    // Extract values and sort them
    final cellValues = cells.map((addr) => data[addr]).toList();
    cellValues.sort((a, b) {
      final valueA = a?.value ?? '';
      final valueB = b?.value ?? '';
      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });

    // Update cells with sorted values
    for (int i = 0; i < cells.length; i++) {
      if (cellValues[i] != null) {
        ref
            .read(spreadsheetProvider.notifier)
            .updateCellValue(cells[i], cellValues[i]!.value);
      }
    }
  }

  //----------
  /// Clear all formatting from selected cells while preserving values
  void clearFormatting(CellSelection selection) {
    final cells = selection.getCells();
    for (final addr in cells) {
      final current = ref.read(spreadsheetProvider)[addr];
      if (current != null) {
        // Keep the value but reset the style to default
        ref
            .read(spreadsheetProvider.notifier)
            .updateCellStyle(addr, const CellStyle());
      }
    }
  }

  /// Set text color for selected cells
  void setTextColor(CellSelection selection, Color color) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);
    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      ref
          .read(spreadsheetProvider.notifier)
          .updateCellStyle(addr, current.style.copyWith(textColor: color));
    }
  }

  /// Apply number formatting to selected cells
  void setNumberFormat(CellSelection selection, String formatType) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);

    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      final newStyle = current.style.copyWith(numberFormat: formatType);
      ref.read(spreadsheetProvider.notifier).updateCellStyle(addr, newStyle);
    }
  }

  /// Sort selected range
  void sortSelection(CellSelection selection, {bool ascending = true}) {
    ref
        .read(spreadsheetProvider.notifier)
        .sortRange(selection, ascending: ascending);
  }

  /// Apply filter to selected column
  void applyFilter(CellSelection selection) {
    final col = selection.start.col;
    final currentFilters = Map<int, String>.from(ref.read(filterProvider));
    currentFilters[col] =
        ''; // Empty string means filter is active but no specific filter set
    ref.read(filterProvider.notifier).state = currentFilters;
  }

  /// Remove filter from selected column
  void removeFilter(CellSelection selection) {
    final col = selection.start.col;
    final currentFilters = Map<int, String>.from(ref.read(filterProvider));
    currentFilters.remove(col);
    ref.read(filterProvider.notifier).state = currentFilters;
  }

  /// Freeze panes at selection
  void freezePanesAt(CellSelection selection) {
    ref.read(freezePanesProvider.notifier).state = selection.start;
  }

  /// Unfreeze all panes
  void unfreezePanes() {
    ref.read(freezePanesProvider.notifier).state = null;
  }

  /// Zoom in
  void zoomIn() {
    final currentZoom = ref.read(zoomLevelProvider);
    final newZoom = (currentZoom * 1.2).clamp(0.5, 3.0);
    ref.read(zoomLevelProvider.notifier).state = newZoom;
  }

  /// Zoom out
  void zoomOut() {
    final currentZoom = ref.read(zoomLevelProvider);
    final newZoom = (currentZoom / 1.2).clamp(0.5, 3.0);
    ref.read(zoomLevelProvider.notifier).state = newZoom;
  }

  /// Reset zoom to 100%
  void resetZoom() {
    ref.read(zoomLevelProvider.notifier).state = 1.0;
  }

  /// Search for text in spreadsheet
  void search(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.isNotEmpty) {
      final results = ref.read(spreadsheetProvider.notifier).search(query);
      ref.read(searchResultsProvider.notifier).state = results;
      ref.read(currentSearchIndexProvider.notifier).state = 0;
    } else {
      ref.read(searchResultsProvider.notifier).state = [];
    }
  }

  /// Navigate to next search result
  void nextSearchResult() {
    final results = ref.read(searchResultsProvider);
    final currentIndex = ref.read(currentSearchIndexProvider);
    if (results.isNotEmpty) {
      final nextIndex = (currentIndex + 1) % results.length;
      ref.read(currentSearchIndexProvider.notifier).state = nextIndex;

      // Create a single cell selection for the search result
      final selectedCell = CellSelection.single(results[nextIndex]);
      ref.read(selectedCellProvider.notifier).state = selectedCell;
    }
  }

  /// Navigate to previous search result
  void previousSearchResult() {
    final results = ref.read(searchResultsProvider);
    final currentIndex = ref.read(currentSearchIndexProvider);
    if (results.isNotEmpty) {
      final prevIndex = (currentIndex - 1 + results.length) % results.length;
      ref.read(currentSearchIndexProvider.notifier).state = prevIndex;

      // Create a single cell selection for the search result
      final selectedCell = CellSelection.single(results[prevIndex]);
      ref.read(selectedCellProvider.notifier).state = selectedCell;
    }
  }

  /// Replace all occurrences of text
  void replaceAll(String find, String replace) {
    ref.read(spreadsheetProvider.notifier).replaceAll(find, replace);
  }

  ///-----
  /// Apply data validation to selected cells
  void applyValidation(CellSelection selection, CellValidation validation) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);

    for (final addr in cells) {
      final current = data[addr] ?? CellData();
      final updated = current.copyWith(validation: validation);
      ref.read(spreadsheetProvider.notifier).updateCell(addr, updated);
    }
  }

  /// Clear data validation from selected cells
  void clearValidation(CellSelection selection) {
    final cells = selection.getCells();
    final data = ref.read(spreadsheetProvider);

    for (final addr in cells) {
      final current = data[addr];
      if (current != null) {
        final updated = current.copyWith(validation: null);
        ref.read(spreadsheetProvider.notifier).updateCell(addr, updated);
      }
    }
  }

  //----------

  /// Apply required field validation
  void applyRequiredValidation(
    CellSelection selection, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.required,
      errorMessage: errorMessage ?? 'This field is required',
    );
    applyValidation(selection, validation);
  }

  /// Apply phone number validation
  void applyPhoneValidation(CellSelection selection, {String? errorMessage}) {
    final validation = CellValidation(
      type: ValidationType.phone,
      errorMessage: errorMessage ?? 'Please enter a valid phone number',
    );
    applyValidation(selection, validation);
  }

  /// Apply regex pattern validation
  void applyRegexValidation(
    CellSelection selection,
    String pattern, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.regex,
      pattern: pattern,
      errorMessage: errorMessage ?? 'Value must match the required pattern',
    );
    applyValidation(selection, validation);
  }

  /// Apply minimum length validation
  void applyMinLengthValidation(
    CellSelection selection,
    int minLength, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.minLength,
      min: minLength.toString(),
      errorMessage:
          errorMessage ?? 'Value must be at least $minLength characters long',
    );
    applyValidation(selection, validation);
  }

  /// Apply maximum length validation
  void applyMaxLengthValidation(
    CellSelection selection,
    int maxLength, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.maxLength,
      max: maxLength.toString(),
      errorMessage:
          errorMessage ?? 'Value must be at most $maxLength characters long',
    );
    applyValidation(selection, validation);
  }

  /// Apply minimum value validation (works for numbers, dates, and text length)
  void applyMinValidation(
    CellSelection selection,
    String minValue, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.min,
      min: minValue,
      errorMessage: errorMessage ?? 'Value must be at least $minValue',
    );
    applyValidation(selection, validation);
  }

  /// Apply maximum value validation (works for numbers, dates, and text length)
  void applyMaxValidation(
    CellSelection selection,
    String maxValue, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.max,
      max: maxValue,
      errorMessage: errorMessage ?? 'Value must be at most $maxValue',
    );
    applyValidation(selection, validation);
  }

  //------

  /// Apply number validation to selected cells
  void applyNumberValidation(
    CellSelection selection, {
    double? min,
    double? max,
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.number,
      min: min?.toString(),
      max: max?.toString(),
      errorMessage: errorMessage,
    );
    applyValidation(selection, validation);
  }

  /// Apply list validation to selected cells
  void applyListValidation(
    CellSelection selection,
    List<String> options, {
    String? errorMessage,
  }) {
    final validation = CellValidation(
      type: ValidationType.list,
      options: options,
      errorMessage: errorMessage,
    );
    applyValidation(selection, validation);
  }

  /// Apply date validation to selected cells
  void applyDateValidation(CellSelection selection, {String? errorMessage}) {
    final validation = CellValidation(
      type: ValidationType.date,
      errorMessage: errorMessage,
    );
    applyValidation(selection, validation);
  }

  /// Apply email validation to selected cells
  void applyEmailValidation(CellSelection selection, {String? errorMessage}) {
    final validation = CellValidation(
      type: ValidationType.email,
      errorMessage: errorMessage,
    );
    applyValidation(selection, validation);
  }

  /// Apply URL validation to selected cells
  void applyUrlValidation(CellSelection selection, {String? errorMessage}) {
    final validation = CellValidation(
      type: ValidationType.url,
      errorMessage: errorMessage,
    );
    applyValidation(selection, validation);
  }

  ////---------
}
