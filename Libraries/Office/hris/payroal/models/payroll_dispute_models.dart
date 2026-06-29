import '../../employee/models/employee.dart';

enum PayrollDisputeType {
  missingPay('Missing pay'),
  incorrectDeduction('Incorrect deduction'),
  payslipQuestion('Payslip question'),
  bankFailure('Bank failure'),
  taxWithholding('Tax withholding');

  final String label;

  const PayrollDisputeType(this.label);
}

enum PayrollDisputeStatus {
  submitted('Submitted'),
  inReview('In review'),
  correctionApproved('Correction approved'),
  rejected('Rejected'),
  resolved('Resolved');

  final String label;

  const PayrollDisputeStatus(this.label);
}

class PayrollDisputeDraft {
  final int? employeeId;
  final PayrollDisputeType type;
  final String claimAmount;
  final String evidenceReference;
  final String description;
  final DateTime asOfDate;

  const PayrollDisputeDraft({
    required this.employeeId,
    required this.type,
    required this.claimAmount,
    required this.evidenceReference,
    required this.description,
    required this.asOfDate,
  });

  factory PayrollDisputeDraft.empty(DateTime asOfDate) {
    return PayrollDisputeDraft(
      employeeId: null,
      type: PayrollDisputeType.missingPay,
      claimAmount: '',
      evidenceReference: '',
      description: '',
      asOfDate: asOfDate,
    );
  }

  PayrollDisputeDraft copyWith({
    int? employeeId,
    PayrollDisputeType? type,
    String? claimAmount,
    String? evidenceReference,
    String? description,
    DateTime? asOfDate,
    bool clearEmployee = false,
  }) {
    return PayrollDisputeDraft(
      employeeId: clearEmployee ? null : employeeId ?? this.employeeId,
      type: type ?? this.type,
      claimAmount: claimAmount ?? this.claimAmount,
      evidenceReference: evidenceReference ?? this.evidenceReference,
      description: description ?? this.description,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          employeeId != null,
          validateClaimAmount(claimAmount) == null,
          validateEvidenceReference(evidenceReference) == null,
          validateDescription(description) == null,
        ].where((item) => item).length;
    return completed / 4;
  }

  List<String> get validationErrors {
    return [
      if (employeeId == null) 'Select an employee',
      if (validateClaimAmount(claimAmount) case final error?) error,
      if (validateEvidenceReference(evidenceReference) case final error?) error,
      if (validateDescription(description) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  PayrollDisputeCase toCase({required String id, required Employee employee}) {
    return PayrollDisputeCase(
      id: id,
      employeeId: employee.id,
      employeeName: employee.name,
      department: employee.department ?? 'Payroll',
      type: type,
      claimAmount: double.parse(claimAmount.trim()),
      evidenceReference: evidenceReference.trim(),
      description: description.trim(),
      submittedAt: asOfDate,
      owner: 'Payroll Ops',
      status: PayrollDisputeStatus.submitted,
      resolutionAmount: 0,
      resolutionNotes: '',
    );
  }

  static String? validateClaimAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter claimed amount';
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) return 'Enter a valid claimed amount';
    if (amount > 50000) return 'Claim exceeds dispute review threshold';
    return null;
  }

  static String? validateEvidenceReference(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Attach evidence reference';
    }
    if (value.trim().length < 6) return 'Evidence reference is too short';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter dispute details';
    if (value.trim().length < 12) {
      return 'Description must be at least 12 chars';
    }
    return null;
  }
}

class PayrollDisputeCase {
  final String id;
  final int employeeId;
  final String employeeName;
  final String department;
  final PayrollDisputeType type;
  final double claimAmount;
  final String evidenceReference;
  final String description;
  final DateTime submittedAt;
  final String owner;
  final PayrollDisputeStatus status;
  final double resolutionAmount;
  final String resolutionNotes;

  const PayrollDisputeCase({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.claimAmount,
    required this.evidenceReference,
    required this.description,
    required this.submittedAt,
    required this.owner,
    required this.status,
    required this.resolutionAmount,
    required this.resolutionNotes,
  });

  bool get isOpen =>
      status == PayrollDisputeStatus.submitted ||
      status == PayrollDisputeStatus.inReview ||
      status == PayrollDisputeStatus.correctionApproved;

  bool get canReview => status == PayrollDisputeStatus.submitted;

  bool get canApproveCorrection => status == PayrollDisputeStatus.inReview;

  bool get canClose => status == PayrollDisputeStatus.correctionApproved;

  bool get canReject =>
      status == PayrollDisputeStatus.submitted ||
      status == PayrollDisputeStatus.inReview;

  PayrollDisputeCase copyWith({
    PayrollDisputeStatus? status,
    double? resolutionAmount,
    String? resolutionNotes,
  }) {
    return PayrollDisputeCase(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      type: type,
      claimAmount: claimAmount,
      evidenceReference: evidenceReference,
      description: description,
      submittedAt: submittedAt,
      owner: owner,
      status: status ?? this.status,
      resolutionAmount: resolutionAmount ?? this.resolutionAmount,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

class PayrollDisputeSummary {
  final PayrollDisputeDraft draft;
  final List<PayrollDisputeCase> cases;
  final int? selectedEmployeeId;

  const PayrollDisputeSummary({
    required this.draft,
    required this.cases,
    required this.selectedEmployeeId,
  });

  List<PayrollDisputeCase> get visibleCases {
    if (selectedEmployeeId == null) return cases;
    return cases
        .where((item) => item.employeeId == selectedEmployeeId)
        .toList();
  }

  int get submittedCount => _count(PayrollDisputeStatus.submitted);

  int get inReviewCount => _count(PayrollDisputeStatus.inReview);

  int get correctionApprovedCount =>
      _count(PayrollDisputeStatus.correctionApproved);

  int get resolvedCount => _count(PayrollDisputeStatus.resolved);

  int get openCount => cases.where((item) => item.isOpen).length;

  double get openExposure {
    return cases
        .where((item) => item.isOpen)
        .fold(0, (total, item) => total + item.claimAmount);
  }

  double get approvedCorrectionAmount {
    return cases
        .where((item) => item.status == PayrollDisputeStatus.correctionApproved)
        .fold(0, (total, item) => total + item.resolutionAmount);
  }

  String get nextAction {
    if (submittedCount > 0) return 'Start review for $submittedCount disputes.';
    if (inReviewCount > 0) return 'Resolve $inReviewCount disputes in review.';
    if (correctionApprovedCount > 0) {
      return 'Close $correctionApprovedCount approved corrections.';
    }
    return 'No payroll disputes need action.';
  }

  int _count(PayrollDisputeStatus status) {
    return cases.where((item) => item.status == status).length;
  }
}
