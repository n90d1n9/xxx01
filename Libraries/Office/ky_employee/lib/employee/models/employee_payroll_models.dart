enum EmployeePaymentMethod {
  directDeposit('Direct deposit'),
  bankTransfer('Bank transfer'),
  manual('Manual');

  final String label;

  const EmployeePaymentMethod(this.label);
}

enum EmployeeBankVerificationStatus {
  verified('Verified'),
  pending('Pending'),
  failed('Failed'),
  missing('Missing');

  final String label;

  const EmployeeBankVerificationStatus(this.label);
}

enum EmployeeTaxFormStatus {
  current('Current'),
  expiring('Expiring'),
  missing('Missing'),
  rejected('Rejected');

  final String label;

  const EmployeeTaxFormStatus(this.label);
}

enum EmployeePayrollChangeType {
  bankAccount('Bank account'),
  taxWithholding('Tax withholding'),
  paySchedule('Pay schedule'),
  paymentMethod('Payment method');

  final String label;

  const EmployeePayrollChangeType(this.label);
}

enum EmployeePayrollChangeStatus {
  submitted('Submitted'),
  approved('Approved'),
  applied('Applied'),
  rejected('Rejected');

  final String label;

  const EmployeePayrollChangeStatus(this.label);
}

class EmployeePayrollBankAccount {
  final String bankName;
  final String maskedAccount;
  final String routingCode;
  final String country;
  final EmployeeBankVerificationStatus verificationStatus;
  final DateTime? lastVerifiedAt;

  const EmployeePayrollBankAccount({
    required this.bankName,
    required this.maskedAccount,
    required this.routingCode,
    required this.country,
    required this.verificationStatus,
    required this.lastVerifiedAt,
  });

  bool get needsAttention {
    return verificationStatus == EmployeeBankVerificationStatus.pending ||
        verificationStatus == EmployeeBankVerificationStatus.failed ||
        verificationStatus == EmployeeBankVerificationStatus.missing;
  }

  EmployeePayrollBankAccount copyWith({
    EmployeeBankVerificationStatus? verificationStatus,
    DateTime? lastVerifiedAt,
  }) {
    return EmployeePayrollBankAccount(
      bankName: bankName,
      maskedAccount: maskedAccount,
      routingCode: routingCode,
      country: country,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }
}

class EmployeePayrollTaxProfile {
  final String taxIdMasked;
  final String formType;
  final String filingStatus;
  final int allowanceCount;
  final EmployeeTaxFormStatus status;
  final DateTime lastUpdatedAt;

  const EmployeePayrollTaxProfile({
    required this.taxIdMasked,
    required this.formType,
    required this.filingStatus,
    required this.allowanceCount,
    required this.status,
    required this.lastUpdatedAt,
  });

  bool get needsAttention {
    return status == EmployeeTaxFormStatus.expiring ||
        status == EmployeeTaxFormStatus.missing ||
        status == EmployeeTaxFormStatus.rejected;
  }

  EmployeePayrollTaxProfile copyWith({
    EmployeeTaxFormStatus? status,
    DateTime? lastUpdatedAt,
  }) {
    return EmployeePayrollTaxProfile(
      taxIdMasked: taxIdMasked,
      formType: formType,
      filingStatus: filingStatus,
      allowanceCount: allowanceCount,
      status: status ?? this.status,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

class EmployeePayrollSchedule {
  final String payGroup;
  final String payCycle;
  final String currencyCode;
  final EmployeePaymentMethod paymentMethod;
  final DateTime nextPayDate;
  final DateTime cutoffDate;

  const EmployeePayrollSchedule({
    required this.payGroup,
    required this.payCycle,
    required this.currencyCode,
    required this.paymentMethod,
    required this.nextPayDate,
    required this.cutoffDate,
  });

  bool isCutoffSoon(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return !cutoffDate.isBefore(today) &&
        !cutoffDate.isAfter(today.add(const Duration(days: 5)));
  }
}

class EmployeePayrollChangeRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeePayrollChangeType type;
  final String title;
  final String requestedBy;
  final DateTime effectiveDate;
  final String detail;
  final EmployeePayrollChangeStatus status;
  final DateTime submittedAt;

  const EmployeePayrollChangeRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.effectiveDate,
    required this.detail,
    required this.status,
    required this.submittedAt,
  });

