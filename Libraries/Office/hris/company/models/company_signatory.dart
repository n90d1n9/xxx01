enum CompanySignatoryScope {
  statutoryFiling,
  employmentContract,
  payroll,
  bankInstruction,
  policy,
  legalDocument,
}

enum CompanySignatoryAuthorityLevel { preparer, reviewer, signer, approver }

enum CompanySignatoryStatus {
  active,
  pendingEvidence,
  expiringSoon,
  expired,
  revoked,
}

enum CompanySignatoryIssue {
  missingEntity,
  missingPerson,
  missingTitle,
  missingBackup,
  missingEvidence,
  expiryOverdue,
  expiringSoon,
  pendingEvidence,
  inactiveAuthority,
}

extension CompanySignatoryScopeLabels on CompanySignatoryScope {
  String get label {
    switch (this) {
      case CompanySignatoryScope.statutoryFiling:
        return 'Statutory filing';
      case CompanySignatoryScope.employmentContract:
        return 'Employment contract';
      case CompanySignatoryScope.payroll:
        return 'Payroll';
      case CompanySignatoryScope.bankInstruction:
        return 'Bank instruction';
      case CompanySignatoryScope.policy:
        return 'Policy';
      case CompanySignatoryScope.legalDocument:
        return 'Legal document';
    }
  }
}

extension CompanySignatoryAuthorityLevelLabels
    on CompanySignatoryAuthorityLevel {
  String get label {
    switch (this) {
      case CompanySignatoryAuthorityLevel.preparer:
        return 'Preparer';
      case CompanySignatoryAuthorityLevel.reviewer:
        return 'Reviewer';
      case CompanySignatoryAuthorityLevel.signer:
        return 'Signer';
      case CompanySignatoryAuthorityLevel.approver:
        return 'Approver';
    }
  }
}

extension CompanySignatoryStatusLabels on CompanySignatoryStatus {
  String get label {
    switch (this) {
      case CompanySignatoryStatus.active:
        return 'Active';
      case CompanySignatoryStatus.pendingEvidence:
        return 'Pending evidence';
      case CompanySignatoryStatus.expiringSoon:
        return 'Expiring soon';
      case CompanySignatoryStatus.expired:
        return 'Expired';
      case CompanySignatoryStatus.revoked:
        return 'Revoked';
    }
  }
}

extension CompanySignatoryIssueLabels on CompanySignatoryIssue {
  String get label {
    switch (this) {
      case CompanySignatoryIssue.missingEntity:
        return 'Assign entity';
      case CompanySignatoryIssue.missingPerson:
        return 'Assign signer';
      case CompanySignatoryIssue.missingTitle:
        return 'Add title';
      case CompanySignatoryIssue.missingBackup:
        return 'Assign backup';
      case CompanySignatoryIssue.missingEvidence:
        return 'Attach evidence';
      case CompanySignatoryIssue.expiryOverdue:
        return 'Authority expired';
      case CompanySignatoryIssue.expiringSoon:
        return 'Authority expiring';
      case CompanySignatoryIssue.pendingEvidence:
        return 'Evidence pending';
      case CompanySignatoryIssue.inactiveAuthority:
        return 'Authority inactive';
    }
  }
}

class CompanySignatory {
  final String id;
  final String personName;
  final String title;
  final String entityName;
  final CompanySignatoryScope scope;
  final CompanySignatoryAuthorityLevel authorityLevel;
  final CompanySignatoryStatus status;
  final DateTime effectiveDate;
  final DateTime expiryDate;
  final String backupSignerName;
  final String evidenceSummary;
  final String delegationNotes;

  const CompanySignatory({
    required this.id,
    required this.personName,
    required this.title,
    required this.entityName,
    required this.scope,
    required this.authorityLevel,
    required this.status,
    required this.effectiveDate,
    required this.expiryDate,
    required this.backupSignerName,
    required this.evidenceSummary,
    required this.delegationNotes,
  });

