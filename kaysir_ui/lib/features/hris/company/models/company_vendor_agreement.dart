enum CompanyVendorAgreementCategory {
  payroll,
  benefits,
  recruitment,
  backgroundCheck,
  eSignature,
  occupationalHealth,
  dataProcessor,
}

enum CompanyVendorAgreementStatus {
  active,
  implementation,
  renewalDue,
  expired,
  suspended,
}

enum CompanyVendorAgreementIssue {
  missingVendor,
  missingService,
  missingEntity,
  missingOwner,
  missingAccountManager,
  missingSla,
  missingDataProtection,
  missingNextAction,
  reviewOverdue,
  reviewDueSoon,
  implementationOpen,
  renewalDue,
  expired,
  suspended,
}

extension CompanyVendorAgreementCategoryLabels
    on CompanyVendorAgreementCategory {
  String get label {
    switch (this) {
      case CompanyVendorAgreementCategory.payroll:
        return 'Payroll';
      case CompanyVendorAgreementCategory.benefits:
        return 'Benefits';
      case CompanyVendorAgreementCategory.recruitment:
        return 'Recruitment';
      case CompanyVendorAgreementCategory.backgroundCheck:
        return 'Background check';
      case CompanyVendorAgreementCategory.eSignature:
        return 'E-signature';
      case CompanyVendorAgreementCategory.occupationalHealth:
        return 'Occupational health';
      case CompanyVendorAgreementCategory.dataProcessor:
        return 'Data processor';
    }
  }
}

extension CompanyVendorAgreementStatusLabels on CompanyVendorAgreementStatus {
  String get label {
    switch (this) {
      case CompanyVendorAgreementStatus.active:
        return 'Active';
      case CompanyVendorAgreementStatus.implementation:
        return 'Implementation';
      case CompanyVendorAgreementStatus.renewalDue:
        return 'Renewal due';
      case CompanyVendorAgreementStatus.expired:
        return 'Expired';
      case CompanyVendorAgreementStatus.suspended:
        return 'Suspended';
    }
  }
}

extension CompanyVendorAgreementIssueLabels on CompanyVendorAgreementIssue {
  String get label {
    switch (this) {
      case CompanyVendorAgreementIssue.missingVendor:
        return 'Add vendor';
      case CompanyVendorAgreementIssue.missingService:
        return 'Add service';
      case CompanyVendorAgreementIssue.missingEntity:
        return 'Assign entity';
      case CompanyVendorAgreementIssue.missingOwner:
        return 'Assign owner';
      case CompanyVendorAgreementIssue.missingAccountManager:
        return 'Assign account manager';
      case CompanyVendorAgreementIssue.missingSla:
        return 'Add SLA';
      case CompanyVendorAgreementIssue.missingDataProtection:
        return 'Add DPA';
      case CompanyVendorAgreementIssue.missingNextAction:
        return 'Add next action';
      case CompanyVendorAgreementIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyVendorAgreementIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyVendorAgreementIssue.implementationOpen:
        return 'Close implementation';
      case CompanyVendorAgreementIssue.renewalDue:
        return 'Renew agreement';
      case CompanyVendorAgreementIssue.expired:
        return 'Expired';
      case CompanyVendorAgreementIssue.suspended:
        return 'Restore service';
    }
  }
}

class CompanyVendorAgreement {
  final String id;
  final String vendorName;
  final String serviceName;
  final String entityName;
  final CompanyVendorAgreementCategory category;
  final CompanyVendorAgreementStatus status;
  final String ownerName;
  final String accountManagerName;
  final DateTime contractEndDate;
  final String slaSummary;
  final String dataProtectionSummary;
  final String nextAction;
  final String linkedModule;

  const CompanyVendorAgreement({
    required this.id,
    required this.vendorName,
    required this.serviceName,
    required this.entityName,
    required this.category,
    required this.status,
    required this.ownerName,
    required this.accountManagerName,
    required this.contractEndDate,
    required this.slaSummary,
    required this.dataProtectionSummary,
    required this.nextAction,
    required this.linkedModule,
  });

