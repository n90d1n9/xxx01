import '../../employee/models/employee.dart';

enum PayrollOffCycleRunType {
  correction('Correction'),
  termination('Termination payout'),
  bonus('Spot bonus'),
  reimbursement('Reimbursement'),
  retroPay('Retro pay');

  final String label;

  const PayrollOffCycleRunType(this.label);
}

enum PayrollOffCycleRunStatus {
  submitted('Submitted'),
  approved('Approved'),
  rejected('Rejected'),
  released('Released');

  final String label;

  const PayrollOffCycleRunStatus(this.label);
}

class PayrollOffCycleRunRequest {
  final String id;
  final int employeeId;
  final String employeeName;
  final String department;
  final PayrollOffCycleRunType type;
  final double grossAmount;
  final DateTime payDate;
  final String reason;
  final String evidenceReference;
  final bool grossUp;
  final PayrollOffCycleRunStatus status;
  final DateTime submittedAt;

  const PayrollOffCycleRunRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.grossAmount,
    required this.payDate,
    required this.reason,
    required this.evidenceReference,
    required this.grossUp,
    required this.status,
    required this.submittedAt,
  });

  bool get isSubmitted => status == PayrollOffCycleRunStatus.submitted;

  bool get isApproved => status == PayrollOffCycleRunStatus.approved;

  bool get isReleased => status == PayrollOffCycleRunStatus.released;

  double get taxAmount {
    if (type == PayrollOffCycleRunType.reimbursement) return 0;
    final rate = grossUp ? 0.32 : 0.22;
    return grossAmount * rate;
  }

  double get netAmount {
    if (grossUp) return grossAmount;
    return grossAmount - taxAmount;
  }

  PayrollOffCycleRunRequest copyWith({PayrollOffCycleRunStatus? status}) {
    return PayrollOffCycleRunRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      type: type,
      grossAmount: grossAmount,
      payDate: payDate,
      reason: reason,
      evidenceReference: evidenceReference,
      grossUp: grossUp,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

class PayrollOffCycleRunDraft {
  final int? employeeId;
  final PayrollOffCycleRunType type;
  final String grossAmount;
  final DateTime? payDate;
  final String reason;
  final String evidenceReference;
  final bool grossUp;
  final DateTime asOfDate;

  const PayrollOffCycleRunDraft({
    required this.employeeId,
    required this.type,
    required this.grossAmount,
    required this.payDate,
    required this.reason,
    required this.evidenceReference,
    required this.grossUp,
    required this.asOfDate,
  });

  factory PayrollOffCycleRunDraft.empty(DateTime asOfDate) {
    return PayrollOffCycleRunDraft(
      employeeId: null,
      type: PayrollOffCycleRunType.correction,
      grossAmount: '',
      payDate: null,
      reason: '',
      evidenceReference: '',
      grossUp: false,
      asOfDate: asOfDate,
    );
  }

  PayrollOffCycleRunDraft copyWith({
    int? employeeId,
    PayrollOffCycleRunType? type,
    String? grossAmount,
    DateTime? payDate,
    String? reason,
    String? evidenceReference,
    bool? grossUp,
    DateTime? asOfDate,
    bool clearEmployee = false,
    bool clearPayDate = false,
  }) {
    return PayrollOffCycleRunDraft(
      employeeId: clearEmployee ? null : employeeId ?? this.employeeId,
      type: type ?? this.type,
      grossAmount: grossAmount ?? this.grossAmount,
      payDate: clearPayDate ? null : payDate ?? this.payDate,
      reason: reason ?? this.reason,
      evidenceReference: evidenceReference ?? this.evidenceReference,
      grossUp: grossUp ?? this.grossUp,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          employeeId != null,
          validateGrossAmount(grossAmount) == null,
          payDate != null,
          validateReason(reason) == null,
          validateEvidenceReference(evidenceReference) == null,
        ].where((item) => item).length;
    return completed / 5;
  }

  List<String> get validationErrors {
    final errors = <String>[
      if (employeeId == null) 'Select an employee',
      if (validateGrossAmount(grossAmount) case final error?) error,
      if (validatePayDate(payDate, asOfDate) case final error?) error,
      if (validateReason(reason) case final error?) error,
      if (validateEvidenceReference(evidenceReference) case final error?) error,
    ];
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  PayrollOffCycleRunRequest toRequest({
    required String id,
    required Employee employee,
    required DateTime submittedAt,
  }) {
    return PayrollOffCycleRunRequest(
      id: id,
      employeeId: employee.id,
      employeeName: employee.name,
      department: employee.department ?? 'Payroll',
      type: type,
      grossAmount: double.parse(grossAmount.trim()),
      payDate: payDate!,
      reason: reason.trim(),
      evidenceReference: evidenceReference.trim(),
      grossUp: grossUp,
      status: PayrollOffCycleRunStatus.submitted,
      submittedAt: submittedAt,
    );
  }

  static String? validateGrossAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a gross amount';
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) return 'Enter a valid gross amount';
    if (amount > 50000) return 'Gross amount exceeds off-cycle limit';
    return null;
  }

  static String? validatePayDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select an off-cycle pay date';
    final date = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (date.isBefore(today)) return 'Pay date cannot be in the past';
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a reason';
    if (value.trim().length < 12) return 'Reason must be at least 12 chars';
    return null;
  }

  static String? validateEvidenceReference(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Attach an evidence reference';
    }
    if (value.trim().length < 6) return 'Evidence reference is too short';
    return null;
  }
}

class PayrollOffCycleRunSummary {
  final List<PayrollOffCycleRunRequest> requests;

  const PayrollOffCycleRunSummary({required this.requests});

  int get submittedCount => _count(PayrollOffCycleRunStatus.submitted);

  int get approvedCount => _count(PayrollOffCycleRunStatus.approved);

  int get releasedCount => _count(PayrollOffCycleRunStatus.released);

  int get rejectedCount => _count(PayrollOffCycleRunStatus.rejected);

  double get pendingGrossAmount {
    return requests
        .where(
          (request) =>
              !request.isReleased &&
              request.status != PayrollOffCycleRunStatus.rejected,
        )
        .fold(0, (total, request) => total + request.grossAmount);
  }

  double get releasedNetAmount {
    return requests
        .where((request) => request.isReleased)
        .fold(0, (total, request) => total + request.netAmount);
  }

  double get taxWithholdingAmount {
    return requests.fold(0, (total, request) => total + request.taxAmount);
  }

  PayrollOffCycleRunRequest? get nextRequest {
    final openRequests =
        requests.where((request) => !request.isReleased).toList()
          ..sort((left, right) => left.payDate.compareTo(right.payDate));
    if (openRequests.isEmpty) return null;
    return openRequests.first;
  }

  String get nextAction {
    if (submittedCount > 0) {
      return 'Approve $submittedCount off-cycle requests.';
    }
    if (approvedCount > 0) {
      return 'Release $approvedCount approved off-cycle runs.';
    }
    return 'No off-cycle payroll action is pending.';
  }

  int _count(PayrollOffCycleRunStatus status) {
    return requests.where((request) => request.status == status).length;
  }
}
