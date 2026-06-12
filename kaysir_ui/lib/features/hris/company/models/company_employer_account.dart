enum CompanyEmployerAccountType {
  payrollTax,
  socialSecurity,
  pension,
  payrollBank,
  governmentPortal,
  laborRegistry,
}

enum CompanyEmployerAccountStatus {
  verified,
  setupInProgress,
  pendingAuthority,
  needsReview,
  suspended,
}

enum CompanyEmployerAccountIssue {
  missingEntity,
  missingAccountNumber,
  missingOwner,
  missingCredentialOwner,
  missingEvidence,
  reviewOverdue,
  reviewDueSoon,
  pendingAuthority,
  setupBlocked,
  suspended,
  needsReview,
}

extension CompanyEmployerAccountTypeLabels on CompanyEmployerAccountType {
  String get label {
    switch (this) {
      case CompanyEmployerAccountType.payrollTax:
        return 'Payroll tax';
      case CompanyEmployerAccountType.socialSecurity:
        return 'Social security';
      case CompanyEmployerAccountType.pension:
        return 'Pension';
      case CompanyEmployerAccountType.payrollBank:
        return 'Payroll bank';
      case CompanyEmployerAccountType.governmentPortal:
        return 'Government portal';
      case CompanyEmployerAccountType.laborRegistry:
        return 'Labor registry';
    }
  }
}

extension CompanyEmployerAccountStatusLabels on CompanyEmployerAccountStatus {
  String get label {
    switch (this) {
      case CompanyEmployerAccountStatus.verified:
        return 'Verified';
      case CompanyEmployerAccountStatus.setupInProgress:
        return 'Setup in progress';
      case CompanyEmployerAccountStatus.pendingAuthority:
        return 'Pending authority';
      case CompanyEmployerAccountStatus.needsReview:
        return 'Needs review';
      case CompanyEmployerAccountStatus.suspended:
        return 'Suspended';
    }
  }
}

extension CompanyEmployerAccountIssueLabels on CompanyEmployerAccountIssue {
  String get label {
    switch (this) {
      case CompanyEmployerAccountIssue.missingEntity:
        return 'Assign entity';
      case CompanyEmployerAccountIssue.missingAccountNumber:
        return 'Add account number';
      case CompanyEmployerAccountIssue.missingOwner:
        return 'Assign owner';
      case CompanyEmployerAccountIssue.missingCredentialOwner:
        return 'Assign credential owner';
      case CompanyEmployerAccountIssue.missingEvidence:
        return 'Attach evidence';
      case CompanyEmployerAccountIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyEmployerAccountIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyEmployerAccountIssue.pendingAuthority:
        return 'Chase authority';
      case CompanyEmployerAccountIssue.setupBlocked:
        return 'Complete setup';
      case CompanyEmployerAccountIssue.suspended:
        return 'Restore account';
      case CompanyEmployerAccountIssue.needsReview:
        return 'Review account';
    }
  }
}

class CompanyEmployerAccount {
  final String id;
  final String accountName;
  final String entityName;
  final CompanyEmployerAccountType type;
  final CompanyEmployerAccountStatus status;
  final String accountNumber;
  final String ownerName;
  final String credentialOwnerName;
  final DateTime nextReviewDate;
  final String evidenceSummary;
  final String nextAction;
  final String linkedFiling;