  bool get canApprove => status == EmployeePayrollChangeStatus.submitted;

  bool get canApply => status == EmployeePayrollChangeStatus.approved;

  bool get canReject => status == EmployeePayrollChangeStatus.submitted;

  EmployeePayrollChangeRequest copyWith({EmployeePayrollChangeStatus? status}) {
    return EmployeePayrollChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      requestedBy: requestedBy,
      effectiveDate: effectiveDate,
      detail: detail,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}

class EmployeePayrollProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeePayrollBankAccount bankAccount;
  final EmployeePayrollTaxProfile taxProfile;
  final EmployeePayrollSchedule schedule;
  final List<EmployeePayrollChangeRequest> changes;

  const EmployeePayrollProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.bankAccount,
    required this.taxProfile,
    required this.schedule,
    required this.changes,
  });

  EmployeePayrollProfile copyWith({
    EmployeePayrollBankAccount? bankAccount,
    EmployeePayrollTaxProfile? taxProfile,
    List<EmployeePayrollChangeRequest>? changes,
  }) {
    return EmployeePayrollProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      bankAccount: bankAccount ?? this.bankAccount,
      taxProfile: taxProfile ?? this.taxProfile,
      schedule: schedule,
      changes: changes ?? this.changes,
    );
  }

  int get submittedChangeCount {
    return changes
        .where(
          (change) => change.status == EmployeePayrollChangeStatus.submitted,
        )
        .length;
  }

  int get approvedChangeCount {
    return changes
        .where(
          (change) => change.status == EmployeePayrollChangeStatus.approved,
        )
        .length;
  }

  int get bankAttentionCount => bankAccount.needsAttention ? 1 : 0;

  int get taxAttentionCount => taxProfile.needsAttention ? 1 : 0;

  int get attentionCount {
    return bankAttentionCount +
        taxAttentionCount +
        submittedChangeCount +
        approvedChangeCount;
  }

  String get nextAction {
    if (bankAttentionCount > 0) return 'Verify payroll bank account.';
    if (taxAttentionCount > 0) return 'Review payroll tax profile.';
    if (approvedChangeCount > 0) {
      return 'Apply $approvedChangeCount approved payroll change${approvedChangeCount == 1 ? '' : 's'}.';
    }
    if (submittedChangeCount > 0) {
      return 'Review $submittedChangeCount submitted payroll change${submittedChangeCount == 1 ? '' : 's'}.';
    }
    if (schedule.isCutoffSoon(asOfDate)) return 'Payroll cutoff is coming up.';
    return 'Payroll profile is current.';
  }
}

class EmployeePayrollChangeDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeePayrollChangeType type;
  final String title;
  final String requestedBy;
  final DateTime? effectiveDate;
  final String detail;

  const EmployeePayrollChangeDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.effectiveDate,
    required this.detail,
  });

  EmployeePayrollChangeDraft copyWith({
    EmployeePayrollChangeType? type,
    String? title,
    String? requestedBy,
    DateTime? effectiveDate,
    String? detail,
  }) {
    return EmployeePayrollChangeDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      requestedBy: requestedBy ?? this.requestedBy,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      detail: detail ?? this.detail,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Title must be at least 4 characters');
    }
    if (requestedBy.trim().length < 3) {
      errors.add('Requester is required');
    }
    if (effectiveDate == null) {
      errors.add('Effective date is required');
    } else if (effectiveDate!.isBefore(asOfDate)) {
      errors.add('Effective date cannot be before today');
    }
    if (detail.trim().length < 12) {
      errors.add('Detail must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          title.trim().length >= 4,
          requestedBy.trim().length >= 3,
          effectiveDate != null && !effectiveDate!.isBefore(asOfDate),
          detail.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 4;
  }

  EmployeePayrollChangeRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeePayrollChangeRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      requestedBy: requestedBy.trim(),
      effectiveDate: effectiveDate!,
      detail: detail.trim(),
      status: EmployeePayrollChangeStatus.submitted,
      submittedAt: asOfDate,
    );
  }
}
