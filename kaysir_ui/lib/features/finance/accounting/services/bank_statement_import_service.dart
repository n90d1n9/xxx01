import 'dart:convert';

import 'package:intl/intl.dart';

import '../models/bank_reconciliation.dart';

class BankStatementImportService {
  const BankStatementImportService();

  BankStatementImportResult parseCsv(
    String csv, {
    String importId = 'csv',
    Iterable<BankStatementLine> existingLines = const [],
  }) {
    final records =
        const LineSplitter()
            .convert(csv)
            .indexed
            .map(
              (entry) => _CsvRecord(
                rowNumber: entry.$1 + 1,
                cells: _parseCsvLine(entry.$2),
              ),
            )
            .where(
              (record) => record.cells.any((cell) => cell.trim().isNotEmpty),
            )
            .toList();

    if (records.isEmpty) {
      return const BankStatementImportResult(
        lines: [],
        issues: [
          BankStatementImportIssue(rowNumber: 0, message: 'CSV data is empty'),
        ],
      );
    }

    final headerRecord = records.first;
    final headers = headerRecord.cells.map(_normalizeHeader).toList();
    final dateIndex = _firstHeaderIndex(headers, const {
      'date',
      'transactiondate',
      'valuedate',
      'tanggal',
      'tgl',
    });
    final descriptionIndex = _firstHeaderIndex(headers, const {
      'description',
      'details',
      'detail',
      'narration',
      'keterangan',
      'uraian',
      'memo',
    });
    final referenceIndex = _firstHeaderIndex(headers, const {
      'reference',
      'ref',
      'referensi',
      'noref',
      'noreferensi',
      'transactionid',
      'idtransaksi',
    });
    final amountIndex = _firstHeaderIndex(headers, const {
      'amount',
      'jumlah',
      'mutasi',
      'nominal',
      'nilai',
      'transactionamount',
    });
    final depositIndex = _firstHeaderIndex(headers, const {
      'deposit',
      'credit',
      'kredit',
      'masuk',
      'inflow',
      'receipt',
      'penerimaan',
    });
    final withdrawalIndex = _firstHeaderIndex(headers, const {
      'withdrawal',
      'debit',
      'debet',
      'keluar',
      'outflow',
      'payment',
      'pengeluaran',
    });

    final schemaIssues = <BankStatementImportIssue>[
      if (dateIndex == -1)
        BankStatementImportIssue(
          rowNumber: headerRecord.rowNumber,
          message: 'Missing date column',
        ),
      if (descriptionIndex == -1)
        BankStatementImportIssue(
          rowNumber: headerRecord.rowNumber,
          message: 'Missing description column',
        ),
      if (amountIndex == -1 && depositIndex == -1 && withdrawalIndex == -1)
        BankStatementImportIssue(
          rowNumber: headerRecord.rowNumber,
          message: 'Missing amount or debit/credit columns',
        ),
    ];
    if (schemaIssues.isNotEmpty) {
      return BankStatementImportResult(lines: const [], issues: schemaIssues);
    }

    final lines = <BankStatementLine>[];
    final issues = <BankStatementImportIssue>[];
    final knownLineKeys = existingLines.map(_statementLineKey).toSet();

    for (final record in records.skip(1)) {
      final date = _parseDate(_cellAt(record.cells, dateIndex));
      final description = _cellAt(record.cells, descriptionIndex).trim();
      final amount = _movementAmount(
        record.cells,
        amountIndex: amountIndex,
        depositIndex: depositIndex,
        withdrawalIndex: withdrawalIndex,
      );

      if (date == null) {
        issues.add(
          BankStatementImportIssue(
            rowNumber: record.rowNumber,
            message: 'Invalid date',
          ),
        );
        continue;
      }
      if (description.isEmpty) {
        issues.add(
          BankStatementImportIssue(
            rowNumber: record.rowNumber,
            message: 'Missing description',
          ),
        );
        continue;
      }
      if (amount == null || amount == 0) {
        issues.add(
          BankStatementImportIssue(
            rowNumber: record.rowNumber,
            message: 'Invalid amount',
          ),
        );
        continue;
      }

      final reference = _cellAt(record.cells, referenceIndex).trim();
      final line = BankStatementLine(
        id: 'bank-stmt-$importId-row-${record.rowNumber}',
        date: date,
        description: description,
        amount: amount,
        reference: reference.isEmpty ? null : reference,
      );
      final key = _statementLineKey(line);
      if (knownLineKeys.contains(key)) {
        issues.add(
          BankStatementImportIssue(
            rowNumber: record.rowNumber,
            message: 'Duplicate statement line',
          ),
        );
        continue;
      }

      knownLineKeys.add(key);
      lines.add(line);
    }

    return BankStatementImportResult(lines: lines, issues: issues);
  }

