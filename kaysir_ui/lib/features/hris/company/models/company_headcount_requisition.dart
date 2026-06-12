/// Business reason for a headcount requisition.
enum CompanyHeadcountRequisitionType {
  growth('Growth'),
  backfill('Backfill'),
  replacement('Replacement'),
  temporary('Temporary'),
  internship('Internship');

  final String label;

  const CompanyHeadcountRequisitionType(this.label);
}

/// Approval and fulfillment state for a headcount requisition.
enum CompanyHeadcountRequisitionStatus {
  draft('Draft'),
  awaitingApproval('Awaiting approval'),
  approved('Approved'),
  recruiting('Recruiting'),
  filled('Filled'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String label;

  const CompanyHeadcountRequisitionStatus(this.label);
}

/// Hiring urgency assigned to a headcount requisition.
enum CompanyHeadcountRequisitionPriority {
  low('Low', 3),
  medium('Medium', 2),
  high('High', 1),
  critical('Critical', 0);

  final String label;
  final int sortRank;

  const CompanyHeadcountRequisitionPriority(this.label, this.sortRank);
}

/// Readiness issue detected on a headcount requisition.
enum CompanyHeadcountRequisitionIssue {
  missingTitle('Add role title'),
  missingEntity('Assign entity'),
  missingOrgUnit('Assign org unit'),
  missingHiringManager('Assign hiring manager'),
  missingJobProfile('Link job profile'),
  missingCostCenter('Link cost center'),
  invalidSeats('Set requested seats'),
  missingTargetStart('Set target start'),
  missingBusinessCase('Add business case'),
  missingBudgetImpact('Add budget impact'),
  missingApprover('Assign approver'),
  overdueTargetStart('Target start overdue'),
  awaitingApproval('Approve requisition'),
  approvedNotRecruiting('Open recruiting'),
  recruitingOpen('Recruiting open'),
  rejected('Rejected'),
  criticalPriority('Critical priority');

  final String label;

  const CompanyHeadcountRequisitionIssue(this.label);
}

/// Headcount requisition intake record for approving and tracking hiring demand.
class CompanyHeadcountRequisition {
  final String id;
  final String roleTitle;
  final String entityName;
  final String orgUnitName;
  final String hiringManagerName;
  final String positionControlId;
  final String jobProfileCode;
  final String costCenterCode;
  final CompanyHeadcountRequisitionType type;
  final CompanyHeadcountRequisitionPriority priority;
  final CompanyHeadcountRequisitionStatus status;
  final int requestedSeats;
  final DateTime targetStartDate;
  final String businessCase;
  final String budgetImpact;
  final String approverRole;

  const CompanyHeadcountRequisition({
    required this.id,
    required this.roleTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.hiringManagerName,
    required this.positionControlId,
    required this.jobProfileCode,
    required this.costCenterCode,
    required this.type,
    required this.priority,
    required this.status,
    required this.requestedSeats,
    required this.targetStartDate,
    required this.businessCase,
    required this.budgetImpact,
    required this.approverRole,
  });

