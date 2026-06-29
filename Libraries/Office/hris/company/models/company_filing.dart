enum CompanyFilingType { tax, bpjs, license, laborReport, dataPrivacy, payroll }

enum CompanyFilingCadence { monthly, quarterly, annual, oneOff }

enum CompanyFilingStatus { scheduled, inProgress, filed, overdue, blocked }

enum CompanyFilingIssue {
  missingEntity,
  missingOwner,
  missingAuthority,
  missingNextStep,
  missingEvidence,
  overdueDueDate,
  blocked,
  dueSoon,
}

extension CompanyFilingTypeLabels on CompanyFilingType {
  String get label {
    switch (this) {
      case CompanyFilingType.tax:
        return 'Tax';
      case CompanyFilingType.bpjs:
        return 'BPJS';
      case CompanyFilingType.license:
        return 'License';
      case CompanyFilingType.laborReport:
        return 'Labor report';
      case CompanyFilingType.dataPrivacy:
        return 'Data privacy';
      case CompanyFilingType.payroll:
        return 'Payroll';
    }
  }
}

extension CompanyFilingCadenceLabels on CompanyFilingCadence {
  String get label {
    switch (this) {
      case CompanyFilingCadence.monthly:
        return 'Monthly';
      case CompanyFilingCadence.quarterly:
        return 'Quarterly';
      case CompanyFilingCadence.annual:
        return 'Annual';
      case CompanyFilingCadence.oneOff:
        return 'One-off';
    }
  }
}

extension CompanyFilingStatusLabels on CompanyFilingStatus {
  String get label {
    switch (this) {
      case CompanyFilingStatus.scheduled:
        return 'Scheduled';
      case CompanyFilingStatus.inProgress:
        return 'In progress';
      case CompanyFilingStatus.filed:
        return 'Filed';
      case CompanyFilingStatus.overdue:
        return 'Overdue';
      case CompanyFilingStatus.blocked:
        return 'Blocked';
    }
  }
}

extension CompanyFilingIssueLabels on CompanyFilingIssue {
  String get label {
    switch (this) {
      case CompanyFilingIssue.missingEntity:
        return 'Assign entity';
      case CompanyFilingIssue.missingOwner:
        return 'Assign owner';
      case CompanyFilingIssue.missingAuthority:
        return 'Assign authority';
      case CompanyFilingIssue.missingNextStep:
        return 'Add next step';
      case CompanyFilingIssue.missingEvidence:
        return 'Attach evidence';
      case CompanyFilingIssue.overdueDueDate:
        return 'Filing overdue';
      case CompanyFilingIssue.blocked:
        return 'Resolve blocker';
      case CompanyFilingIssue.dueSoon:
        return 'Due soon';
    }
  }
}

class CompanyFiling {
  final String id;
  final String title;
  final String entityName;
  final CompanyFilingType type;
  final CompanyFilingCadence cadence;
  final CompanyFilingStatus status;
  final String ownerName;
  final String authorityName;
  final DateTime dueDate;
  final String evidenceSummary;
  final String nextStep;
  final String linkedRecord;

  const CompanyFiling({
    required this.id,
    required this.title,
    required this.entityName,
    required this.type,
    required this.cadence,
    required this.status,
    required this.ownerName,
    required this.authorityName,
    required this.dueDate,
    required this.evidenceSummary,
    required this.nextStep,
    required this.linkedRecord,
  });

  int daysUntilDue(DateTime asOfDate) {
    return _dateOnly(dueDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyFilingIssue> issues(DateTime asOfDate) {
    if (status == CompanyFilingStatus.filed) return [];

    final days = daysUntilDue(asOfDate);
    return [
      if (entityName.trim().isEmpty) CompanyFilingIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyFilingIssue.missingOwner,
      if (authorityName.trim().isEmpty) CompanyFilingIssue.missingAuthority,
      if (nextStep.trim().isEmpty) CompanyFilingIssue.missingNextStep,
      if (status == CompanyFilingStatus.inProgress &&
          evidenceSummary.trim().isEmpty)
        CompanyFilingIssue.missingEvidence,
      if (days < 0 || status == CompanyFilingStatus.overdue)
        CompanyFilingIssue.overdueDueDate,
      if (status == CompanyFilingStatus.blocked) CompanyFilingIssue.blocked,
      if (days >= 0 && days <= 14) CompanyFilingIssue.dueSoon,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyFiling copyWith({
    String? id,
    String? title,
    String? entityName,
    CompanyFilingType? type,
    CompanyFilingCadence? cadence,
    CompanyFilingStatus? status,
    String? ownerName,
    String? authorityName,
    DateTime? dueDate,
    String? evidenceSummary,
    String? nextStep,
    String? linkedRecord,
  }) {
    return CompanyFiling(
      id: id ?? this.id,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      cadence: cadence ?? this.cadence,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      authorityName: authorityName ?? this.authorityName,
      dueDate: dueDate ?? this.dueDate,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      nextStep: nextStep ?? this.nextStep,
      linkedRecord: linkedRecord ?? this.linkedRecord,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyFilingDraft {
  final String title;
  final String entityName;
  final CompanyFilingType type;
  final CompanyFilingCadence cadence;
  final CompanyFilingStatus status;
  final String ownerName;
  final String authorityName;
  final String dueDateText;
  final String evidenceSummary;
  final String nextStep;
  final String linkedRecord;

  const CompanyFilingDraft({
    required this.title,
    required this.entityName,
    required this.type,
    required this.cadence,
    required this.status,
    required this.ownerName,
    required this.authorityName,
    required this.dueDateText,
    required this.evidenceSummary,
    required this.nextStep,
    required this.linkedRecord,
  });

  factory CompanyFilingDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyFilingDraft(
      title: '',
      entityName: entityName,
      type: CompanyFilingType.tax,
      cadence: CompanyFilingCadence.monthly,
      status: CompanyFilingStatus.scheduled,
      ownerName: '',
      authorityName: '',
      dueDateText: '',
      evidenceSummary: '',
      nextStep: '',
      linkedRecord: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get dueDate => _parseDate(dueDateText);

  bool get isReady {
    return title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        authorityName.trim().isNotEmpty &&
        dueDate != null &&
        nextStep.trim().isNotEmpty;
  }

  CompanyFiling toFiling(String id) {
    if (!isReady) {
      throw StateError('Complete company filing fields before saving.');
    }
    return CompanyFiling(
      id: id,
      title: title.trim(),
      entityName: entityName.trim(),
      type: type,
      cadence: cadence,
      status: status,
      ownerName: ownerName.trim(),
      authorityName: authorityName.trim(),
      dueDate: dueDate!,
      evidenceSummary: evidenceSummary.trim(),
      nextStep: nextStep.trim(),
      linkedRecord: linkedRecord.trim(),
    );
  }

  CompanyFilingDraft copyWith({
    String? title,
    String? entityName,
    CompanyFilingType? type,
    CompanyFilingCadence? cadence,
    CompanyFilingStatus? status,
    String? ownerName,
    String? authorityName,
    String? dueDateText,
    String? evidenceSummary,
    String? nextStep,
    String? linkedRecord,
  }) {
    return CompanyFilingDraft(
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      cadence: cadence ?? this.cadence,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      authorityName: authorityName ?? this.authorityName,
      dueDateText: dueDateText ?? this.dueDateText,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      nextStep: nextStep ?? this.nextStep,
      linkedRecord: linkedRecord ?? this.linkedRecord,
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
