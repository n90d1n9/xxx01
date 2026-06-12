import '../../employee/models/employee.dart';

enum PayrollAdjustmentType {
  bonus('Bonus'),
  overtime('Overtime'),
  reimbursement('Reimbursement'),
  deduction('Deduction'),
  correction('Correction');

  final String label;

  const PayrollAdjustmentType(this.label);
}

enum PayrollAdjustmentStatus {
  submitted('Submitted'),
  approved('Approved'),
  rejected('Rejected');

  final String label;

  const PayrollAdjustmentStatus(this.label);
}

class PayrollAdjustmentRequest {
  final String id;
  final int employeeId;
  final String employeeName;
  final String department;
  final PayrollAdjustmentType type;
  final double amount;
  final DateTime effectiveDate;
  final String costCenter;
  final String reason;
  final PayrollAdjustmentStatus status;
  final DateTime submittedAt;

  const PayrollAdjustmentRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.amount,
    required this.effectiveDate,
    required this.costCenter,
    required this.reason,
    required this.status,
    required this.submittedAt,
  });

  bool get isPending => status == PayrollAdjustmentStatus.submitted;

  bool get isApproved => status == PayrollAdjustmentStatus.approved;

  PayrollAdjustmentRequest copyWith({PayrollAdjustmentStatus? status}) {
    return PayrollAdjustmentRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      type: type,
      amount: amount,
      effectiveDate: effectiveDate,
      costCenter: costCenter,
      reason: reason,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

class PayrollAdjustmentDraft {
  final int? employeeId;
  final PayrollAdjustmentType type;
  final String amount;
  final DateTime? effectiveDate;
  final String costCenter;
  final String reason;
  final DateTime asOfDate;

  const PayrollAdjustmentDraft({
    required this.employeeId,
    required this.type,
    required this.amount,
    required this.effectiveDate,
    required this.costCenter,
    required this.reason,
    required this.asOfDate,
  });

  factory PayrollAdjustmentDraft.empty(DateTime asOfDate) {
    return PayrollAdjustmentDraft(
      employeeId: null,
      type: PayrollAdjustmentType.bonus,
      amount: '',
      effectiveDate: null,
      costCenter: '',
      reason: '',
      asOfDate: asOfDate,
    );
  }

  PayrollAdjustmentDraft copyWith({
    int? employeeId,
    PayrollAdjustmentType? type,
    String? amount,
    DateTime? effectiveDate,
    String? costCenter,
    String? reason,
    DateTime? asOfDate,
    bool clearEmployee = false,
    bool clearEffectiveDate = false,
  }) {
    return PayrollAdjustmentDraft(
      employeeId: clearEmployee ? null : employeeId ?? this.employeeId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      effectiveDate:
          clearEffectiveDate ? null : effectiveDate ?? this.effectiveDate,
      costCenter: costCenter ?? this.costCenter,
      reason: reason ?? this.reason,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          employeeId != null,
          validateAmount(amount) == null,
          effectiveDate != null,
          costCenter.trim().isNotEmpty,
          reason.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 5;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateEmployee(employeeId),
      validateAmount(amount),
      validateEffectiveDate(effectiveDate, asOfDate),
      validateRequired(costCenter, 'a cost center'),
      validateReason(reason),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  PayrollAdjustmentRequest toRequest({
    required String id,
    required Employee employee,
    required DateTime submittedAt,
  }) {
    return PayrollAdjustmentRequest(
      id: id,
      employeeId: employee.id,
      employeeName: employee.name,
      department: employee.department ?? 'Payroll',
      type: type,
      amount: double.parse(amount.trim()),
      effectiveDate: effectiveDate!,
      costCenter: costCenter.trim(),
      reason: reason.trim(),
      status: PayrollAdjustmentStatus.submitted,
      submittedAt: submittedAt,
    );
  }

  static String? validateEmployee(int? value) {
    if (value == null) return 'Please select an employee';
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? validateEffectiveDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select an effective date';

    final effective = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (effective.isBefore(today)) {
      return 'Effective date cannot be in the past';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateReason(String? value) {
    final requiredError = validateRequired(value, 'a reason');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Reason must be at least 12 characters';
    }
    return null;
  }
}
