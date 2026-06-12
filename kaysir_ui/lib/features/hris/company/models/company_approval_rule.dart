enum CompanyApprovalDomain {
  hiring,
  payroll,
  leave,
  reimbursement,
  policy,
  organizationChange,
}

enum CompanyApprovalRuleStatus { active, draft, paused }

enum CompanyApprovalRuleIssue {
  missingEntity,
  missingScope,
  missingApprover,
  missingBackup,
  slowSla,
  draft,
  paused,
}

extension CompanyApprovalDomainLabels on CompanyApprovalDomain {
  String get label {
    switch (this) {
      case CompanyApprovalDomain.hiring:
        return 'Hiring';
      case CompanyApprovalDomain.payroll:
        return 'Payroll';
      case CompanyApprovalDomain.leave:
        return 'Leave';
      case CompanyApprovalDomain.reimbursement:
        return 'Reimbursement';
      case CompanyApprovalDomain.policy:
        return 'Policy';
      case CompanyApprovalDomain.organizationChange:
        return 'Org change';
    }
  }
}

extension CompanyApprovalRuleStatusLabels on CompanyApprovalRuleStatus {
  String get label {
    switch (this) {
      case CompanyApprovalRuleStatus.active:
        return 'Active';
      case CompanyApprovalRuleStatus.draft:
        return 'Draft';
      case CompanyApprovalRuleStatus.paused:
        return 'Paused';
    }
  }
}

extension CompanyApprovalRuleIssueLabels on CompanyApprovalRuleIssue {
  String get label {
    switch (this) {
      case CompanyApprovalRuleIssue.missingEntity:
        return 'Assign entity';
      case CompanyApprovalRuleIssue.missingScope:
        return 'Assign scope';
      case CompanyApprovalRuleIssue.missingApprover:
        return 'Assign approver';
      case CompanyApprovalRuleIssue.missingBackup:
        return 'Assign backup';
      case CompanyApprovalRuleIssue.slowSla:
        return 'Review SLA';
      case CompanyApprovalRuleIssue.draft:
        return 'Publish rule';
      case CompanyApprovalRuleIssue.paused:
        return 'Resume rule';
    }
  }
}

class CompanyApprovalRule {
  final String id;
  final CompanyApprovalDomain domain;
  final String entityName;
  final String scopeName;
  final String approverRole;
  final String backupApproverRole;
  final String thresholdLabel;
  final int slaHours;
  final CompanyApprovalRuleStatus status;

  const CompanyApprovalRule({
    required this.id,
    required this.domain,
    required this.entityName,
    required this.scopeName,
    required this.approverRole,
    required this.backupApproverRole,
    required this.thresholdLabel,
    required this.slaHours,
    required this.status,
  });

  List<CompanyApprovalRuleIssue> get issues {
    return [
      if (entityName.trim().isEmpty) CompanyApprovalRuleIssue.missingEntity,
      if (scopeName.trim().isEmpty) CompanyApprovalRuleIssue.missingScope,
      if (approverRole.trim().isEmpty) CompanyApprovalRuleIssue.missingApprover,
      if (backupApproverRole.trim().isEmpty)
        CompanyApprovalRuleIssue.missingBackup,
      if (slaHours > 72 || slaHours <= 0) CompanyApprovalRuleIssue.slowSla,
      if (status == CompanyApprovalRuleStatus.draft)
        CompanyApprovalRuleIssue.draft,
      if (status == CompanyApprovalRuleStatus.paused)
        CompanyApprovalRuleIssue.paused,
    ];
  }

  bool get requiresAttention => issues.isNotEmpty;

  CompanyApprovalRule copyWith({
    String? id,
    CompanyApprovalDomain? domain,
    String? entityName,
    String? scopeName,
    String? approverRole,
    String? backupApproverRole,
    String? thresholdLabel,
    int? slaHours,
    CompanyApprovalRuleStatus? status,
  }) {
    return CompanyApprovalRule(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      entityName: entityName ?? this.entityName,
      scopeName: scopeName ?? this.scopeName,
      approverRole: approverRole ?? this.approverRole,
      backupApproverRole: backupApproverRole ?? this.backupApproverRole,
      thresholdLabel: thresholdLabel ?? this.thresholdLabel,
      slaHours: slaHours ?? this.slaHours,
      status: status ?? this.status,
    );
  }
}

class CompanyApprovalRuleDraft {
  final CompanyApprovalDomain domain;
  final String entityName;
  final String scopeName;
  final String approverRole;
  final String backupApproverRole;
  final String thresholdLabel;
  final String slaHoursText;
  final CompanyApprovalRuleStatus status;

  const CompanyApprovalRuleDraft({
    required this.domain,
    required this.entityName,
    required this.scopeName,
    required this.approverRole,
    required this.backupApproverRole,
    required this.thresholdLabel,
    required this.slaHoursText,
    required this.status,
  });

  factory CompanyApprovalRuleDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyApprovalRuleDraft(
      domain: CompanyApprovalDomain.hiring,
      entityName: entityName,
      scopeName: '',
      approverRole: '',
      backupApproverRole: '',
      thresholdLabel: 'Any amount',
      slaHoursText: '24',
      status: CompanyApprovalRuleStatus.draft,
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateSlaHours(String? value) {
    final hours = int.tryParse(value?.trim() ?? '');
    if (hours == null || hours <= 0) return 'Enter SLA hours';
    return null;
  }

  int? get slaHours => int.tryParse(slaHoursText.trim());

  bool get isReady {
    return entityName.trim().isNotEmpty &&
        scopeName.trim().isNotEmpty &&
        approverRole.trim().isNotEmpty &&
        backupApproverRole.trim().isNotEmpty &&
        thresholdLabel.trim().isNotEmpty &&
        slaHours != null &&
        slaHours! > 0;
  }

  CompanyApprovalRule toApprovalRule(String id) {
    if (!isReady) {
      throw StateError('Complete approval rule fields before saving.');
    }

    return CompanyApprovalRule(
      id: id,
      domain: domain,
      entityName: entityName.trim(),
      scopeName: scopeName.trim(),
      approverRole: approverRole.trim(),
      backupApproverRole: backupApproverRole.trim(),
      thresholdLabel: thresholdLabel.trim(),
      slaHours: slaHours!,
      status: status,
    );
  }

  CompanyApprovalRuleDraft copyWith({
    CompanyApprovalDomain? domain,
    String? entityName,
    String? scopeName,
    String? approverRole,
    String? backupApproverRole,
    String? thresholdLabel,
    String? slaHoursText,
    CompanyApprovalRuleStatus? status,
  }) {
    return CompanyApprovalRuleDraft(
      domain: domain ?? this.domain,
      entityName: entityName ?? this.entityName,
      scopeName: scopeName ?? this.scopeName,
      approverRole: approverRole ?? this.approverRole,
      backupApproverRole: backupApproverRole ?? this.backupApproverRole,
      thresholdLabel: thresholdLabel ?? this.thresholdLabel,
      slaHoursText: slaHoursText ?? this.slaHoursText,
      status: status ?? this.status,
    );
  }
}
