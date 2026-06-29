enum CompanyGovernanceRole {
  executiveSponsor,
  peopleOwner,
  payrollOwner,
  legalOwner,
  financeOwner,
  complianceOwner,
  itOwner,
  branchOwner,
}

enum CompanyGovernanceContactStatus {
  active,
  missingBackup,
  needsReview,
  inactive,
}

enum CompanyGovernanceContactIssue {
  missingEntity,
  missingOwner,
  missingEmail,
  missingPhone,
  missingBackup,
  reviewOverdue,
  needsReview,
  inactive,
}

extension CompanyGovernanceRoleLabels on CompanyGovernanceRole {
  String get label {
    switch (this) {
      case CompanyGovernanceRole.executiveSponsor:
        return 'Executive sponsor';
      case CompanyGovernanceRole.peopleOwner:
        return 'People owner';
      case CompanyGovernanceRole.payrollOwner:
        return 'Payroll owner';
      case CompanyGovernanceRole.legalOwner:
        return 'Legal owner';
      case CompanyGovernanceRole.financeOwner:
        return 'Finance owner';
      case CompanyGovernanceRole.complianceOwner:
        return 'Compliance owner';
      case CompanyGovernanceRole.itOwner:
        return 'IT owner';
      case CompanyGovernanceRole.branchOwner:
        return 'Branch owner';
    }
  }
}

extension CompanyGovernanceContactStatusLabels
    on CompanyGovernanceContactStatus {
  String get label {
    switch (this) {
      case CompanyGovernanceContactStatus.active:
        return 'Active';
      case CompanyGovernanceContactStatus.missingBackup:
        return 'Missing backup';
      case CompanyGovernanceContactStatus.needsReview:
        return 'Needs review';
      case CompanyGovernanceContactStatus.inactive:
        return 'Inactive';
    }
  }
}

extension CompanyGovernanceContactIssueLabels on CompanyGovernanceContactIssue {
  String get label {
    switch (this) {
      case CompanyGovernanceContactIssue.missingEntity:
        return 'Assign entity';
      case CompanyGovernanceContactIssue.missingOwner:
        return 'Assign owner';
      case CompanyGovernanceContactIssue.missingEmail:
        return 'Add email';
      case CompanyGovernanceContactIssue.missingPhone:
        return 'Add phone';
      case CompanyGovernanceContactIssue.missingBackup:
        return 'Assign backup';
      case CompanyGovernanceContactIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyGovernanceContactIssue.needsReview:
        return 'Review owner';
      case CompanyGovernanceContactIssue.inactive:
        return 'Activate owner';
    }
  }
}

class CompanyGovernanceContact {
  final String id;
  final String entityName;
  final CompanyGovernanceRole role;
  final String personName;
  final String title;
  final String email;
  final String phone;
  final String backupName;
  final String escalationChannel;
  final CompanyGovernanceContactStatus status;
  final DateTime lastReviewedAt;
  final DateTime nextReviewAt;

  const CompanyGovernanceContact({
    required this.id,
    required this.entityName,
    required this.role,
    required this.personName,
    required this.title,
    required this.email,
    required this.phone,
    required this.backupName,
    required this.escalationChannel,
    required this.status,
    required this.lastReviewedAt,
    required this.nextReviewAt,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewAt).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyGovernanceContactIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);