  static List<String> _parseCsvLine(String line) {
    final cells = <String>[];
    var buffer = StringBuffer();
    var quoted = false;

    for (var index = 0; index < line.length; index += 1) {
      final char = line[index];
      if (char == '"') {
        final nextIsQuote = index + 1 < line.length && line[index + 1] == '"';
        if (quoted && nextIsQuote) {
          buffer.write('"');
          index += 1;
        } else {
          quoted = !quoted;
        }
        continue;
      }

      if (char == ',' && !quoted) {
        cells.add(buffer.toString().trim());
        buffer = StringBuffer();
        continue;
      }

      buffer.write(char);
    }

    cells.add(buffer.toString().trim());
    return cells;
  }

  static String _normalizeHeader(String header) {
    return header.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _statementLineKey(BankStatementLine line) {
    final dateKey = DateFormat('yyyy-MM-dd').format(line.date);
    final amountKey = (line.amount * 100).round().toString();
    final referenceOrDescription =
        (line.reference?.trim().isNotEmpty ?? false)
            ? line.reference!
            : line.description;
    final narrativeKey = referenceOrDescription.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return '$dateKey|$amountKey|$narrativeKey';
  }

  static int _firstHeaderIndex(List<String> headers, Set<String> candidates) {
    for (var index = 0; index < headers.length; index += 1) {
      if (candidates.contains(headers[index])) {
        return index;
      }
    }
    return -1;
  }

  static String _cellAt(List<String> cells, int index) {
    if (index < 0 || index >= cells.length) {
      return '';
    }
    return cells[index];
  }

  static DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final isoDate = DateTime.tryParse(trimmed);
    if (isoDate != null) {
      return DateTime(isoDate.year, isoDate.month, isoDate.day);
    }

    for (final format in const [
      'dd/MM/yyyy',
      'd/M/yyyy',
      'dd-MM-yyyy',
      'd-M-yyyy',
      'yyyy/MM/dd',
      'MM/dd/yyyy',
    ]) {
      try {
        final parsed = DateFormat(format).parseStrict(trimmed);
        return DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  static double? _movementAmount(
    List<String> cells, {
    required int amountIndex,
    required int depositIndex,
    required int withdrawalIndex,
  }) {
    final amount = _parseMoney(_cellAt(cells, amountIndex));
    if (amount != null) {
      return amount;
    }

    final deposit = _parseMoney(_cellAt(cells, depositIndex));
    final withdrawal = _parseMoney(_cellAt(cells, withdrawalIndex));
    if (deposit == null && withdrawal == null) {
      return null;
    }

    return (deposit?.abs() ?? 0) - (withdrawal?.abs() ?? 0);
  }

  static double? _parseMoney(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    var negative = false;
    if (normalized.startsWith('(') && normalized.endsWith(')')) {
      negative = true;
      normalized = normalized.substring(1, normalized.length - 1);
    }

    normalized = normalized
        .replaceAll(RegExp(r'\b(idr|rp)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (normalized.contains('-')) {
      negative = true;
      normalized = normalized.replaceAll('-', '');
    }
    if (!RegExp(r'\d').hasMatch(normalized)) {
      return null;
    }

    final lastDot = normalized.lastIndexOf('.');
    final lastComma = normalized.lastIndexOf(',');
    if (lastDot != -1 && lastComma != -1) {
      final decimalSeparator = lastDot > lastComma ? '.' : ',';
      final groupSeparator = decimalSeparator == '.' ? ',' : '.';
      normalized = normalized.replaceAll(groupSeparator, '');
      if (decimalSeparator == ',') {
        normalized = normalized.replaceAll(',', '.');
      }
    } else if (lastComma != -1) {
      normalized = _normalizeSingleSeparator(
        normalized,
        separator: ',',
        decimalSeparator: ',',
      );
    } else if (lastDot != -1) {
      normalized = _normalizeSingleSeparator(
        normalized,
        separator: '.',
        decimalSeparator: '.',
      );
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }
    return negative ? -parsed : parsed;
  }

  static String _normalizeSingleSeparator(
    String value, {
    required String separator,
    required String decimalSeparator,
  }) {
    final lastSeparator = value.lastIndexOf(separator);
    final decimalDigits = value.length - lastSeparator - 1;
    final isDecimal = decimalDigits > 0 && decimalDigits <= 2;
    if (!isDecimal) {
      return value.replaceAll(separator, '');
    }
    if (decimalSeparator == ',') {
      return value.replaceAll('.', '').replaceAll(',', '.');
    }
    return value.replaceAll(',', '');
  }
}

class BankStatementImportResult {
  final List<BankStatementLine> lines;
  final List<BankStatementImportIssue> issues;

  const BankStatementImportResult({required this.lines, required this.issues});

  bool get hasImportableLines => lines.isNotEmpty;

  int get depositCount => lines.where((line) => line.amount >= 0).length;

  int get withdrawalCount => lines.where((line) => line.amount < 0).length;

  double get netMovement {
    return lines.fold(0.0, (sum, line) => sum + line.amount);
  }
}

class BankStatementImportIssue {
  final int rowNumber;
  final String message;

  const BankStatementImportIssue({
    required this.rowNumber,
    required this.message,
  });
}

class _CsvRecord {
  final int rowNumber;
  final List<String> cells;

  const _CsvRecord({required this.rowNumber, required this.cells});
}
