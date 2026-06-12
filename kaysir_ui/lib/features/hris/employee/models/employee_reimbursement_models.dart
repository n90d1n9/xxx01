enum EmployeeExpenseCategory {
  travel('Travel'),
  meal('Meal'),
  learning('Learning'),
  equipment('Equipment'),
  wellness('Wellness'),
  other('Other');

  final String label;

  const EmployeeExpenseCategory(this.label);
}

enum EmployeeExpenseClaimStatus {
  submitted('Submitted'),
  approved('Approved'),
  reimbursed('Reimbursed'),
  rejected('Rejected');

  final String label;

  const EmployeeExpenseClaimStatus(this.label);
}

enum EmployeeExpenseReceiptStatus {
  attached('Attached'),
  missing('Missing'),
  flagged('Flagged');

  final String label;

  const EmployeeExpenseReceiptStatus(this.label);
}

class EmployeeExpenseAllowance {
  final String id;
  final EmployeeExpenseCategory category;
  final String label;
  final String currencyCode;
  final double annualLimit;
  final double usedAmount;
  final double pendingAmount;

  const EmployeeExpenseAllowance({
    required this.id,
    required this.category,
    required this.label,
    required this.currencyCode,
    required this.annualLimit,
    required this.usedAmount,
    required this.pendingAmount,
  });

  double get committedAmount => usedAmount + pendingAmount;

  double get remainingAmount {
    return (annualLimit - committedAmount).clamp(0, annualLimit).toDouble();
  }

  double get utilizationRatio {
    if (annualLimit <= 0) return 0;
    return (committedAmount / annualLimit).clamp(0, 1).toDouble();
  }

  bool get isLow => remainingAmount <= annualLimit * 0.12;

  EmployeeExpenseAllowance copyWith({
    double? usedAmount,
    double? pendingAmount,
  }) {
    return EmployeeExpenseAllowance(
      id: id,
      category: category,
      label: label,
      currencyCode: currencyCode,
      annualLimit: annualLimit,
      usedAmount: usedAmount ?? this.usedAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
    );
  }
}

class EmployeeExpenseClaim {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeExpenseCategory category;
  final String merchant;
  final double amount;
  final String currencyCode;
  final DateTime incurredOn;
  final DateTime submittedAt;
  final String description;
  final EmployeeExpenseReceiptStatus receiptStatus;
  final EmployeeExpenseClaimStatus status;

  const EmployeeExpenseClaim({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.category,
    required this.merchant,
    required this.amount,
    required this.currencyCode,
    required this.incurredOn,
    required this.submittedAt,
    required this.description,
    required this.receiptStatus,
    required this.status,
  });

  bool get needsReceipt {
    return receiptStatus == EmployeeExpenseReceiptStatus.missing ||
        receiptStatus == EmployeeExpenseReceiptStatus.flagged;
  }

  bool get canAttachReceipt =>
      needsReceipt && status != EmployeeExpenseClaimStatus.rejected;

  bool get canApprove {
    return status == EmployeeExpenseClaimStatus.submitted &&
        receiptStatus == EmployeeExpenseReceiptStatus.attached;
  }

  bool get canReject => status == EmployeeExpenseClaimStatus.submitted;

  bool get canReimburse => status == EmployeeExpenseClaimStatus.approved;

  EmployeeExpenseClaim copyWith({
    EmployeeExpenseReceiptStatus? receiptStatus,
    EmployeeExpenseClaimStatus? status,
  }) {
    return EmployeeExpenseClaim(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      category: category,
      merchant: merchant,
      amount: amount,
      currencyCode: currencyCode,
      incurredOn: incurredOn,
      submittedAt: submittedAt,
      description: description,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      status: status ?? this.status,
    );
  }
}

class EmployeeReimbursementProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeExpenseAllowance> allowances;
  final List<EmployeeExpenseClaim> claims;

  const EmployeeReimbursementProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.allowances,
    required this.claims,
  });

  EmployeeReimbursementProfile copyWith({
    List<EmployeeExpenseAllowance>? allowances,
    List<EmployeeExpenseClaim>? claims,
  }) {
    return EmployeeReimbursementProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      allowances: allowances ?? this.allowances,
      claims: claims ?? this.claims,
    );
  }

  int get submittedCount {
    return claims
        .where((claim) => claim.status == EmployeeExpenseClaimStatus.submitted)
        .length;
  }

  int get approvedCount {
    return claims
        .where((claim) => claim.status == EmployeeExpenseClaimStatus.approved)
        .length;
  }

  int get missingReceiptCount {
    return claims
        .where(
          (claim) =>
              claim.status != EmployeeExpenseClaimStatus.rejected &&
              claim.needsReceipt,
        )
        .length;
  }

  int get lowAllowanceCount {
    return allowances.where((allowance) => allowance.isLow).length;
  }

  double get pendingAmount {
    return claims
        .where(
          (claim) =>
              claim.status == EmployeeExpenseClaimStatus.submitted ||
              claim.status == EmployeeExpenseClaimStatus.approved,
        )
        .fold(0, (total, claim) => total + claim.amount);
  }

  int get attentionCount {
    return missingReceiptCount +
        submittedCount +
        approvedCount +
        lowAllowanceCount;
  }

  String get nextAction {
    if (missingReceiptCount > 0) {
      return 'Attach $missingReceiptCount missing receipt${missingReceiptCount == 1 ? '' : 's'}.';
    }
    if (submittedCount > 0) {
      return 'Review $submittedCount submitted expense claim${submittedCount == 1 ? '' : 's'}.';
    }
    if (approvedCount > 0) {
      return 'Reimburse $approvedCount approved claim${approvedCount == 1 ? '' : 's'}.';
    }
    if (lowAllowanceCount > 0) {
      return 'Review low allowance balances.';
    }
    return 'Expense claims are current.';
  }

  EmployeeExpenseAllowance? allowanceFor(EmployeeExpenseCategory category) {
    for (final allowance in allowances) {
      if (allowance.category == category) return allowance;
    }
    return null;
  }
}

class EmployeeExpenseDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeExpenseCategory category;
  final String merchant;
  final double amount;
  final String currencyCode;
  final DateTime incurredOn;
  final String description;
  final bool receiptAttached;

  const EmployeeExpenseDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.category,
    required this.merchant,
    required this.amount,
    required this.currencyCode,
    required this.incurredOn,
    required this.description,
    required this.receiptAttached,
  });

  EmployeeExpenseDraft copyWith({
    EmployeeExpenseCategory? category,
    String? merchant,
    double? amount,
    String? currencyCode,
    DateTime? incurredOn,
    String? description,
    bool? receiptAttached,
  }) {
    return EmployeeExpenseDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      incurredOn: incurredOn ?? this.incurredOn,
      description: description ?? this.description,
      receiptAttached: receiptAttached ?? this.receiptAttached,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (merchant.trim().length < 2) {
      errors.add('Merchant is required');
    }
    if (amount <= 0) {
      errors.add('Amount must be greater than zero');
    }
    if (incurredOn.isAfter(asOfDate)) {
      errors.add('Expense date cannot be in the future');
    }
    if (incurredOn.isBefore(asOfDate.subtract(const Duration(days: 365)))) {
      errors.add('Expense date is outside the claim window');
    }
    if (description.trim().length < 10) {
      errors.add('Description must be at least 10 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          merchant.trim().length >= 2,
          amount > 0,
          !incurredOn.isAfter(asOfDate) &&
              !incurredOn.isBefore(
                asOfDate.subtract(const Duration(days: 365)),
              ),
          description.trim().length >= 10,
          receiptAttached,
        ].where((item) => item).length;
    return completed / 5;
  }

  EmployeeExpenseClaim toClaim({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeExpenseClaim(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      category: category,
      merchant: merchant.trim(),
      amount: amount,
      currencyCode: currencyCode,
      incurredOn: incurredOn,
      submittedAt: asOfDate,
      description: description.trim(),
      receiptStatus:
          receiptAttached
              ? EmployeeExpenseReceiptStatus.attached
              : EmployeeExpenseReceiptStatus.missing,
      status: EmployeeExpenseClaimStatus.submitted,
    );
  }
}