  const CompanyEmployerAccount({
    required this.id,
    required this.accountName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.accountNumber,
    required this.ownerName,
    required this.credentialOwnerName,
    required this.nextReviewDate,
    required this.evidenceSummary,
    required this.nextAction,
    required this.linkedFiling,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyEmployerAccountIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (entityName.trim().isEmpty) CompanyEmployerAccountIssue.missingEntity,
      if (accountNumber.trim().isEmpty)
        CompanyEmployerAccountIssue.missingAccountNumber,
      if (ownerName.trim().isEmpty) CompanyEmployerAccountIssue.missingOwner,
      if (credentialOwnerName.trim().isEmpty)
        CompanyEmployerAccountIssue.missingCredentialOwner,
      if (status != CompanyEmployerAccountStatus.setupInProgress &&
          evidenceSummary.trim().isEmpty)
        CompanyEmployerAccountIssue.missingEvidence,
      if (days < 0) CompanyEmployerAccountIssue.reviewOverdue,
      if (days >= 0 && days <= 30) CompanyEmployerAccountIssue.reviewDueSoon,
      if (status == CompanyEmployerAccountStatus.pendingAuthority)
        CompanyEmployerAccountIssue.pendingAuthority,
      if (status == CompanyEmployerAccountStatus.setupInProgress)
        CompanyEmployerAccountIssue.setupBlocked,
      if (status == CompanyEmployerAccountStatus.suspended)
        CompanyEmployerAccountIssue.suspended,
      if (status == CompanyEmployerAccountStatus.needsReview)
        CompanyEmployerAccountIssue.needsReview,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyEmployerAccount copyWith({
    String? id,
    String? accountName,
    String? entityName,
    CompanyEmployerAccountType? type,
    CompanyEmployerAccountStatus? status,
    String? accountNumber,
    String? ownerName,
    String? credentialOwnerName,
    DateTime? nextReviewDate,
    String? evidenceSummary,
    String? nextAction,
    String? linkedFiling,
  }) {
    return CompanyEmployerAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      accountNumber: accountNumber ?? this.accountNumber,
      ownerName: ownerName ?? this.ownerName,
      credentialOwnerName: credentialOwnerName ?? this.credentialOwnerName,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      nextAction: nextAction ?? this.nextAction,
      linkedFiling: linkedFiling ?? this.linkedFiling,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyEmployerAccountDraft {
  final String accountName;
  final String entityName;
  final CompanyEmployerAccountType type;
  final CompanyEmployerAccountStatus status;
  final String accountNumber;
  final String ownerName;
  final String credentialOwnerName;
  final String nextReviewDateText;
  final String evidenceSummary;
  final String nextAction;
  final String linkedFiling;

  const CompanyEmployerAccountDraft({
    required this.accountName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.accountNumber,
    required this.ownerName,
    required this.credentialOwnerName,
    required this.nextReviewDateText,
    required this.evidenceSummary,
    required this.nextAction,
    required this.linkedFiling,
  });

  factory CompanyEmployerAccountDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyEmployerAccountDraft(
      accountName: '',
      entityName: entityName,
      type: CompanyEmployerAccountType.payrollTax,
      status: CompanyEmployerAccountStatus.setupInProgress,
      accountNumber: '',
      ownerName: '',
      credentialOwnerName: '',
      nextReviewDateText: '',
      evidenceSummary: '',
      nextAction: '',
      linkedFiling: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    return accountName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        accountNumber.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        credentialOwnerName.trim().isNotEmpty &&
        nextReviewDate != null &&
        nextAction.trim().isNotEmpty;
  }

  CompanyEmployerAccount toAccount(String id) {
    if (!isReady) {
      throw StateError('Complete employer account fields before saving.');
    }
    return CompanyEmployerAccount(
      id: id,
      accountName: accountName.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      accountNumber: accountNumber.trim(),
      ownerName: ownerName.trim(),
      credentialOwnerName: credentialOwnerName.trim(),
      nextReviewDate: nextReviewDate!,
      evidenceSummary: evidenceSummary.trim(),
      nextAction: nextAction.trim(),
      linkedFiling: linkedFiling.trim(),
    );
  }

  CompanyEmployerAccountDraft copyWith({
    String? accountName,
    String? entityName,
    CompanyEmployerAccountType? type,
    CompanyEmployerAccountStatus? status,
    String? accountNumber,
    String? ownerName,
    String? credentialOwnerName,
    String? nextReviewDateText,
    String? evidenceSummary,
    String? nextAction,
    String? linkedFiling,
  }) {
    return CompanyEmployerAccountDraft(
      accountName: accountName ?? this.accountName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      accountNumber: accountNumber ?? this.accountNumber,
      ownerName: ownerName ?? this.ownerName,
      credentialOwnerName: credentialOwnerName ?? this.credentialOwnerName,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      nextAction: nextAction ?? this.nextAction,
      linkedFiling: linkedFiling ?? this.linkedFiling,
    );
  }

  static DateTime? _parseDate(String value) {
    final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!pattern.hasMatch(value)) return null;
    final parts = value.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    return date.year == parts[0] &&
            date.month == parts[1] &&
            date.day == parts[2]
        ? date
        : null;
  }
}