  int daysUntilTargetStart(DateTime asOfDate) {
    return _dateOnly(targetStartDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyHeadcountRequisitionIssue> issues(DateTime asOfDate) {
    if (status == CompanyHeadcountRequisitionStatus.filled ||
        status == CompanyHeadcountRequisitionStatus.cancelled) {
      return const [];
    }

    final days = daysUntilTargetStart(asOfDate);
    return [
      if (roleTitle.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingTitle,
      if (entityName.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingEntity,
      if (orgUnitName.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingOrgUnit,
      if (hiringManagerName.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingHiringManager,
      if (jobProfileCode.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingJobProfile,
      if (costCenterCode.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingCostCenter,
      if (requestedSeats <= 0) CompanyHeadcountRequisitionIssue.invalidSeats,
      if (businessCase.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingBusinessCase,
      if (budgetImpact.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingBudgetImpact,
      if (approverRole.trim().isEmpty)
        CompanyHeadcountRequisitionIssue.missingApprover,
      if (days < 0) CompanyHeadcountRequisitionIssue.overdueTargetStart,
      if (status == CompanyHeadcountRequisitionStatus.awaitingApproval)
        CompanyHeadcountRequisitionIssue.awaitingApproval,
      if (status == CompanyHeadcountRequisitionStatus.approved)
        CompanyHeadcountRequisitionIssue.approvedNotRecruiting,
      if (status == CompanyHeadcountRequisitionStatus.recruiting)
        CompanyHeadcountRequisitionIssue.recruitingOpen,
      if (status == CompanyHeadcountRequisitionStatus.rejected)
        CompanyHeadcountRequisitionIssue.rejected,
      if (priority == CompanyHeadcountRequisitionPriority.critical)
        CompanyHeadcountRequisitionIssue.criticalPriority,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyHeadcountRequisition copyWith({
    String? id,
    String? roleTitle,
    String? entityName,
    String? orgUnitName,
    String? hiringManagerName,
    String? positionControlId,
    String? jobProfileCode,
    String? costCenterCode,
    CompanyHeadcountRequisitionType? type,
    CompanyHeadcountRequisitionPriority? priority,
    CompanyHeadcountRequisitionStatus? status,
    int? requestedSeats,
    DateTime? targetStartDate,
    String? businessCase,
    String? budgetImpact,
    String? approverRole,
  }) {
    return CompanyHeadcountRequisition(
      id: id ?? this.id,
      roleTitle: roleTitle ?? this.roleTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      hiringManagerName: hiringManagerName ?? this.hiringManagerName,
      positionControlId: positionControlId ?? this.positionControlId,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      costCenterCode: costCenterCode ?? this.costCenterCode,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requestedSeats: requestedSeats ?? this.requestedSeats,
      targetStartDate: targetStartDate ?? this.targetStartDate,
      businessCase: businessCase ?? this.businessCase,
      budgetImpact: budgetImpact ?? this.budgetImpact,
      approverRole: approverRole ?? this.approverRole,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

/// Editable draft for the headcount requisition intake form.
class CompanyHeadcountRequisitionDraft {
  final String roleTitle;
  final String entityName;
  final String orgUnitName;
  final String hiringManagerName;
  final String positionControlId;
  final String jobProfileCode;
  final String costCenterCode;
  final CompanyHeadcountRequisitionType type;
  final CompanyHeadcountRequisitionPriority priority;
  final CompanyHeadcountRequisitionStatus status;
  final String requestedSeatsText;
  final String targetStartDateText;
  final String businessCase;
  final String budgetImpact;
  final String approverRole;

  const CompanyHeadcountRequisitionDraft({
    required this.roleTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.hiringManagerName,
    required this.positionControlId,
    required this.jobProfileCode,
    required this.costCenterCode,
    required this.type,
    required this.priority,
    required this.status,
    required this.requestedSeatsText,
    required this.targetStartDateText,
    required this.businessCase,
    required this.budgetImpact,
    required this.approverRole,
  });

  factory CompanyHeadcountRequisitionDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
  }) {
    return CompanyHeadcountRequisitionDraft(
      roleTitle: '',
      entityName: entityName,
      orgUnitName: orgUnitName,
      hiringManagerName: '',
      positionControlId: '',
      jobProfileCode: '',
      costCenterCode: '',
      type: CompanyHeadcountRequisitionType.growth,
      priority: CompanyHeadcountRequisitionPriority.medium,
      status: CompanyHeadcountRequisitionStatus.awaitingApproval,
      requestedSeatsText: '1',
      targetStartDateText: '',
      businessCase: '',
      budgetImpact: '',
      approverRole: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveInt(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    return _parseDate(value?.trim() ?? '') == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get requestedSeats => int.tryParse(requestedSeatsText.trim());

  DateTime? get targetStartDate => _parseDate(targetStartDateText);

  bool get isReady {
    final seats = requestedSeats;
    return roleTitle.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        orgUnitName.trim().isNotEmpty &&
        hiringManagerName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        costCenterCode.trim().isNotEmpty &&
        seats != null &&
        seats > 0 &&
        targetStartDate != null &&
        businessCase.trim().isNotEmpty &&
        budgetImpact.trim().isNotEmpty &&
        approverRole.trim().isNotEmpty;
  }

  CompanyHeadcountRequisition toRequisition(String id) {
    if (!isReady) {
      throw StateError('Complete headcount requisition before saving.');
    }

    return CompanyHeadcountRequisition(
      id: id,
      roleTitle: roleTitle.trim(),
      entityName: entityName.trim(),
      orgUnitName: orgUnitName.trim(),
      hiringManagerName: hiringManagerName.trim(),
      positionControlId: positionControlId.trim(),
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      costCenterCode: costCenterCode.trim().toUpperCase(),
      type: type,
      priority: priority,
      status: status,
      requestedSeats: requestedSeats!,
      targetStartDate: targetStartDate!,
      businessCase: businessCase.trim(),
      budgetImpact: budgetImpact.trim(),
      approverRole: approverRole.trim(),
    );
  }

  CompanyHeadcountRequisitionDraft copyWith({
    String? roleTitle,
    String? entityName,
    String? orgUnitName,
    String? hiringManagerName,
    String? positionControlId,
    String? jobProfileCode,
    String? costCenterCode,
    CompanyHeadcountRequisitionType? type,
    CompanyHeadcountRequisitionPriority? priority,
    CompanyHeadcountRequisitionStatus? status,
    String? requestedSeatsText,
    String? targetStartDateText,
    String? businessCase,
    String? budgetImpact,
    String? approverRole,
  }) {
    return CompanyHeadcountRequisitionDraft(
      roleTitle: roleTitle ?? this.roleTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      hiringManagerName: hiringManagerName ?? this.hiringManagerName,
      positionControlId: positionControlId ?? this.positionControlId,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      costCenterCode: costCenterCode ?? this.costCenterCode,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requestedSeatsText: requestedSeatsText ?? this.requestedSeatsText,
      targetStartDateText: targetStartDateText ?? this.targetStartDateText,
      businessCase: businessCase ?? this.businessCase,
      budgetImpact: budgetImpact ?? this.budgetImpact,
      approverRole: approverRole ?? this.approverRole,
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
