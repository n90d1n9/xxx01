enum CompanyChangeRequestType {
  legalEntity,
  workLocation,
  orgStructure,
  costCenter,
  approvalRule,
  policy,
  document,
  operatingReadiness,
}

enum CompanyChangeRequestStatus {
  draft,
  awaitingApproval,
  scheduled,
  implemented,
  blocked,
}

enum CompanyChangeRequestPriority { low, medium, high, critical }

enum CompanyChangeRequestIssue {
  missingOwner,
  missingEntity,
  missingImpact,
  overdueEffectiveDate,
  blocked,
  awaitingApproval,
  draft,
  criticalPriority,
}

extension CompanyChangeRequestTypeLabels on CompanyChangeRequestType {
  String get label {
    switch (this) {
      case CompanyChangeRequestType.legalEntity:
        return 'Legal entity';
      case CompanyChangeRequestType.workLocation:
        return 'Work location';
      case CompanyChangeRequestType.orgStructure:
        return 'Org structure';
      case CompanyChangeRequestType.costCenter:
        return 'Cost center';
      case CompanyChangeRequestType.approvalRule:
        return 'Approval rule';
      case CompanyChangeRequestType.policy:
        return 'Policy';
      case CompanyChangeRequestType.document:
        return 'Document';
      case CompanyChangeRequestType.operatingReadiness:
        return 'Operating readiness';
    }
  }
}

extension CompanyChangeRequestStatusLabels on CompanyChangeRequestStatus {
  String get label {
    switch (this) {
      case CompanyChangeRequestStatus.draft:
        return 'Draft';
      case CompanyChangeRequestStatus.awaitingApproval:
        return 'Awaiting approval';
      case CompanyChangeRequestStatus.scheduled:
        return 'Scheduled';
      case CompanyChangeRequestStatus.implemented:
        return 'Implemented';
      case CompanyChangeRequestStatus.blocked:
        return 'Blocked';
    }
  }
}

extension CompanyChangeRequestPriorityLabels on CompanyChangeRequestPriority {
  String get label {
    switch (this) {
      case CompanyChangeRequestPriority.low:
        return 'Low';
      case CompanyChangeRequestPriority.medium:
        return 'Medium';
      case CompanyChangeRequestPriority.high:
        return 'High';
      case CompanyChangeRequestPriority.critical:
        return 'Critical';
    }
  }
}

extension CompanyChangeRequestIssueLabels on CompanyChangeRequestIssue {
  String get label {
    switch (this) {
      case CompanyChangeRequestIssue.missingOwner:
        return 'Assign owner';
      case CompanyChangeRequestIssue.missingEntity:
        return 'Assign entity';
      case CompanyChangeRequestIssue.missingImpact:
        return 'Add impact summary';
      case CompanyChangeRequestIssue.overdueEffectiveDate:
        return 'Effective date overdue';
      case CompanyChangeRequestIssue.blocked:
        return 'Resolve blocker';
      case CompanyChangeRequestIssue.awaitingApproval:
        return 'Approve change';
      case CompanyChangeRequestIssue.draft:
        return 'Complete draft';
      case CompanyChangeRequestIssue.criticalPriority:
        return 'Critical change';
    }
  }
}

class CompanyChangeRequest {
  final String id;
  final String title;
  final String entityName;
  final String ownerName;
  final CompanyChangeRequestType type;
  final CompanyChangeRequestPriority priority;
  final CompanyChangeRequestStatus status;
  final DateTime effectiveDate;
  final String impactSummary;
  final String approverRole;
  final String linkedRecord;

  const CompanyChangeRequest({
    required this.id,
    required this.title,
    required this.entityName,
    required this.ownerName,
    required this.type,
    required this.priority,
    required this.status,
    required this.effectiveDate,
    required this.impactSummary,
    required this.approverRole,
    required this.linkedRecord,
  });

