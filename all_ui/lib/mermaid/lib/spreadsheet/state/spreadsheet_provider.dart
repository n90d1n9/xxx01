// Providers
import 'dart:math' as math;

import 'package:csv/csv.dart';
import 'package:excel_plus/excel_plus.dart' as excel_lib;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/cell/cell_address.dart';
import '../model/cell/cell_data.dart';
import '../model/cell/cell_selection.dart';
import '../model/cell/cell_style.dart';
import '../model/column_config.dart';
import '../model/row_config.dart';
import '../model/undo_redo_action.dart';

final selectedCellProvider = StateProvider<CellSelection?>((ref) => null);

final undoStackProvider = StateProvider<List<UndoRedoAction>>((ref) => []);
final redoStackProvider = StateProvider<List<UndoRedoAction>>((ref) => []);

final clipboardProvider = StateProvider<Map<CellAddress, CellData>?>(
  (ref) => null,
);

final freezePanesProvider = StateProvider<CellAddress?>((ref) => null);

final filterProvider = StateProvider<Map<int, String>>((ref) => {});

final sortColumnProvider = StateProvider<int?>((ref) => null);
final sortAscendingProvider = StateProvider<bool>((ref) => true);

final columnConfigProvider = StateProvider<Map<int, ColumnConfig>>((ref) => {});
final rowConfigProvider = StateProvider<Map<int, RowConfig>>((ref) => {});

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = StateProvider<List<CellAddress>>((ref) => []);
final currentSearchIndexProvider = StateProvider<int>((ref) => 0);

final zoomLevelProvider = StateProvider<double>((ref) => 1.0);

final spreadsheetProvider =
    StateNotifierProvider<SpreadsheetNotifier, Map<CellAddress, CellData>>(
      (ref) => SpreadsheetNotifier(),
    );

class SpreadsheetNotifier extends StateNotifier<Map<CellAddress, CellData>> {
  SpreadsheetNotifier() : super({});

  void updateCell(CellAddress addr, CellData data) {
    state = {...state, addr: data};
    _recalculateFormulas();
  }

  void updateCellValue(CellAddress addr, String value) {
    final current = state[addr] ?? CellData();

    // Validate input
    if (current.validation != null && !current.validation!.validate(value)) {
      return; // Validation failed
    }

    if (value.startsWith('=')) {
      state = {...state, addr: current.copyWith(formula: value, value: '')};
      _recalculateFormulas();
    } else {
      state = {
        ...state,
        addr: current.copyWith(value: value, clearFormula: true),
      };
    }
  }

  void updateCellStyle(CellAddress addr, CellStyle style) {
    final current = state[addr] ?? CellData();
    state = {...state, addr: current.copyWith(style: style)};
  }

  void clearCell(CellAddress addr) {
    final newState = Map<CellAddress, CellData>.from(state);
    newState.remove(addr);
    state = newState;
  }

  void clearCells(List<CellAddress> addresses) {
    final newState = Map<CellAddress, CellData>.from(state);
    for (final addr in addresses) {
      newState.remove(addr);
    }
    state = newState;
  }

  void pasteCells(Map<CellAddress, CellData> cells, CellAddress targetStart) {
    final newState = Map<CellAddress, CellData>.from(state);
    cells.forEach((sourceAddr, data) {
      final targetAddr = CellAddress(
        targetStart.row + sourceAddr.row,
        targetStart.col + sourceAddr.col,
      );
      newState[targetAddr] = data;
    });
    state = newState;
    _recalculateFormulas();
  }

  void fillDown(CellAddress start, int count) {
    final sourceData = state[start];
    if (sourceData == null) return;

    final newState = Map<CellAddress, CellData>.from(state);
    for (int i = 1; i <= count; i++) {
      newState[CellAddress(start.row + i, start.col)] = sourceData;
    }
    state = newState;
    _recalculateFormulas();
  }

  void fillRight(CellAddress start, int count) {
    final sourceData = state[start];
    if (sourceData == null) return;

    final newState = Map<CellAddress, CellData>.from(state);
    for (int i = 1; i <= count; i++) {
      newState[CellAddress(start.row, start.col + i)] = sourceData;
    }
    state = newState;
    _recalculateFormulas();
  }

  void importFromExcel(excel_lib.Excel excel) {
    final newState = <CellAddress, CellData>{};

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var row = 0; row < sheet.maxRows; row++) {
        for (var col = 0; col < sheet.maxColumns; col++) {
          final cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: row,
            ),
          );