    return [
      if (entityName.trim().isEmpty)
        CompanyGovernanceContactIssue.missingEntity,
      if (personName.trim().isEmpty) CompanyGovernanceContactIssue.missingOwner,
      if (email.trim().isEmpty) CompanyGovernanceContactIssue.missingEmail,
      if (phone.trim().isEmpty) CompanyGovernanceContactIssue.missingPhone,
      if (backupName.trim().isEmpty ||
          status == CompanyGovernanceContactStatus.missingBackup)
        CompanyGovernanceContactIssue.missingBackup,
      if (days < 0) CompanyGovernanceContactIssue.reviewOverdue,
      if (status == CompanyGovernanceContactStatus.needsReview)
        CompanyGovernanceContactIssue.needsReview,
      if (status == CompanyGovernanceContactStatus.inactive)
        CompanyGovernanceContactIssue.inactive,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyGovernanceContact copyWith({
    String? id,
    String? entityName,
    CompanyGovernanceRole? role,
    String? personName,
    String? title,
    String? email,
    String? phone,
    String? backupName,
    String? escalationChannel,
    CompanyGovernanceContactStatus? status,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return CompanyGovernanceContact(
      id: id ?? this.id,
      entityName: entityName ?? this.entityName,
      role: role ?? this.role,
      personName: personName ?? this.personName,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      backupName: backupName ?? this.backupName,
      escalationChannel: escalationChannel ?? this.escalationChannel,
      status: status ?? this.status,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyGovernanceContactDraft {
  final String entityName;
  final CompanyGovernanceRole role;
  final String personName;
  final String title;
  final String email;
  final String phone;
  final String backupName;
  final String escalationChannel;
  final CompanyGovernanceContactStatus status;
  final String lastReviewedAtText;
  final String nextReviewAtText;

  const CompanyGovernanceContactDraft({
    required this.entityName,
    required this.role,
    required this.personName,
    required this.title,
    required this.email,
    required this.phone,
    required this.backupName,
    required this.escalationChannel,
    required this.status,
    required this.lastReviewedAtText,
    required this.nextReviewAtText,
  });

  factory CompanyGovernanceContactDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyGovernanceContactDraft(
      entityName: entityName,
      role: CompanyGovernanceRole.peopleOwner,
      personName: '',
      title: '',
      email: '',
      phone: '',
      backupName: '',
      escalationChannel: 'People Operations',
      status: CompanyGovernanceContactStatus.active,
      lastReviewedAtText: '',
      nextReviewAtText: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateEmail(String? value) {
    final normalized = value?.trim() ?? '';
    if (!normalized.contains('@') || !normalized.contains('.')) {
      return 'Enter valid email';
    }
    return null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get lastReviewedAt => _parseDate(lastReviewedAtText);

  DateTime? get nextReviewAt => _parseDate(nextReviewAtText);

  bool get isReady {
    return entityName.trim().isNotEmpty &&
        personName.trim().isNotEmpty &&
        title.trim().isNotEmpty &&
        validateEmail(email) == null &&
        phone.trim().isNotEmpty &&
        escalationChannel.trim().isNotEmpty &&
        lastReviewedAt != null &&
        nextReviewAt != null;
  }

  CompanyGovernanceContact toContact(String id) {
    if (!isReady) {
      throw StateError('Complete governance contact before saving.');
    }

    return CompanyGovernanceContact(
      id: id,
      entityName: entityName.trim(),
      role: role,
      personName: personName.trim(),
      title: title.trim(),
      email: email.trim(),
      phone: phone.trim(),
      backupName: backupName.trim(),
      escalationChannel: escalationChannel.trim(),
      status: status,
      lastReviewedAt: lastReviewedAt!,
      nextReviewAt: nextReviewAt!,
    );
  }

  CompanyGovernanceContactDraft copyWith({
    String? entityName,
    CompanyGovernanceRole? role,
    String? personName,
    String? title,
    String? email,
    String? phone,
    String? backupName,
    String? escalationChannel,
    CompanyGovernanceContactStatus? status,
    String? lastReviewedAtText,
    String? nextReviewAtText,
  }) {
    return CompanyGovernanceContactDraft(
      entityName: entityName ?? this.entityName,
      role: role ?? this.role,
      personName: personName ?? this.personName,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      backupName: backupName ?? this.backupName,
      escalationChannel: escalationChannel ?? this.escalationChannel,
      status: status ?? this.status,
      lastReviewedAtText: lastReviewedAtText ?? this.lastReviewedAtText,
      nextReviewAtText: nextReviewAtText ?? this.nextReviewAtText,
    );
  }

  static DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.length != 10) return null;
    final date = DateTime.tryParse(normalized);
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }
}
