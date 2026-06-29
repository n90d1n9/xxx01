import 'package:csv/csv.dart';

import 'employee_directory_intake_draft.dart';
import 'employee_directory_models.dart';

class EmployeeDirectoryImportRow {
  final int rowNumber;
  final EmployeeDirectoryIntakeDraft draft;
  final List<String> errors;

  const EmployeeDirectoryImportRow({
    required this.rowNumber,
    required this.draft,
    required this.errors,
  });

  bool get isValid => errors.isEmpty && draft.isReadyToCreate;
}

class EmployeeDirectoryImportPreview {
  final String rawCsv;
  final List<String> headerErrors;
  final List<EmployeeDirectoryImportRow> rows;

  const EmployeeDirectoryImportPreview({
    required this.rawCsv,
    required this.headerErrors,
    required this.rows,
  });

  factory EmployeeDirectoryImportPreview.empty() {
    return const EmployeeDirectoryImportPreview(
      rawCsv: '',
      headerErrors: [],
      rows: [],
    );
  }

  factory EmployeeDirectoryImportPreview.fromCsv({
    required String rawCsv,
    required List<EmployeeDirectoryMember> existingMembers,
  }) {
    if (rawCsv.trim().isEmpty) {
      return EmployeeDirectoryImportPreview.empty();
    }

    final table = _parseCsv(rawCsv);
    if (table == null || table.isEmpty) {
      return EmployeeDirectoryImportPreview(
        rawCsv: rawCsv,
        headerErrors: const ['CSV could not be parsed'],
        rows: const [],
      );
    }

    final csvRows = <_CsvRow>[];
    for (var index = 0; index < table.length; index++) {
      final values = table[index];
      if (!_isBlankRow(values)) {
        csvRows.add(_CsvRow(rowNumber: index + 1, values: values));
      }
    }
    if (csvRows.isEmpty) {
      return EmployeeDirectoryImportPreview(
        rawCsv: rawCsv,
        headerErrors: const [],
        rows: const [],
      );
    }

    final header = _headerMap(csvRows.first.values);
    final missingHeaders =
        _requiredHeaders
            .where((headerName) => !header.containsKey(headerName))
            .toList();
    if (missingHeaders.isNotEmpty) {
      return EmployeeDirectoryImportPreview(
        rawCsv: rawCsv,
        headerErrors: [
          'Missing columns: ${missingHeaders.map(_columnLabel).join(', ')}',
        ],
        rows: const [],
      );
    }

    final existingEmails =
        existingMembers
            .map((member) => member.email.trim().toLowerCase())
            .toSet();
    final importEmails = <String>{};
    final rows = <EmployeeDirectoryImportRow>[];

    for (var index = 1; index < csvRows.length; index++) {
      final csvRow = csvRows[index];
      final values = csvRow.values;

      final draft = _draftFor(values: values, header: header);
      final email = draft.email.trim().toLowerCase();
      final errors = <String>[
        ...draft.validationErrors,
        if (email.isNotEmpty && existingEmails.contains(email))
          'Email already exists in directory',
        if (email.isNotEmpty && !importEmails.add(email))
          'Email is duplicated in this import',
      ];

      final rawStatus = _valueFor(values, header, 'status');
      if (rawStatus.trim().isEmpty) {
        errors.add('Please enter a status');
      } else if (_statusFrom(rawStatus) == null) {
        errors.add('Status must be Active, Onboarding, or Watchlist');
      }

      final rawDate = _valueFor(values, header, 'joining_date');
      if (rawDate.trim().isNotEmpty && _dateFrom(rawDate) == null) {
        errors.add('Joining date must be YYYY-MM-DD or DD/MM/YYYY');
      }

      rows.add(
        EmployeeDirectoryImportRow(
          rowNumber: csvRow.rowNumber,
          draft: draft,
          errors: errors.toSet().toList(),
        ),
      );
    }

    return EmployeeDirectoryImportPreview(
      rawCsv: rawCsv,
      headerErrors: const [],
      rows: rows,
    );
  }

  List<EmployeeDirectoryImportRow> get validRows {
    return rows.where((row) => row.isValid).toList();
  }

  List<EmployeeDirectoryImportRow> get errorRows {
    return rows.where((row) => !row.isValid).toList();
  }