          if (cell.value != null) {
            final cellData = CellData(
              value: cell.value.toString(),
              style: _convertExcelStyle(cell),
            );
            newState[CellAddress(row, col)] = cellData;
          }
        }
      }
      break; // Only import first sheet for now
    }

    state = newState;
    _recalculateFormulas();
  }

  CellStyle _convertExcelStyle(excel_lib.Data cell) {
    final style = CellStyle();

    // Convert Excel cell style to our CellStyle
    // This is simplified - real implementation would be more complex
    if (cell.cellStyle != null) {
      final excelStyle = cell.cellStyle!;
      return style.copyWith(
        bold: excelStyle.isBold,
        italic: excelStyle.isItalic,
        underline: excelStyle.underline != excel_lib.Underline.None,
      );
    }

    return style;
  }

  void importFromCSV(String csvContent) {
    final rows = const CsvToListConverter().convert(csvContent);
    final newState = <CellAddress, CellData>{};

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final value = rows[r][c]?.toString() ?? '';
        if (value.isNotEmpty) {
          newState[CellAddress(r, c)] = CellData(value: value);
        }
      }
    }

    state = newState;
    _recalculateFormulas();
  }

  String exportToCSV() {
    if (state.isEmpty) return '';

    final maxRow = state.keys.map((e) => e.row).reduce(math.max);
    final maxCol = state.keys.map((e) => e.col).reduce(math.max);

    final rows = <List<String>>[];
    for (int r = 0; r <= maxRow; r++) {
      final row = <String>[];
      for (int c = 0; c <= maxCol; c++) {
        final cell = state[CellAddress(r, c)];
        row.add(cell?.value ?? '');
      }
      rows.add(row);
    }

    return const ListToCsvConverter().convert(rows);
  }

  excel_lib.Excel exportToExcel() {
    final excel = excel_lib.Excel.createExcel();
    final sheet = excel['Sheet1'];

    state.forEach((addr, data) {
      final cell = sheet.cell(
        excel_lib.CellIndex.indexByColumnRow(
          columnIndex: addr.col,
          rowIndex: addr.row,
        ),
      );

      cell.value = excel_lib.TextCellValue(data.value);

      // Apply styling
      if (data.style.bold || data.style.italic) {
        cell.cellStyle = excel_lib.CellStyle(
          bold: data.style.bold,
          italic: data.style.italic,
        );
      }
    });

    return excel;
  }

  Map<String, dynamic> exportToJson() {
    final cellsJson = <String, dynamic>{};
    state.forEach((addr, data) {
      cellsJson['${addr.row},${addr.col}'] = data.toJson();
    });
    return {'cells': cellsJson, 'version': '2.0'};
  }

  void importFromJson(Map<String, dynamic> json) {
    final newState = <CellAddress, CellData>{};
    final cellsJson = json['cells'] as Map<String, dynamic>? ?? {};
    cellsJson.forEach((key, value) {
      final parts = key.split(',');
      final addr = CellAddress(int.parse(parts[0]), int.parse(parts[1]));
      newState[addr] = CellData.fromJson(value);
    });
    state = newState;
  }

  List<CellAddress> search(String query) {
    final results = <CellAddress>[];
    if (query.isEmpty) return results;

    final lowerQuery = query.toLowerCase();
    state.forEach((addr, data) {
      if (data.value.toLowerCase().contains(lowerQuery) ||
          (data.formula?.toLowerCase().contains(lowerQuery) ?? false)) {
        results.add(addr);
      }
    });

    return results;
  }

  void replaceAll(String find, String replace) {
    final newState = Map<CellAddress, CellData>.from(state);
    newState.forEach((addr, data) {
      if (data.value.contains(find)) {
        newState[addr] = data.copyWith(
          value: data.value.replaceAll(find, replace),
        );
      }
    });
    state = newState;
  }

  void _recalculateFormulas() {
    final newState = Map<CellAddress, CellData>.from(state);
    bool hasChanges = true;
    int maxIterations = 10;
    int iteration = 0;

    while (hasChanges && iteration < maxIterations) {
      hasChanges = false;
      iteration++;

      for (final entry in newState.entries) {
        if (entry.value.formula != null) {
          final result = _evaluateFormula(entry.value.formula!, newState);
          if (result != entry.value.value) {
            newState[entry.key] = entry.value.copyWith(value: result);
            hasChanges = true;
          }
        }
      }
    }
    state = newState;
  }

  String _evaluateFormula(String formula, Map<CellAddress, CellData> data) {
    try {
      final expr = formula.substring(1).toUpperCase().trim();

      // Handle IF function
      if (expr.startsWith('IF(')) {
        return _evaluateIf(expr, data);
      }

      // Handle SUMIF function
      if (expr.startsWith('SUMIF(')) {
        return _evaluateSumIf(expr, data);
      }

      // Handle COUNTIF function
      if (expr.startsWith('COUNTIF(')) {
        return _evaluateCountIf(expr, data);
      }

      // Handle VLOOKUP function
      if (expr.startsWith('VLOOKUP(')) {
        return _evaluateVLookup(expr, data);
      }

      // Handle SUM function
      if (expr.startsWith('SUM(') && expr.endsWith(')')) {
        final range = expr.substring(4, expr.length - 1);
        return _calculateSum(range, data).toStringAsFixed(2);
      }

      // Handle AVG/AVERAGE function
      if ((expr.startsWith('AVG(') || expr.startsWith('AVERAGE(')) &&
          expr.endsWith(')')) {
        final start = expr.indexOf('(') + 1;
        final range = expr.substring(start, expr.length - 1);
        return _calculateAverage(range, data).toStringAsFixed(2);
      }

      // Handle COUNT function
      if (expr.startsWith('COUNT(') && expr.endsWith(')')) {
        final range = expr.substring(6, expr.length - 1);
        return _calculateCount(range, data).toString();
      }

      // Handle MIN function
      if (expr.startsWith('MIN(') && expr.endsWith(')')) {
        final range = expr.substring(4, expr.length - 1);
        return _calculateMin(range, data).toStringAsFixed(2);
      }

      // Handle MAX function
      if (expr.startsWith('MAX(') && expr.endsWith(')')) {
        final range = expr.substring(4, expr.length - 1);
        return _calculateMax(range, data).toStringAsFixed(2);
      }

      // Handle CONCAT/CONCATENATE function
      if ((expr.startsWith('CONCAT(') || expr.startsWith('CONCATENATE(')) &&
          expr.endsWith(')')) {
        final start = expr.indexOf('(') + 1;
        final range = expr.substring(start, expr.length - 1);
        return _calculateConcat(range, data);
      }

      // Handle LEN function
      if (expr.startsWith('LEN(') && expr.endsWith(')')) {
        final ref = expr.substring(4, expr.length - 1).trim();
        final addr = _parseCellAddress(ref);
        return (data[addr]?.value.length ?? 0).toString();
      }

      // Handle UPPER function
      if (expr.startsWith('UPPER(') && expr.endsWith(')')) {
        final ref = expr.substring(6, expr.length - 1).trim();
        final addr = _parseCellAddress(ref);
        return (data[addr]?.value ?? '').toUpperCase();
      }

      // Handle LOWER function
      if (expr.startsWith('LOWER(') && expr.endsWith(')')) {
        final ref = expr.substring(6, expr.length - 1).trim();
        final addr = _parseCellAddress(ref);
        return (data[addr]?.value ?? '').toLowerCase();
      }

      // Handle simple cell reference
      if (RegExp(r'^[A-Z]+[0-9]+$').hasMatch(expr)) {
        final addr = _parseCellAddress(expr);
        final cellData = data[addr];
        if (cellData != null) {
          return cellData.value;
        }
      }

      // Handle basic arithmetic
      return _evaluateArithmetic(expr, data);
    } catch (e) {
      return '#ERROR';
    }
  }

  String _evaluateIf(String expr, Map<CellAddress, CellData> data) {
    try {
      final content = expr.substring(3, expr.length - 1);
      final parts = _splitFunctionArgs(content);

      if (parts.length != 3) return '#ERROR';

      final condition = _evaluateCondition(parts[0], data);
      return condition
          ? _evaluateExpression(parts[1], data)
          : _evaluateExpression(parts[2], data);
    } catch (e) {
      return '#ERROR';
    }
  }

  String _evaluateSumIf(String expr, Map<CellAddress, CellData> data) {
    try {
      final content = expr.substring(6, expr.length - 1);
      final parts = _splitFunctionArgs(content);

      if (parts.length < 2) return '#ERROR';

      final range = _parseRange(parts[0]);
      final criteria = parts[1].replaceAll('"', '');
      final sumRange = parts.length > 2 ? _parseRange(parts[2]) : range;

      double sum = 0;
      for (int i = 0; i < range.length; i++) {
        final criteriaCell = data[range[i]];
        if (criteriaCell != null && criteriaCell.value == criteria) {
          final sumCell = data[sumRange[i]];
          if (sumCell != null) {
            sum += double.tryParse(sumCell.value) ?? 0;
          }
        }
      }

      return sum.toStringAsFixed(2);
    } catch (e) {
      return '#ERROR';
    }
  }

  String _evaluateCountIf(String expr, Map<CellAddress, CellData> data) {
    try {
      final content = expr.substring(8, expr.length - 1);
      final parts = _splitFunctionArgs(content);

      if (parts.length != 2) return '#ERROR';

      final range = _parseRange(parts[0]);
      final criteria = parts[1].replaceAll('"', '');

      int count = 0;
      for (final addr in range) {
        final cell = data[addr];
        if (cell != null && cell.value == criteria) {
          count++;
        }
      }

      return count.toString();
    } catch (e) {
      return '#ERROR';
    }
  }

  String _evaluateVLookup(String expr, Map<CellAddress, CellData> data) {
    try {
      final content = expr.substring(8, expr.length - 1);
      final parts = _splitFunctionArgs(content);

      if (parts.length < 3) return '#ERROR';

      final searchValue = _evaluateExpression(parts[0], data);
      final tableRange = _parseRange(parts[1]);
      final colIndex = int.parse(parts[2]) - 1;

      // Group by rows
      final Map<int, List<CellAddress>> rows = {};
      for (final addr in tableRange) {
        rows.putIfAbsent(addr.row, () => []).add(addr);
      }

      // Search for value in first column
      for (final row in rows.values) {
        if (row.isEmpty) continue;
        row.sort((a, b) => a.col.compareTo(b.col));

        final firstCell = data[row[0]];
        if (firstCell?.value == searchValue) {
          if (colIndex < row.length) {
            return data[row[colIndex]]?.value ?? '#N/A';
          }
        }
      }

      return '#N/A';
    } catch (e) {
      return '#ERROR';
    }
  }

  bool _evaluateCondition(String condition, Map<CellAddress, CellData> data) {
    condition = condition.trim();

    for (final op in ['>=', '<=', '>', '<', '=', '!=', '<>']) {
      if (condition.contains(op)) {
        final parts = condition.split(op);
        if (parts.length == 2) {
          final leftStr = _evaluateExpression(parts[0], data);
          final rightStr = _evaluateExpression(parts[1], data);

          final left = double.tryParse(leftStr) ?? 0;
          final right = double.tryParse(rightStr) ?? 0;

          switch (op) {
            case '>=':
              return left >= right;
            case '<=':
              return left <= right;
            case '>':
              return left > right;
            case '<':
              return left < right;
            case '=':
              return leftStr == rightStr;
            case '!=':
            case '<>':
              return leftStr != rightStr;
          }
        }
      }
    }
    return false;
  }

  String _evaluateExpression(String expr, Map<CellAddress, CellData> data) {
    expr = expr.trim();

    // Remove quotes if present
    if (expr.startsWith('"') && expr.endsWith('"')) {
      return expr.substring(1, expr.length - 1);
    }

    // Try to evaluate as cell reference
    if (RegExp(r'''^[A-Z]+[0-9]+''').hasMatch(expr)) {
      final addr = _parseCellAddress(expr);
      return data[addr]?.value ?? '';
    }

    // Return as is
    return expr;
  }

  List<String> _splitFunctionArgs(String content) {
    final args = <String>[];
    int parenDepth = 0;
    int quoteDepth = 0;
    String current = '';

    for (int i = 0; i < content.length; i++) {
      final char = content[i];

      if (char == '"') {
        quoteDepth = quoteDepth == 0 ? 1 : 0;
        current += char;
      } else if (char == '(' && quoteDepth == 0) {
        parenDepth++;
        current += char;
      } else if (char == ')' && quoteDepth == 0) {
        parenDepth--;
        current += char;
      } else if (char == ',' && parenDepth == 0 && quoteDepth == 0) {
        args.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }

    if (current.isNotEmpty) {
      args.add(current.trim());
    }

    return args;
  }

  double _calculateSum(String range, Map<CellAddress, CellData> data) {
    final cells = _parseRange(range);
    double sum = 0;
    for (final cell in cells) {
      final cellData = data[cell];
      if (cellData != null) {
        sum += double.tryParse(cellData.value) ?? 0;
      }
    }
    return sum;
  }

  double _calculateAverage(String range, Map<CellAddress, CellData> data) {
    final cells = _parseRange(range);
    if (cells.isEmpty) return 0;
    return _calculateSum(range, data) / cells.length;
  }

  int _calculateCount(String range, Map<CellAddress, CellData> data) {
    final cells = _parseRange(range);
    int count = 0;
    for (final cell in cells) {
      final cellData = data[cell];
      if (cellData != null && cellData.value.isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  double _calculateMin(String range, Map<CellAddress, CellData> data) {
    final cells = _parseRange(range);
    double? min;
    for (final cell in cells) {
      final cellData = data[cell];
      if (cellData != null) {
        final value = double.tryParse(cellData.value);
        if (value != null) {
          min = min == null ? value : math.min(min, value);
        }
      }
    }
    return min ?? 0;
  }

  double _calculateMax(String range, Map<CellAddress, CellData> data) {
    final cells = _parseRange(range);
    double? max;
    for (final cell in cells) {
      final cellData = data[cell];
      if (cellData != null) {
        final value = double.tryParse(cellData.value);
        if (value != null) {
          max = max == null ? value : math.max(max, value);
        }
      }
    }
    return max ?? 0;
  }

  String _calculateConcat(String range, Map<CellAddress, CellData> data) {
    final parts = range.split(',');
    final result = StringBuffer();
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
        result.write(trimmed.substring(1, trimmed.length - 1));
      } else {
        final cells = _parseRange(trimmed);
        for (final cell in cells) {
          final cellData = data[cell];
          if (cellData != null) {
            result.write(cellData.value);
          }
        }
      }
    }
    return result.toString();
  }

  List<CellAddress> _parseRange(String range) {
    final parts = range.split(':');
    if (parts.length == 2) {
      final start = _parseCellAddress(parts[0].trim());
      final end = _parseCellAddress(parts[1].trim());
      final cells = <CellAddress>[];
      for (int r = start.row; r <= end.row; r++) {
        for (int c = start.col; c <= end.col; c++) {
          cells.add(CellAddress(r, c));
        }
      }
      return cells;
    } else {
      return [_parseCellAddress(range.trim())];
    }
  }

  CellAddress _parseCellAddress(String ref) {
    final match = RegExp(r'''^([A-Z]+)([0-9]+)''').firstMatch(ref);
    if (match != null) {
      final colStr = match.group(1)!;
      int col = 0;
      for (int i = 0; i < colStr.length; i++) {
        col = col * 26 + (colStr.codeUnitAt(i) - 65 + 1);
      }
      col--;
      final row = int.parse(match.group(2)!) - 1;
      return CellAddress(row, col);
    }
    throw FormatException('Invalid cell reference: $ref');
  }

  String _evaluateArithmetic(String expr, Map<CellAddress, CellData> data) {
    String replaced = expr;
    final cellRefs = RegExp(r'[A-Z]+[0-9]+').allMatches(expr);
    for (final match in cellRefs) {
      final ref = match.group(0)!;
      final addr = _parseCellAddress(ref);
      final value = data[addr]?.value ?? '0';
      replaced = replaced.replaceAll(ref, value);
    }

    replaced = replaced.replaceAll(' ', '');
    try {
      return _evalExpression(replaced).toStringAsFixed(2);
    } catch (e) {
      return '#ERROR';
    }
  }

  double _evalExpression(String expr) {
    final tokens = <String>[];
    String current = '';
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if ('+-*/()'.contains(ch)) {
        if (current.isNotEmpty) tokens.add(current);
        tokens.add(ch);
        current = '';
      } else {
        current += ch;
      }
    }
    if (current.isNotEmpty) tokens.add(current);

    return _evaluateTokens(tokens);
  }

  double _evaluateTokens(List<String> tokens) {
    // Handle parentheses first
    while (tokens.contains('(')) {
      final openIdx = tokens.lastIndexOf('(');
      int closeIdx = -1;
      for (int i = openIdx + 1; i < tokens.length; i++) {
        if (tokens[i] == ')') {
          closeIdx = i;
          break;
        }
      }
      if (closeIdx == -1) throw FormatException('Mismatched parentheses');

      final subExpr = tokens.sublist(openIdx + 1, closeIdx);
      final result = _evaluateTokens(subExpr);
      tokens.replaceRange(openIdx, closeIdx + 1, [result.toString()]);
    }

    // Handle multiplication and division
    for (int i = 1; i < tokens.length - 1; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(tokens[i - 1]);
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        tokens[i - 1] = result.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i--;
      }
    }

    // Handle addition and subtraction
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length - 1; i += 2) {
      final op = tokens[i];
      final value = double.parse(tokens[i + 1]);
      if (op == '+') {
        result += value;
      } else if (op == '-') {
        result -= value;
      }
    }

    return result;
  }

  /// Insert a new row at the specified index
  void insertRow(int rowIndex) {
    final newState = <CellAddress, CellData>{};

    state.forEach((addr, data) {
      if (addr.row < rowIndex) {
        // Keep cells above the insertion point
        newState[addr] = data;
      } else {
        // Shift cells down
        newState[CellAddress(addr.row + 1, addr.col)] = data;
      }
    });

    state = newState;
    _recalculateFormulas();
  }

  /// Delete a row at the specified index
  void deleteRow(int rowIndex) {
    final newState = <CellAddress, CellData>{};

    state.forEach((addr, data) {
      if (addr.row < rowIndex) {
        // Keep cells above the deletion point
        newState[addr] = data;
      } else if (addr.row > rowIndex) {
        // Shift cells up
        newState[CellAddress(addr.row - 1, addr.col)] = data;
      }
      // Cells in the deleted row are automatically removed
    });

    state = newState;
    _recalculateFormulas();
  }

  /// Insert a new column at the specified index
  void insertColumn(int colIndex) {
    final newState = <CellAddress, CellData>{};

    state.forEach((addr, data) {
      if (addr.col < colIndex) {
        // Keep cells to the left of the insertion point
        newState[addr] = data;
      } else {
        // Shift cells right
        newState[CellAddress(addr.row, addr.col + 1)] = data;
      }
    });

    state = newState;
    _recalculateFormulas();
  }

  /// Delete a column at the specified index
  void deleteColumn(int colIndex) {
    final newState = <CellAddress, CellData>{};

    state.forEach((addr, data) {
      if (addr.col < colIndex) {
        // Keep cells to the left of the deletion point
        newState[addr] = data;
      } else if (addr.col > colIndex) {
        // Shift cells left
        newState[CellAddress(addr.row, addr.col - 1)] = data;
      }
      // Cells in the deleted column are automatically removed
    });

    state = newState;
    _recalculateFormulas();
  }

  /// Insert multiple rows starting at rowIndex
  void insertRows(int rowIndex, int count) {
    for (int i = 0; i < count; i++) {
      insertRow(rowIndex + i);
    }
  }

  /// Insert multiple columns starting at colIndex
  void insertColumns(int colIndex, int count) {
    for (int i = 0; i < count; i++) {
      insertColumn(colIndex + i);
    }
  }

  /// Delete multiple rows starting from startRow to endRow
  void deleteRows(int startRow, int endRow) {
    for (int i = endRow; i >= startRow; i--) {
      deleteRow(i);
    }
  }

  /// Delete multiple columns starting from startCol to endCol
  void deleteColumns(int startCol, int endCol) {
    for (int i = endCol; i >= startCol; i--) {
      deleteColumn(i);
    }
  }

  /// Move a row from source index to destination index
  void moveRow(int sourceRow, int destRow) {
    if (sourceRow == destRow) return;

    final tempState = <CellAddress, CellData>{};
    final cellsToMove = <CellAddress, CellData>{};

    // Separate cells to move and other cells
    state.forEach((addr, data) {
      if (addr.row == sourceRow) {
        cellsToMove[CellAddress(destRow, addr.col)] = data;
      } else {
        tempState[addr] = data;
      }
    });

    // Adjust other cells based on the move direction
    final newState = <CellAddress, CellData>{};
    tempState.forEach((addr, data) {
      if (sourceRow < destRow) {
        // Moving down
        if (addr.row > sourceRow && addr.row <= destRow) {
          newState[CellAddress(addr.row - 1, addr.col)] = data;
        } else {
          newState[addr] = data;
        }
      } else {
        // Moving up
        if (addr.row >= destRow && addr.row < sourceRow) {
          newState[CellAddress(addr.row + 1, addr.col)] = data;
        } else {
          newState[addr] = data;
        }
      }
    });

    // Add the moved cells
    newState.addAll(cellsToMove);
    state = newState;
    _recalculateFormulas();
  }

  /// Move a column from source index to destination index
  void moveColumn(int sourceCol, int destCol) {
    if (sourceCol == destCol) return;

    final tempState = <CellAddress, CellData>{};
    final cellsToMove = <CellAddress, CellData>{};

    // Separate cells to move and other cells
    state.forEach((addr, data) {
      if (addr.col == sourceCol) {
        cellsToMove[CellAddress(addr.row, destCol)] = data;
      } else {
        tempState[addr] = data;
      }
    });

    // Adjust other cells based on the move direction
    final newState = <CellAddress, CellData>{};
    tempState.forEach((addr, data) {
      if (sourceCol < destCol) {
        // Moving right
        if (addr.col > sourceCol && addr.col <= destCol) {
          newState[CellAddress(addr.row, addr.col - 1)] = data;
        } else {
          newState[addr] = data;
        }
      } else {
        // Moving left
        if (addr.col >= destCol && addr.col < sourceCol) {
          newState[CellAddress(addr.row, addr.col + 1)] = data;
        } else {
          newState[addr] = data;
        }
      }
    });

    // Add the moved cells
    newState.addAll(cellsToMove);
    state = newState;
    _recalculateFormulas();
  }

  /// Hide a row
  void hideRow(int rowIndex, Ref ref) {
    final rowConfig = Map<int, RowConfig>.from(ref.read(rowConfigProvider));
    final existingConfig = rowConfig[rowIndex];
    rowConfig[rowIndex] = (existingConfig ?? RowConfig(index: rowIndex))
        .copyWith(hidden: true);
    ref.read(rowConfigProvider.notifier).state = rowConfig;
  }

  /// Show a hidden row
  void showRow(int rowIndex, Ref ref) {
    final rowConfig = Map<int, RowConfig>.from(ref.read(rowConfigProvider));
    final existingConfig = rowConfig[rowIndex];
    rowConfig[rowIndex] = (existingConfig ?? RowConfig(index: rowIndex))
        .copyWith(hidden: false);
    ref.read(rowConfigProvider.notifier).state = rowConfig;
  }

  /// Hide a column
  void hideColumn(int colIndex, Ref ref) {
    final colConfig = Map<int, ColumnConfig>.from(
      ref.read(columnConfigProvider),
    );
    final existingConfig = colConfig[colIndex];
    colConfig[colIndex] = (existingConfig ?? ColumnConfig(index: colIndex))
        .copyWith(hidden: true);
    ref.read(columnConfigProvider.notifier).state = colConfig;
  }

  /// Show a hidden column
  void showColumn(int colIndex, Ref ref) {
    final colConfig = Map<int, ColumnConfig>.from(
      ref.read(columnConfigProvider),
    );
    final existingConfig = colConfig[colIndex];
    colConfig[colIndex] = (existingConfig ?? ColumnConfig(index: colIndex))
        .copyWith(hidden: false);
    ref.read(columnConfigProvider.notifier).state = colConfig;
  }

  /// Set column width
  void setColumnWidth(int colIndex, double width, Ref ref) {
    final colConfig = Map<int, ColumnConfig>.from(
      ref.read(columnConfigProvider),
    );
    final existingConfig = colConfig[colIndex];
    colConfig[colIndex] = (existingConfig ?? ColumnConfig(index: colIndex))
        .copyWith(width: width);
    ref.read(columnConfigProvider.notifier).state = colConfig;
  }

  /// Set row height
  void setRowHeight(int rowIndex, double height, Ref ref) {
    final rowConfig = Map<int, RowConfig>.from(ref.read(rowConfigProvider));
    final existingConfig = rowConfig[rowIndex];
    rowConfig[rowIndex] = (existingConfig ?? RowConfig(index: rowIndex))
        .copyWith(height: height);
    ref.read(rowConfigProvider.notifier).state = rowConfig;
  }

  /// Toggle row visibility
  void toggleRowVisibility(int rowIndex, Ref ref) {
    final rowConfig = Map<int, RowConfig>.from(ref.read(rowConfigProvider));
    final existingConfig = rowConfig[rowIndex];
    final isCurrentlyHidden = existingConfig?.hidden ?? false;
    rowConfig[rowIndex] = (existingConfig ?? RowConfig(index: rowIndex))
        .copyWith(hidden: !isCurrentlyHidden);
    ref.read(rowConfigProvider.notifier).state = rowConfig;
  }

  /// Toggle column visibility
  void toggleColumnVisibility(int colIndex, Ref ref) {
    final colConfig = Map<int, ColumnConfig>.from(
      ref.read(columnConfigProvider),
    );
    final existingConfig = colConfig[colIndex];
    final isCurrentlyHidden = existingConfig?.hidden ?? false;
    colConfig[colIndex] = (existingConfig ?? ColumnConfig(index: colIndex))
        .copyWith(hidden: !isCurrentlyHidden);
    ref.read(columnConfigProvider.notifier).state = colConfig;
  }

  /// Reset row to default settings
  void resetRow(int rowIndex, Ref ref) {
    final rowConfig = Map<int, RowConfig>.from(ref.read(rowConfigProvider));
    rowConfig.remove(rowIndex); // Remove custom config to use defaults
    ref.read(rowConfigProvider.notifier).state = rowConfig;
  }

  /// Reset column to default settings
  void resetColumn(int colIndex, Ref ref) {
    final colConfig = Map<int, ColumnConfig>.from(
      ref.read(columnConfigProvider),
    );
    colConfig.remove(colIndex); // Remove custom config to use defaults
    ref.read(columnConfigProvider.notifier).state = colConfig;
  }

  /// Replace the entire state with new data
  void replaceState(Map<CellAddress, CellData> newState) {
    state = newState;
    _recalculateFormulas();
  }

  /// Get row height (returns default if no custom config)
  double getRowHeight(int rowIndex, Ref ref) {
    final rowConfig = ref.read(rowConfigProvider);
    return rowConfig[rowIndex]?.height ?? 40.0;
  }

  /// Get column width (returns default if no custom config)
  double getColumnWidth(int colIndex, Ref ref) {
    final colConfig = ref.read(columnConfigProvider);
    return colConfig[colIndex]?.width ?? 100.0;
  }

  /// Check if row is hidden
  bool isRowHidden(int rowIndex, Ref ref) {
    final rowConfig = ref.read(rowConfigProvider);
    return rowConfig[rowIndex]?.hidden ?? false;
  }

  /// Check if column is hidden
  bool isColumnHidden(int colIndex, Ref ref) {
    final colConfig = ref.read(columnConfigProvider);
    return colConfig[colIndex]?.hidden ?? false;
  }

  /// Auto-fit column width based on content
  void autoFitColumn(int colIndex, Ref ref) {
    final data = state;
    double maxWidth = 80.0; // minimum width

    // Find all cells in this column
    for (final entry in data.entries) {
      if (entry.key.col == colIndex && entry.value.value.isNotEmpty) {
        // Simple heuristic for text width
        final textLength = entry.value.value.length;
        final fontSize = entry.value.style.fontSize;
        final isBold = entry.value.style.bold;

        // More accurate width calculation considering font size and weight
        final estimatedWidth =
            textLength * (fontSize / 2) + (isBold ? 10 : 0) + 20.0;
        if (estimatedWidth > maxWidth) {
          maxWidth = estimatedWidth;
        }
      }
    }

    setColumnWidth(colIndex, maxWidth.clamp(40.0, 500.0), ref);
  }

  /// Auto-fit row height based on content
  void autoFitRow(int rowIndex, Ref ref) {
    final data = state;
    double maxHeight = 24.0; // minimum height

    // Find all cells in this row
    for (final entry in data.entries) {
      if (entry.key.row == rowIndex && entry.value.value.isNotEmpty) {
        // Calculate height based on line count and font size
        final lineCount = entry.value.value.split('\n').length;
        final fontSize = entry.value.style.fontSize;
        final estimatedHeight = lineCount * (fontSize + 8.0);

        if (estimatedHeight > maxHeight) {
          maxHeight = estimatedHeight;
        }
      }
    }

    setRowHeight(rowIndex, maxHeight.clamp(20.0, 200.0), ref);
  }

  /// Sort a range of cells
  void sortRange(CellSelection selection, {bool ascending = true}) {
    if (!selection.isRange()) return;

    final cells = selection.getCells();
    final data = Map<CellAddress, CellData>.from(state);

    // Group by rows to maintain row integrity
    final rows = <int, List<CellAddress>>{};
    for (final addr in cells) {
      rows.putIfAbsent(addr.row, () => []).add(addr);
    }

    // Extract and sort rows based on the first column in selection
    final sortedRows = rows.entries.toList();
    sortedRows.sort((a, b) {
      final aValue = data[a.value.first]?.value ?? '';
      final bValue = data[b.value.first]?.value ?? '';
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    // Reorder the data
    final newData = Map<CellAddress, CellData>.from(data);
    for (int i = 0; i < sortedRows.length; i++) {
      final originalRow = sortedRows[i];
      for (final addr in originalRow.value) {
        final newAddr = CellAddress(selection.start.row + i, addr.col);
        newData[newAddr] = data[addr] ?? CellData();
      }
    }

    state = newData;
    _recalculateFormulas();
  }
}
