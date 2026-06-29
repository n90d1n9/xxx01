enum CompanyDocumentRenewalStatus {
  scheduled,
  inProgress,
  waitingAuthority,
  blocked,
  completed,
}

enum CompanyDocumentRenewalIssue {
  missingDocument,
  missingOwner,
  overdue,
  dueSoon,
  waitingAuthority,
  blocked,
}

extension CompanyDocumentRenewalStatusLabels on CompanyDocumentRenewalStatus {
  String get label {
    switch (this) {
      case CompanyDocumentRenewalStatus.scheduled:
        return 'Scheduled';
      case CompanyDocumentRenewalStatus.inProgress:
        return 'In progress';
      case CompanyDocumentRenewalStatus.waitingAuthority:
        return 'Waiting authority';
      case CompanyDocumentRenewalStatus.blocked:
        return 'Blocked';
      case CompanyDocumentRenewalStatus.completed:
        return 'Completed';
    }
  }
}

extension CompanyDocumentRenewalIssueLabels on CompanyDocumentRenewalIssue {
  String get label {
    switch (this) {
      case CompanyDocumentRenewalIssue.missingDocument:
        return 'Link document';
      case CompanyDocumentRenewalIssue.missingOwner:
        return 'Assign owner';
      case CompanyDocumentRenewalIssue.overdue:
        return 'Overdue renewal';
      case CompanyDocumentRenewalIssue.dueSoon:
        return 'Renewal due soon';
      case CompanyDocumentRenewalIssue.waitingAuthority:
        return 'Follow up authority';
      case CompanyDocumentRenewalIssue.blocked:
        return 'Remove blocker';
    }
  }
}

class CompanyDocumentRenewalTask {
  final String id;
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String ownerName;
  final DateTime dueDate;
  final int reminderLeadDays;
  final CompanyDocumentRenewalStatus status;
  final String lastActivity;
  final String actionLabel;

  const CompanyDocumentRenewalTask({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.ownerName,
    required this.dueDate,
    required this.reminderLeadDays,
    required this.status,
    required this.lastActivity,
    required this.actionLabel,
  });

  int daysUntilDue(DateTime asOfDate) {
    return _dateOnly(dueDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyDocumentRenewalIssue> issues(DateTime asOfDate) {
    if (status == CompanyDocumentRenewalStatus.completed) return const [];

    final days = daysUntilDue(asOfDate);
    return [
      if (documentId.trim().isEmpty || documentTitle.trim().isEmpty)
        CompanyDocumentRenewalIssue.missingDocument,
      if (ownerName.trim().isEmpty) CompanyDocumentRenewalIssue.missingOwner,
      if (days < 0) CompanyDocumentRenewalIssue.overdue,
      if (days >= 0 && days <= reminderLeadDays)
        CompanyDocumentRenewalIssue.dueSoon,
      if (status == CompanyDocumentRenewalStatus.waitingAuthority)
        CompanyDocumentRenewalIssue.waitingAuthority,
      if (status == CompanyDocumentRenewalStatus.blocked)
        CompanyDocumentRenewalIssue.blocked,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyDocumentRenewalTask copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? entityName,
    String? ownerName,
    DateTime? dueDate,
    int? reminderLeadDays,
    CompanyDocumentRenewalStatus? status,
    String? lastActivity,
    String? actionLabel,
  }) {
    return CompanyDocumentRenewalTask(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      status: status ?? this.status,
      lastActivity: lastActivity ?? this.lastActivity,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyDocumentRenewalDraft {
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String ownerName;
  final String dueDateText;
  final String reminderLeadDaysText;
  final CompanyDocumentRenewalStatus status;
  final String actionLabel;

  const CompanyDocumentRenewalDraft({
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.ownerName,
    required this.dueDateText,
    required this.reminderLeadDaysText,
    required this.status,
    required this.actionLabel,
  });

  factory CompanyDocumentRenewalDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyDocumentRenewalDraft(
      documentId: '',
      documentTitle: '',
      entityName: entityName,
      ownerName: '',
      dueDateText: '',
      reminderLeadDaysText: '30',
      status: CompanyDocumentRenewalStatus.scheduled,
      actionLabel: 'Prepare renewal packet',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  static String? validateLeadDays(String? value) {
    final days = int.tryParse(value?.trim() ?? '');
    if (days == null || days < 0) return 'Enter zero or greater';
    return null;
  }

  DateTime? get dueDate => _parseDate(dueDateText);

  int? get reminderLeadDays => int.tryParse(reminderLeadDaysText.trim());

  bool get isReady {
    return documentId.trim().isNotEmpty &&
        documentTitle.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        actionLabel.trim().isNotEmpty &&
        dueDate != null &&
        reminderLeadDays != null &&
        reminderLeadDays! >= 0;
  }

  CompanyDocumentRenewalTask toRenewalTask(String id) {
    if (!isReady) {
      throw StateError('Complete renewal task fields before saving.');
    }

    return CompanyDocumentRenewalTask(
      id: id,
      documentId: documentId.trim(),
      documentTitle: documentTitle.trim(),
      entityName: entityName.trim(),
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      reminderLeadDays: reminderLeadDays!,
      status: status,
      lastActivity: 'Task scheduled',
      actionLabel: actionLabel.trim(),
    );
  }

  CompanyDocumentRenewalDraft copyWith({
    String? documentId,
    String? documentTitle,
    String? entityName,
    String? ownerName,
    String? dueDateText,
    String? reminderLeadDaysText,
    CompanyDocumentRenewalStatus? status,
    String? actionLabel,
  }) {
    return CompanyDocumentRenewalDraft(
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      dueDateText: dueDateText ?? this.dueDateText,
      reminderLeadDaysText: reminderLeadDaysText ?? this.reminderLeadDaysText,
      status: status ?? this.status,
      actionLabel: actionLabel ?? this.actionLabel,
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