  int daysUntilEffective(DateTime asOfDate) {
    return _dateOnly(effectiveDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyChangeRequestIssue> issues(DateTime asOfDate) {
    if (status == CompanyChangeRequestStatus.implemented) return [];

    return [
      if (entityName.trim().isEmpty) CompanyChangeRequestIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyChangeRequestIssue.missingOwner,
      if (impactSummary.trim().isEmpty) CompanyChangeRequestIssue.missingImpact,
      if (daysUntilEffective(asOfDate) < 0)
        CompanyChangeRequestIssue.overdueEffectiveDate,
      if (status == CompanyChangeRequestStatus.blocked)
        CompanyChangeRequestIssue.blocked,
      if (status == CompanyChangeRequestStatus.awaitingApproval)
        CompanyChangeRequestIssue.awaitingApproval,
      if (status == CompanyChangeRequestStatus.draft)
        CompanyChangeRequestIssue.draft,
      if (priority == CompanyChangeRequestPriority.critical)
        CompanyChangeRequestIssue.criticalPriority,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyChangeRequest copyWith({
    String? id,
    String? title,
    String? entityName,
    String? ownerName,
    CompanyChangeRequestType? type,
    CompanyChangeRequestPriority? priority,
    CompanyChangeRequestStatus? status,
    DateTime? effectiveDate,
    String? impactSummary,
    String? approverRole,
    String? linkedRecord,
  }) {
    return CompanyChangeRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      impactSummary: impactSummary ?? this.impactSummary,
      approverRole: approverRole ?? this.approverRole,
      linkedRecord: linkedRecord ?? this.linkedRecord,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyChangeRequestDraft {
  final String title;
  final String entityName;
  final String ownerName;
  final CompanyChangeRequestType type;
  final CompanyChangeRequestPriority priority;
  final CompanyChangeRequestStatus status;
  final String effectiveDateText;
  final String impactSummary;
  final String approverRole;
  final String linkedRecord;

  const CompanyChangeRequestDraft({
    required this.title,
    required this.entityName,
    required this.ownerName,
    required this.type,
    required this.priority,
    required this.status,
    required this.effectiveDateText,
    required this.impactSummary,
    required this.approverRole,
    required this.linkedRecord,
  });

  factory CompanyChangeRequestDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyChangeRequestDraft(
      title: '',
      entityName: entityName,
      ownerName: '',
      type: CompanyChangeRequestType.orgStructure,
      priority: CompanyChangeRequestPriority.medium,
      status: CompanyChangeRequestStatus.draft,
      effectiveDateText: '',
      impactSummary: '',
      approverRole: '',
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

  DateTime? get effectiveDate => _parseDate(effectiveDateText);

  bool get isReady {
    return title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        effectiveDate != null &&
        impactSummary.trim().isNotEmpty &&
        approverRole.trim().isNotEmpty;
  }

  CompanyChangeRequest toChangeRequest(String id) {
    if (!isReady) {
      throw StateError('Complete company change request before saving.');
    }

    return CompanyChangeRequest(
      id: id,
      title: title.trim(),
      entityName: entityName.trim(),
      ownerName: ownerName.trim(),
      type: type,
      priority: priority,
      status: status,
      effectiveDate: effectiveDate!,
      impactSummary: impactSummary.trim(),
      approverRole: approverRole.trim(),
      linkedRecord: linkedRecord.trim(),
    );
  }

  CompanyChangeRequestDraft copyWith({
    String? title,
    String? entityName,
    String? ownerName,
    CompanyChangeRequestType? type,
    CompanyChangeRequestPriority? priority,
    CompanyChangeRequestStatus? status,
    String? effectiveDateText,
    String? impactSummary,
    String? approverRole,
    String? linkedRecord,
  }) {
    return CompanyChangeRequestDraft(
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      effectiveDateText: effectiveDateText ?? this.effectiveDateText,
      impactSummary: impactSummary ?? this.impactSummary,
      approverRole: approverRole ?? this.approverRole,
      linkedRecord: linkedRecord ?? this.linkedRecord,
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