  int daysUntilContractEnd(DateTime asOfDate) {
    return _dateOnly(contractEndDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyVendorAgreementIssue> issues(DateTime asOfDate) {
    final days = daysUntilContractEnd(asOfDate);
    return [
      if (vendorName.trim().isEmpty) CompanyVendorAgreementIssue.missingVendor,
      if (serviceName.trim().isEmpty)
        CompanyVendorAgreementIssue.missingService,
      if (entityName.trim().isEmpty) CompanyVendorAgreementIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyVendorAgreementIssue.missingOwner,
      if (accountManagerName.trim().isEmpty)
        CompanyVendorAgreementIssue.missingAccountManager,
      if (slaSummary.trim().isEmpty) CompanyVendorAgreementIssue.missingSla,
      if (dataProtectionSummary.trim().isEmpty)
        CompanyVendorAgreementIssue.missingDataProtection,
      if (nextAction.trim().isEmpty)
        CompanyVendorAgreementIssue.missingNextAction,
      if (days < 0 || status == CompanyVendorAgreementStatus.expired)
        CompanyVendorAgreementIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyVendorAgreementIssue.reviewDueSoon,
      if (status == CompanyVendorAgreementStatus.implementation)
        CompanyVendorAgreementIssue.implementationOpen,
      if (status == CompanyVendorAgreementStatus.renewalDue)
        CompanyVendorAgreementIssue.renewalDue,
      if (status == CompanyVendorAgreementStatus.expired)
        CompanyVendorAgreementIssue.expired,
      if (status == CompanyVendorAgreementStatus.suspended)
        CompanyVendorAgreementIssue.suspended,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyVendorAgreement copyWith({
    String? id,
    String? vendorName,
    String? serviceName,
    String? entityName,
    CompanyVendorAgreementCategory? category,
    CompanyVendorAgreementStatus? status,
    String? ownerName,
    String? accountManagerName,
    DateTime? contractEndDate,
    String? slaSummary,
    String? dataProtectionSummary,
    String? nextAction,
    String? linkedModule,
  }) {
    return CompanyVendorAgreement(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      serviceName: serviceName ?? this.serviceName,
      entityName: entityName ?? this.entityName,
      category: category ?? this.category,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      accountManagerName: accountManagerName ?? this.accountManagerName,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      slaSummary: slaSummary ?? this.slaSummary,
      dataProtectionSummary:
          dataProtectionSummary ?? this.dataProtectionSummary,
      nextAction: nextAction ?? this.nextAction,
      linkedModule: linkedModule ?? this.linkedModule,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyVendorAgreementDraft {
  final String vendorName;
  final String serviceName;
  final String entityName;
  final CompanyVendorAgreementCategory category;
  final CompanyVendorAgreementStatus status;
  final String ownerName;
  final String accountManagerName;
  final String contractEndDateText;
  final String slaSummary;
  final String dataProtectionSummary;
  final String nextAction;
  final String linkedModule;

  const CompanyVendorAgreementDraft({
    required this.vendorName,
    required this.serviceName,
    required this.entityName,
    required this.category,
    required this.status,
    required this.ownerName,
    required this.accountManagerName,
    required this.contractEndDateText,
    required this.slaSummary,
    required this.dataProtectionSummary,
    required this.nextAction,
    required this.linkedModule,
  });

  factory CompanyVendorAgreementDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyVendorAgreementDraft(
      vendorName: '',
      serviceName: '',
      entityName: entityName,
      category: CompanyVendorAgreementCategory.payroll,
      status: CompanyVendorAgreementStatus.implementation,
      ownerName: '',
      accountManagerName: '',
      contractEndDateText: '',
      slaSummary: '',
      dataProtectionSummary: '',
      nextAction: '',
      linkedModule: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get contractEndDate => _parseDate(contractEndDateText);

  bool get isReady {
    return vendorName.trim().isNotEmpty &&
        serviceName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        accountManagerName.trim().isNotEmpty &&
        contractEndDate != null &&
        slaSummary.trim().isNotEmpty &&
        dataProtectionSummary.trim().isNotEmpty &&
        nextAction.trim().isNotEmpty;
  }

  CompanyVendorAgreement toAgreement(String id) {
    if (!isReady) {
      throw StateError('Complete vendor agreement fields before saving.');
    }
    return CompanyVendorAgreement(
      id: id,
      vendorName: vendorName.trim(),
      serviceName: serviceName.trim(),
      entityName: entityName.trim(),
      category: category,
      status: status,
      ownerName: ownerName.trim(),
      accountManagerName: accountManagerName.trim(),
      contractEndDate: contractEndDate!,
      slaSummary: slaSummary.trim(),
      dataProtectionSummary: dataProtectionSummary.trim(),
      nextAction: nextAction.trim(),
      linkedModule: linkedModule.trim(),
    );
  }

  CompanyVendorAgreementDraft copyWith({
    String? vendorName,
    String? serviceName,
    String? entityName,
    CompanyVendorAgreementCategory? category,
    CompanyVendorAgreementStatus? status,
    String? ownerName,
    String? accountManagerName,
    String? contractEndDateText,
    String? slaSummary,
    String? dataProtectionSummary,
    String? nextAction,
    String? linkedModule,
  }) {
    return CompanyVendorAgreementDraft(
      vendorName: vendorName ?? this.vendorName,
      serviceName: serviceName ?? this.serviceName,
      entityName: entityName ?? this.entityName,
      category: category ?? this.category,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      accountManagerName: accountManagerName ?? this.accountManagerName,
      contractEndDateText: contractEndDateText ?? this.contractEndDateText,
      slaSummary: slaSummary ?? this.slaSummary,
      dataProtectionSummary:
          dataProtectionSummary ?? this.dataProtectionSummary,
      nextAction: nextAction ?? this.nextAction,
      linkedModule: linkedModule ?? this.linkedModule,
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