  int get totalRows => rows.length;
  int get validCount => validRows.length;
  int get errorCount => errorRows.length + headerErrors.length;
  int get duplicateEmailCount {
    return rows
        .where((row) => row.errors.any((error) => error.contains('Email')))
        .length;
  }

  bool get canImport => headerErrors.isEmpty && validRows.isNotEmpty;
}

class _CsvRow {
  final int rowNumber;
  final List<dynamic> values;

  const _CsvRow({required this.rowNumber, required this.values});
}

const _requiredHeaders = [
  'name',
  'email',
  'phone',
  'position',
  'department',
  'manager',
  'location',
  'joining_date',
  'performance',
  'status',
];

const _headerAliases = {
  'name': ['name', 'employee', 'employee_name', 'employee name'],
  'email': ['email', 'work_email', 'work email'],
  'phone': ['phone', 'phone_number', 'phone number'],
  'position': ['position', 'job_title', 'job title', 'title'],
  'department': ['department', 'team'],
  'manager': ['manager', 'line_manager', 'line manager'],
  'location': ['location', 'work_location', 'work location'],
  'joining_date': ['joining_date', 'join_date', 'joining date', 'join date'],
  'performance': ['performance', 'rating'],
  'status': ['status', 'employee_status', 'employee status'],
};

List<List<dynamic>>? _parseCsv(String rawCsv) {
  try {
    return const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(rawCsv);
  } catch (_) {
    return null;
  }
}

Map<String, int> _headerMap(List<dynamic> row) {
  final header = <String, int>{};
  for (var index = 0; index < row.length; index++) {
    final normalized = _normalize(row[index].toString());
    for (final entry in _headerAliases.entries) {
      if (entry.value.contains(normalized)) {
        header[entry.key] = index;
      }
    }
  }
  return header;
}

EmployeeDirectoryIntakeDraft _draftFor({
  required List<dynamic> values,
  required Map<String, int> header,
}) {
  final rawJoiningDate = _valueFor(values, header, 'joining_date');
  final joiningDate =
      rawJoiningDate.trim().isEmpty ? null : _dateFrom(rawJoiningDate);
  final status =
      _statusFrom(_valueFor(values, header, 'status')) ??
      EmployeeDirectoryStatus.onboarding;

  return EmployeeDirectoryIntakeDraft(
    name: _valueFor(values, header, 'name'),
    position: _valueFor(values, header, 'position'),
    department: _valueFor(values, header, 'department'),
    email: _valueFor(values, header, 'email'),
    phone: _valueFor(values, header, 'phone'),
    joiningDate: joiningDate,
    performance: _valueFor(values, header, 'performance'),
    location: _valueFor(values, header, 'location'),
    manager: _valueFor(values, header, 'manager'),
    status: status,
  );
}

String _valueFor(List<dynamic> row, Map<String, int> header, String key) {
  final index = header[key];
  if (index == null || index >= row.length) return '';
  return row[index].toString().trim();
}

DateTime? _dateFrom(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final isoMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(trimmed);
  if (isoMatch != null) {
    final year = int.tryParse(isoMatch.group(1)!);
    final month = int.tryParse(isoMatch.group(2)!);
    final day = int.tryParse(isoMatch.group(3)!);
    if (year == null || month == null || day == null) return null;
    return _strictDate(year, month, day);
  }

  final parts = trimmed.split(RegExp(r'[-/]'));
  if (parts.length != 3) return null;

  final first = int.tryParse(parts[0]);
  final second = int.tryParse(parts[1]);
  final third = int.tryParse(parts[2]);
  if (first == null || second == null || third == null) return null;

  final year = parts[0].length == 4 ? first : third;
  final month = parts[0].length == 4 ? second : second;
  final day = parts[0].length == 4 ? third : first;

  return _strictDate(year, month, day);
}

DateTime? _strictDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

EmployeeDirectoryStatus? _statusFrom(String value) {
  return switch (_normalize(value)) {
    'active' => EmployeeDirectoryStatus.active,
    'onboarding' => EmployeeDirectoryStatus.onboarding,
    'watchlist' => EmployeeDirectoryStatus.watchlist,
    _ => null,
  };
}

bool _isBlankRow(List<dynamic> row) {
  return row.every((value) => value.toString().trim().isEmpty);
}

String _columnLabel(String key) {
  return key.replaceAll('_', ' ');
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