  int daysUntilExpiry(DateTime asOfDate) {
    return _dateOnly(expiryDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanySignatoryIssue> issues(DateTime asOfDate) {
    final days = daysUntilExpiry(asOfDate);
    final requiresBackup =
        authorityLevel == CompanySignatoryAuthorityLevel.signer ||
        authorityLevel == CompanySignatoryAuthorityLevel.approver;

    return [
      if (entityName.trim().isEmpty) CompanySignatoryIssue.missingEntity,
      if (personName.trim().isEmpty) CompanySignatoryIssue.missingPerson,
      if (title.trim().isEmpty) CompanySignatoryIssue.missingTitle,
      if (requiresBackup && backupSignerName.trim().isEmpty)
        CompanySignatoryIssue.missingBackup,
      if (evidenceSummary.trim().isEmpty) CompanySignatoryIssue.missingEvidence,
      if (days < 0 || status == CompanySignatoryStatus.expired)
        CompanySignatoryIssue.expiryOverdue,
      if (days >= 0 && days <= 30 ||
          status == CompanySignatoryStatus.expiringSoon)
        CompanySignatoryIssue.expiringSoon,
      if (status == CompanySignatoryStatus.pendingEvidence)
        CompanySignatoryIssue.pendingEvidence,
      if (status == CompanySignatoryStatus.revoked)
        CompanySignatoryIssue.inactiveAuthority,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanySignatory copyWith({
    String? id,
    String? personName,
    String? title,
    String? entityName,
    CompanySignatoryScope? scope,
    CompanySignatoryAuthorityLevel? authorityLevel,
    CompanySignatoryStatus? status,
    DateTime? effectiveDate,
    DateTime? expiryDate,
    String? backupSignerName,
    String? evidenceSummary,
    String? delegationNotes,
  }) {
    return CompanySignatory(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      scope: scope ?? this.scope,
      authorityLevel: authorityLevel ?? this.authorityLevel,
      status: status ?? this.status,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      backupSignerName: backupSignerName ?? this.backupSignerName,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      delegationNotes: delegationNotes ?? this.delegationNotes,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanySignatoryDraft {
  final String personName;
  final String title;
  final String entityName;
  final CompanySignatoryScope scope;
  final CompanySignatoryAuthorityLevel authorityLevel;
  final CompanySignatoryStatus status;
  final String effectiveDateText;
  final String expiryDateText;
  final String backupSignerName;
  final String evidenceSummary;
  final String delegationNotes;

  const CompanySignatoryDraft({
    required this.personName,
    required this.title,
    required this.entityName,
    required this.scope,
    required this.authorityLevel,
    required this.status,
    required this.effectiveDateText,
    required this.expiryDateText,
    required this.backupSignerName,
    required this.evidenceSummary,
    required this.delegationNotes,
  });

  factory CompanySignatoryDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanySignatoryDraft(
      personName: '',
      title: '',
      entityName: entityName,
      scope: CompanySignatoryScope.employmentContract,
      authorityLevel: CompanySignatoryAuthorityLevel.signer,
      status: CompanySignatoryStatus.active,
      effectiveDateText: '',
      expiryDateText: '',
      backupSignerName: '',
      evidenceSummary: '',
      delegationNotes: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get effectiveDate => _parseDate(effectiveDateText);
  DateTime? get expiryDate => _parseDate(expiryDateText);

  bool get isReady {
    return personName.trim().isNotEmpty &&
        title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        effectiveDate != null &&
        expiryDate != null &&
        evidenceSummary.trim().isNotEmpty;
  }

  CompanySignatory toSignatory(String id) {
    if (!isReady) {
      throw StateError('Complete company signatory fields before saving.');
    }
    return CompanySignatory(
      id: id,
      personName: personName.trim(),
      title: title.trim(),
      entityName: entityName.trim(),
      scope: scope,
      authorityLevel: authorityLevel,
      status: status,
      effectiveDate: effectiveDate!,
      expiryDate: expiryDate!,
      backupSignerName: backupSignerName.trim(),
      evidenceSummary: evidenceSummary.trim(),
      delegationNotes: delegationNotes.trim(),
    );
  }

  CompanySignatoryDraft copyWith({
    String? personName,
    String? title,
    String? entityName,
    CompanySignatoryScope? scope,
    CompanySignatoryAuthorityLevel? authorityLevel,
    CompanySignatoryStatus? status,
    String? effectiveDateText,
    String? expiryDateText,
    String? backupSignerName,
    String? evidenceSummary,
    String? delegationNotes,
  }) {
    return CompanySignatoryDraft(
      personName: personName ?? this.personName,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      scope: scope ?? this.scope,
      authorityLevel: authorityLevel ?? this.authorityLevel,
      status: status ?? this.status,
      effectiveDateText: effectiveDateText ?? this.effectiveDateText,
      expiryDateText: expiryDateText ?? this.expiryDateText,
      backupSignerName: backupSignerName ?? this.backupSignerName,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      delegationNotes: delegationNotes ?? this.delegationNotes,
    );
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }
}
