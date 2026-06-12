import '../../employee/models/employee.dart';
import 'payroll_input_change_models.dart';

enum PayrollDataImportType {
  salaryChange('Salary changes', PayrollInputChangeType.salaryChange),
  bonus('Bonuses', PayrollInputChangeType.bonus),
  deduction('Deductions', PayrollInputChangeType.unpaidLeave),
  reimbursement('Reimbursements', PayrollInputChangeType.retroAdjustment);

  final String label;
  final PayrollInputChangeType inputChangeType;

  const PayrollDataImportType(this.label, this.inputChangeType);
}

class PayrollDataImportDraft {
  final PayrollDataImportType type;
  final String sourceLabel;
  final String csvText;
  final DateTime asOfDate;

  const PayrollDataImportDraft({
    required this.type,
    required this.sourceLabel,
    required this.csvText,
    required this.asOfDate,
  });

  factory PayrollDataImportDraft.empty(DateTime asOfDate) {
    return PayrollDataImportDraft(
      type: PayrollDataImportType.salaryChange,
      sourceLabel: 'Monthly payroll import',
      csvText: 'employee_id,amount,effective_date,reason,current_amount\n',
      asOfDate: asOfDate,
    );
  }

  PayrollDataImportDraft copyWith({
    PayrollDataImportType? type,
    String? sourceLabel,
    String? csvText,
    DateTime? asOfDate,
  }) {
    return PayrollDataImportDraft(
      type: type ?? this.type,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      csvText: csvText ?? this.csvText,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  bool get hasPayload {
    return csvText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .length >
        1;
  }
}

class PayrollDataImportLine {
  final int rowNumber;
  final int? employeeId;
  final Employee? employee;
  final double? amount;
  final double? currentAmount;
  final DateTime? effectiveDate;
  final String reason;
  final List<String> errors;

  const PayrollDataImportLine({
    required this.rowNumber,
    required this.employeeId,
    required this.employee,
    required this.amount,
    required this.currentAmount,
    required this.effectiveDate,
    required this.reason,
    required this.errors,
  });

  bool get isValid => errors.isEmpty;

  String get employeeName => employee?.name ?? 'Unknown employee';

  double get requestedAmount => amount ?? 0;
}

class PayrollDataImportBatch {
  final String id;
  final PayrollDataImportType type;
  final String sourceLabel;
  final DateTime importedAt;
  final List<PayrollDataImportLine> lines;

  const PayrollDataImportBatch({
    required this.id,
    required this.type,
    required this.sourceLabel,
    required this.importedAt,
    required this.lines,
  });

  int get validCount => lines.where((line) => line.isValid).length;

  int get errorCount => lines.length - validCount;

  double get totalAmount {
    return lines
        .where((line) => line.isValid)
        .fold(0, (total, line) => total + line.requestedAmount);
  }

  List<PayrollInputChangeRequest> toInputChanges() {
    return lines.where((line) => line.isValid).map((line) {
      final current =
          type == PayrollDataImportType.salaryChange
              ? line.currentAmount ?? line.employee?.salary ?? 0
              : 0.0;
      return PayrollInputChangeRequest(
        id: '$id-${line.rowNumber}',
        employeeId: line.employeeId!,
        type: type.inputChangeType,
        currentAmount: current,
        proposedAmount: line.requestedAmount,
        effectiveDate: line.effectiveDate!,
        sourceLabel: sourceLabel,
        reason: line.reason,
        hasApprovalOwner: true,
        hasSupportingDocument: true,
      );
    }).toList();
  }
}

class PayrollDataImportPreview {
  final PayrollDataImportDraft draft;
  final List<PayrollDataImportLine> lines;

  const PayrollDataImportPreview({required this.draft, required this.lines});

  factory PayrollDataImportPreview.fromDraft({
    required PayrollDataImportDraft draft,
    required List<Employee> employees,
  }) {
    final rows =
        draft.csvText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
    if (rows.isEmpty) {
      return PayrollDataImportPreview(draft: draft, lines: const []);
    }

    final header = _splitCsvLine(rows.first).map(_normalizeHeader).toList();
    final lines = <PayrollDataImportLine>[];
    for (var index = 1; index < rows.length; index++) {
      final values = _splitCsvLine(rows[index]);
      final row = <String, String>{};
      for (var column = 0; column < header.length; column++) {
        row[header[column]] =
            column < values.length ? values[column].trim() : '';
      }
      lines.add(
        _lineFromRow(
          rowNumber: index + 1,
          row: row,
          draft: draft,
          employees: employees,
          header: header,
        ),
      );
    }

    return PayrollDataImportPreview(draft: draft, lines: lines);
  }

  int get validCount => lines.where((line) => line.isValid).length;

  int get errorCount => lines.length - validCount;

  double get totalAmount {
    return lines
        .where((line) => line.isValid)
        .fold(0, (total, line) => total + line.requestedAmount);
  }

  bool get canImport => draft.hasPayload && validCount > 0 && errorCount == 0;

  String get nextAction {
    if (!draft.hasPayload) return 'Paste payroll import rows to preview.';
    if (errorCount > 0) return 'Fix $errorCount import row errors.';
    if (validCount > 0) return 'Import $validCount validated payroll rows.';
    return 'No importable payroll rows found.';
  }

  PayrollDataImportBatch toBatch({required String id}) {
    return PayrollDataImportBatch(
      id: id,
      type: draft.type,
      sourceLabel: draft.sourceLabel.trim(),
      importedAt: draft.asOfDate,
      lines: lines,
    );
  }
}

PayrollDataImportLine _lineFromRow({
  required int rowNumber,
  required Map<String, String> row,
  required PayrollDataImportDraft draft,
  required List<Employee> employees,
  required List<String> header,
}) {
  final errors = <String>[];
  for (final requiredColumn in ['employee_id', 'amount', 'effective_date']) {
    if (!header.contains(requiredColumn)) {
      errors.add('Missing $requiredColumn column');
    }
  }

  final employeeId = int.tryParse(row['employee_id'] ?? '');
  final employee = _findEmployee(employees, employeeId);
  final amount = double.tryParse(row['amount'] ?? '');
  final currentAmount = double.tryParse(row['current_amount'] ?? '');
  final effectiveDate = DateTime.tryParse(row['effective_date'] ?? '');
  final reason = (row['reason'] ?? '').trim();

  if (employeeId == null) errors.add('Employee id is invalid');
  if (employeeId != null && employee == null) {
    errors.add('Employee $employeeId is unavailable');
  }
  if (amount == null || amount <= 0) {
    errors.add('Amount must be greater than 0');
  }
  if (effectiveDate == null) {
    errors.add('Effective date is invalid');
  } else if (_isBeforeAsOfDate(effectiveDate, draft.asOfDate)) {
    errors.add('Effective date is before payroll period');
  }
  if (draft.type == PayrollDataImportType.salaryChange &&
      currentAmount != null &&
      amount != null &&
      currentAmount == amount) {
    errors.add('Salary change amount matches current amount');
  }
  if (reason.length < 8) errors.add('Reason must be at least 8 chars');

  return PayrollDataImportLine(
    rowNumber: rowNumber,
    employeeId: employeeId,
    employee: employee,
    amount: amount,
    currentAmount: currentAmount,
    effectiveDate: effectiveDate,
    reason: reason,
    errors: errors,
  );
}

List<String> _splitCsvLine(String line) {
  final values = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (char == '"') {
      quoted = !quoted;
      continue;
    }
    if (char == ',' && !quoted) {
      values.add(buffer.toString());
      buffer.clear();
      continue;
    }
    buffer.write(char);
  }
  values.add(buffer.toString());
  return values;
}

String _normalizeHeader(String value) {
  return value.trim().toLowerCase().replaceAll(' ', '_');
}

bool _isBeforeAsOfDate(DateTime value, DateTime comparison) {
  final effective = DateTime(value.year, value.month, value.day);
  final asOf = DateTime(comparison.year, comparison.month, comparison.day);
  return effective.isBefore(asOf);
}

Employee? _findEmployee(List<Employee> employees, int? employeeId) {
  for (final employee in employees) {
    if (employee.id == employeeId) return employee;
  }
  return null;
}
