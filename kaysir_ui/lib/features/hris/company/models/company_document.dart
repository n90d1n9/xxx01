enum CompanyDocumentType {
  registration,
  tax,
  payroll,
  socialSecurity,
  bank,
  policy,
  lease,
  other,
}

enum CompanyDocumentStatus { verified, pending, expiringSoon, expired, missing }

enum CompanyDocumentIssue {
  missingEntity,
  missingOwner,
  missingDocumentNumber,
  expired,
  expiringSoon,
  pending,
  missing,
}

extension CompanyDocumentTypeLabels on CompanyDocumentType {
  String get label {
    switch (this) {
      case CompanyDocumentType.registration:
        return 'Registration';
      case CompanyDocumentType.tax:
        return 'Tax';
      case CompanyDocumentType.payroll:
        return 'Payroll';
      case CompanyDocumentType.socialSecurity:
        return 'Social security';
      case CompanyDocumentType.bank:
        return 'Bank';
      case CompanyDocumentType.policy:
        return 'Policy';
      case CompanyDocumentType.lease:
        return 'Lease';
      case CompanyDocumentType.other:
        return 'Other';
    }
  }
}

extension CompanyDocumentStatusLabels on CompanyDocumentStatus {
  String get label {
    switch (this) {
      case CompanyDocumentStatus.verified:
        return 'Verified';
      case CompanyDocumentStatus.pending:
        return 'Pending';
      case CompanyDocumentStatus.expiringSoon:
        return 'Expiring soon';
      case CompanyDocumentStatus.expired:
        return 'Expired';
      case CompanyDocumentStatus.missing:
        return 'Missing';
    }
  }
}

extension CompanyDocumentIssueLabels on CompanyDocumentIssue {
  String get label {
    switch (this) {
      case CompanyDocumentIssue.missingEntity:
        return 'Assign entity';
      case CompanyDocumentIssue.missingOwner:
        return 'Assign owner';
      case CompanyDocumentIssue.missingDocumentNumber:
        return 'Add document number';
      case CompanyDocumentIssue.expired:
        return 'Renew document';
      case CompanyDocumentIssue.expiringSoon:
        return 'Plan renewal';
      case CompanyDocumentIssue.pending:
        return 'Complete verification';
      case CompanyDocumentIssue.missing:
        return 'Upload document';
    }
  }
}

class CompanyDocumentRecord {
  static const renewalWindowDays = 30;

  final String id;
  final String title;
  final String documentNumber;
  final String entityName;
  final String ownerName;
  final CompanyDocumentType type;
  final DateTime? issuedDate;
  final DateTime? expiryDate;
  final CompanyDocumentStatus status;
  final String linkedModule;

  const CompanyDocumentRecord({
    required this.id,
    required this.title,
    required this.documentNumber,
    required this.entityName,
    required this.ownerName,
    required this.type,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    required this.linkedModule,
  });

  int? daysUntilExpiry(DateTime asOfDate) {
    final expiry = expiryDate;
    if (expiry == null) return null;
    return _dateOnly(expiry).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyDocumentIssue> issues(DateTime asOfDate) {
    final days = daysUntilExpiry(asOfDate);
    final isExpired =
        status == CompanyDocumentStatus.expired || (days != null && days < 0);
    final isExpiringSoon =
        !isExpired &&
        (status == CompanyDocumentStatus.expiringSoon ||
            (days != null && days <= renewalWindowDays));

    return [
      if (entityName.trim().isEmpty) CompanyDocumentIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyDocumentIssue.missingOwner,
      if (documentNumber.trim().isEmpty)
        CompanyDocumentIssue.missingDocumentNumber,
      if (isExpired) CompanyDocumentIssue.expired,
      if (isExpiringSoon) CompanyDocumentIssue.expiringSoon,
      if (status == CompanyDocumentStatus.pending) CompanyDocumentIssue.pending,
      if (status == CompanyDocumentStatus.missing) CompanyDocumentIssue.missing,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  double readinessScore(DateTime asOfDate) {
    const totalChecks = 7;
    return ((totalChecks - issues(asOfDate).length) / totalChecks).clamp(0, 1);
  }

  CompanyDocumentRecord copyWith({
    String? id,
    String? title,
    String? documentNumber,
    String? entityName,
    String? ownerName,
    CompanyDocumentType? type,
    DateTime? issuedDate,
    DateTime? expiryDate,
    CompanyDocumentStatus? status,
    String? linkedModule,
  }) {
    return CompanyDocumentRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      documentNumber: documentNumber ?? this.documentNumber,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      type: type ?? this.type,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      linkedModule: linkedModule ?? this.linkedModule,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyDocumentDraft {
  final String title;
  final String documentNumber;
  final String entityName;
  final String ownerName;
  final CompanyDocumentType type;
  final String issuedDateText;
  final String expiryDateText;
  final CompanyDocumentStatus status;
  final String linkedModule;

  const CompanyDocumentDraft({
    required this.title,
    required this.documentNumber,
    required this.entityName,
    required this.ownerName,
    required this.type,
    required this.issuedDateText,
    required this.expiryDateText,
    required this.status,
    required this.linkedModule,
  });

  factory CompanyDocumentDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyDocumentDraft(
      title: '',
      documentNumber: '',
      entityName: entityName,
      ownerName: '',
      type: CompanyDocumentType.registration,
      issuedDateText: '',
      expiryDateText: '',
      status: CompanyDocumentStatus.pending,
      linkedModule: 'Company',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDocumentNumber(
    String? value,
    CompanyDocumentStatus status,
  ) {
    if (status == CompanyDocumentStatus.missing) return null;
    return value == null || value.trim().isEmpty
        ? 'Enter document number'
        : null;
  }

  static String? validateOptionalDate(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return null;
    return _parseDate(normalized) == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get issuedDate => _parseDate(issuedDateText);

  DateTime? get expiryDate => _parseDate(expiryDateText);

  bool get isReady {
    return title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        linkedModule.trim().isNotEmpty &&
        (status == CompanyDocumentStatus.missing ||
            documentNumber.trim().isNotEmpty) &&
        (issuedDateText.trim().isEmpty || issuedDate != null) &&
        (expiryDateText.trim().isEmpty || expiryDate != null);
  }

  CompanyDocumentRecord toDocument(String id) {
    if (!isReady) {
      throw StateError('Complete company document fields before saving.');
    }

    return CompanyDocumentRecord(
      id: id,
      title: title.trim(),
      documentNumber: documentNumber.trim(),
      entityName: entityName.trim(),
      ownerName: ownerName.trim(),
      type: type,
      issuedDate: issuedDate,
      expiryDate: expiryDate,
      status: status,
      linkedModule: linkedModule.trim(),
    );
  }

  CompanyDocumentDraft copyWith({
    String? title,
    String? documentNumber,
    String? entityName,
    String? ownerName,
    CompanyDocumentType? type,
    String? issuedDateText,
    String? expiryDateText,
    CompanyDocumentStatus? status,
    String? linkedModule,
  }) {
    return CompanyDocumentDraft(
      title: title ?? this.title,
      documentNumber: documentNumber ?? this.documentNumber,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      type: type ?? this.type,
      issuedDateText: issuedDateText ?? this.issuedDateText,
      expiryDateText: expiryDateText ?? this.expiryDateText,
      status: status ?? this.status,
      linkedModule: linkedModule ?? this.linkedModule,
    );
  }

  static DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    final date = DateTime.tryParse(normalized);
    if (date == null || normalized.length != 10) return null;
    return DateTime(date.year, date.month, date.day);
  }
}
