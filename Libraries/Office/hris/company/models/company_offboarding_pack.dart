enum CompanyOffboardingPackType {
  resignation,
  termination,
  contractEnd,
  roleTransfer,
  retirement,
}

enum CompanyOffboardingPackStatus {
  active,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

enum CompanyOffboardingPackIssue {
  missingName,
  missingEntity,
  missingJobProfile,
  missingOwner,
  missingManagerRole,
  missingKnowledgeTransfer,
  missingAssetReturn,
  missingAccessRevocation,
  missingFinalPayroll,
  missingDocumentChecklist,
  missingExitInterview,
  noRequiredTasks,
  missingSla,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

extension CompanyOffboardingPackTypeLabels on CompanyOffboardingPackType {
  String get label {
    switch (this) {
      case CompanyOffboardingPackType.resignation:
        return 'Resignation';
      case CompanyOffboardingPackType.termination:
        return 'Termination';
      case CompanyOffboardingPackType.contractEnd:
        return 'Contract end';
      case CompanyOffboardingPackType.roleTransfer:
        return 'Role transfer';
      case CompanyOffboardingPackType.retirement:
        return 'Retirement';
    }
  }
}

extension CompanyOffboardingPackStatusLabels on CompanyOffboardingPackStatus {
  String get label {
    switch (this) {
      case CompanyOffboardingPackStatus.active:
        return 'Active';
      case CompanyOffboardingPackStatus.draft:
        return 'Draft';
      case CompanyOffboardingPackStatus.pendingOwnerReview:
        return 'Pending owner review';
      case CompanyOffboardingPackStatus.needsReview:
        return 'Needs review';
      case CompanyOffboardingPackStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyOffboardingPackIssueLabels on CompanyOffboardingPackIssue {
  String get label {
    switch (this) {
      case CompanyOffboardingPackIssue.missingName:
        return 'Add pack name';
      case CompanyOffboardingPackIssue.missingEntity:
        return 'Assign entity';
      case CompanyOffboardingPackIssue.missingJobProfile:
        return 'Link job profile';
      case CompanyOffboardingPackIssue.missingOwner:
        return 'Assign owner';
      case CompanyOffboardingPackIssue.missingManagerRole:
        return 'Add manager role';
      case CompanyOffboardingPackIssue.missingKnowledgeTransfer:
        return 'Add knowledge transfer';
      case CompanyOffboardingPackIssue.missingAssetReturn:
        return 'Add asset return';
      case CompanyOffboardingPackIssue.missingAccessRevocation:
        return 'Add access revocation';
      case CompanyOffboardingPackIssue.missingFinalPayroll:
        return 'Add final payroll';
      case CompanyOffboardingPackIssue.missingDocumentChecklist:
        return 'Add document checklist';
      case CompanyOffboardingPackIssue.missingExitInterview:
        return 'Add exit interview';
      case CompanyOffboardingPackIssue.noRequiredTasks:
        return 'Add tasks';
      case CompanyOffboardingPackIssue.missingSla:
        return 'Add SLA';
      case CompanyOffboardingPackIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyOffboardingPackIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyOffboardingPackIssue.draft:
        return 'Finalize draft';
      case CompanyOffboardingPackIssue.pendingOwnerReview:
        return 'Complete owner review';
      case CompanyOffboardingPackIssue.needsReview:
        return 'Review pack';
      case CompanyOffboardingPackIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyOffboardingPack {
  final String id;
  final String packName;
  final String entityName;
  final CompanyOffboardingPackType type;
  final CompanyOffboardingPackStatus status;
  final String jobProfileCode;
  final String ownerName;
  final String managerRole;
  final String knowledgeTransferPlan;
  final String assetReturnChecklist;
  final String accessRevocationChecklist;
  final String finalPayrollChecklist;
  final String documentChecklist;
  final String exitInterviewTemplate;
  final int requiredTaskCount;
  final int slaDays;
  final DateTime nextReviewDate;
  final String notes;

  const CompanyOffboardingPack({
    required this.id,
    required this.packName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.ownerName,
    required this.managerRole,
    required this.knowledgeTransferPlan,
    required this.assetReturnChecklist,
    required this.accessRevocationChecklist,
    required this.finalPayrollChecklist,
    required this.documentChecklist,
    required this.exitInterviewTemplate,
    required this.requiredTaskCount,
    required this.slaDays,
    required this.nextReviewDate,
    required this.notes,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyOffboardingPackIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (packName.trim().isEmpty) CompanyOffboardingPackIssue.missingName,
      if (entityName.trim().isEmpty) CompanyOffboardingPackIssue.missingEntity,
      if (jobProfileCode.trim().isEmpty)
        CompanyOffboardingPackIssue.missingJobProfile,
      if (ownerName.trim().isEmpty) CompanyOffboardingPackIssue.missingOwner,
      if (managerRole.trim().isEmpty)
        CompanyOffboardingPackIssue.missingManagerRole,
      if (knowledgeTransferPlan.trim().isEmpty)
        CompanyOffboardingPackIssue.missingKnowledgeTransfer,
      if (assetReturnChecklist.trim().isEmpty)
        CompanyOffboardingPackIssue.missingAssetReturn,
      if (accessRevocationChecklist.trim().isEmpty)
        CompanyOffboardingPackIssue.missingAccessRevocation,
      if (finalPayrollChecklist.trim().isEmpty)
        CompanyOffboardingPackIssue.missingFinalPayroll,
      if (documentChecklist.trim().isEmpty)
        CompanyOffboardingPackIssue.missingDocumentChecklist,
      if (exitInterviewTemplate.trim().isEmpty)
        CompanyOffboardingPackIssue.missingExitInterview,
      if (requiredTaskCount <= 0) CompanyOffboardingPackIssue.noRequiredTasks,
      if (slaDays <= 0) CompanyOffboardingPackIssue.missingSla,
      if (days < 0) CompanyOffboardingPackIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyOffboardingPackIssue.reviewDueSoon,
      if (status == CompanyOffboardingPackStatus.draft)
        CompanyOffboardingPackIssue.draft,
      if (status == CompanyOffboardingPackStatus.pendingOwnerReview)
        CompanyOffboardingPackIssue.pendingOwnerReview,
      if (status == CompanyOffboardingPackStatus.needsReview)
        CompanyOffboardingPackIssue.needsReview,
      if (status == CompanyOffboardingPackStatus.retired)
        CompanyOffboardingPackIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyOffboardingPack copyWith({
    String? id,
    String? packName,
    String? entityName,
    CompanyOffboardingPackType? type,
    CompanyOffboardingPackStatus? status,
    String? jobProfileCode,
    String? ownerName,
    String? managerRole,
    String? knowledgeTransferPlan,
    String? assetReturnChecklist,
    String? accessRevocationChecklist,
    String? finalPayrollChecklist,
    String? documentChecklist,
    String? exitInterviewTemplate,
    int? requiredTaskCount,
    int? slaDays,
    DateTime? nextReviewDate,
    String? notes,
  }) {
    return CompanyOffboardingPack(
      id: id ?? this.id,
      packName: packName ?? this.packName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      ownerName: ownerName ?? this.ownerName,
      managerRole: managerRole ?? this.managerRole,
      knowledgeTransferPlan:
          knowledgeTransferPlan ?? this.knowledgeTransferPlan,
      assetReturnChecklist: assetReturnChecklist ?? this.assetReturnChecklist,
      accessRevocationChecklist:
          accessRevocationChecklist ?? this.accessRevocationChecklist,
      finalPayrollChecklist:
          finalPayrollChecklist ?? this.finalPayrollChecklist,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      exitInterviewTemplate:
          exitInterviewTemplate ?? this.exitInterviewTemplate,
      requiredTaskCount: requiredTaskCount ?? this.requiredTaskCount,
      slaDays: slaDays ?? this.slaDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      notes: notes ?? this.notes,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyOffboardingPackDraft {
  final String packName;
  final String entityName;
  final CompanyOffboardingPackType type;
  final CompanyOffboardingPackStatus status;
  final String jobProfileCode;
  final String ownerName;
  final String managerRole;
  final String knowledgeTransferPlan;
  final String assetReturnChecklist;
  final String accessRevocationChecklist;
  final String finalPayrollChecklist;
  final String documentChecklist;
  final String exitInterviewTemplate;
  final String requiredTaskCountText;
  final String slaDaysText;
  final String nextReviewDateText;
  final String notes;

  const CompanyOffboardingPackDraft({
    required this.packName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.ownerName,
    required this.managerRole,
    required this.knowledgeTransferPlan,
    required this.assetReturnChecklist,
    required this.accessRevocationChecklist,
    required this.finalPayrollChecklist,
    required this.documentChecklist,
    required this.exitInterviewTemplate,
    required this.requiredTaskCountText,
    required this.slaDaysText,
    required this.nextReviewDateText,
    required this.notes,
  });

  factory CompanyOffboardingPackDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
  }) {
    return CompanyOffboardingPackDraft(
      packName: '',
      entityName: entityName,
      type: CompanyOffboardingPackType.resignation,
      status: CompanyOffboardingPackStatus.active,
      jobProfileCode: jobProfileCode,
      ownerName: '',
      managerRole: '',
      knowledgeTransferPlan: '',
      assetReturnChecklist: '',
      accessRevocationChecklist: '',
      finalPayrollChecklist: '',
      documentChecklist: '',
      exitInterviewTemplate: '',
      requiredTaskCountText: '',
      slaDaysText: '',
      nextReviewDateText: '',
      notes: '',
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
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get requiredTaskCount => int.tryParse(requiredTaskCountText.trim());
  int? get slaDays => int.tryParse(slaDaysText.trim());
  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    final tasks = requiredTaskCount;
    final sla = slaDays;
    return packName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        managerRole.trim().isNotEmpty &&
        knowledgeTransferPlan.trim().isNotEmpty &&
        assetReturnChecklist.trim().isNotEmpty &&
        accessRevocationChecklist.trim().isNotEmpty &&
        finalPayrollChecklist.trim().isNotEmpty &&
        documentChecklist.trim().isNotEmpty &&
        exitInterviewTemplate.trim().isNotEmpty &&
        tasks != null &&
        tasks > 0 &&
        sla != null &&
        sla > 0 &&
        nextReviewDate != null;
  }

  CompanyOffboardingPack toOffboardingPack(String id) {
    if (!isReady) {
      throw StateError('Complete offboarding pack fields before saving.');
    }
    return CompanyOffboardingPack(
      id: id,
      packName: packName.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      ownerName: ownerName.trim(),
      managerRole: managerRole.trim(),
      knowledgeTransferPlan: knowledgeTransferPlan.trim(),
      assetReturnChecklist: assetReturnChecklist.trim(),
      accessRevocationChecklist: accessRevocationChecklist.trim(),
      finalPayrollChecklist: finalPayrollChecklist.trim(),
      documentChecklist: documentChecklist.trim(),
      exitInterviewTemplate: exitInterviewTemplate.trim(),
      requiredTaskCount: requiredTaskCount!,
      slaDays: slaDays!,
      nextReviewDate: nextReviewDate!,
      notes: notes.trim(),
    );
  }

  CompanyOffboardingPackDraft copyWith({
    String? packName,
    String? entityName,
    CompanyOffboardingPackType? type,
    CompanyOffboardingPackStatus? status,
    String? jobProfileCode,
    String? ownerName,
    String? managerRole,
    String? knowledgeTransferPlan,
    String? assetReturnChecklist,
    String? accessRevocationChecklist,
    String? finalPayrollChecklist,
    String? documentChecklist,
    String? exitInterviewTemplate,
    String? requiredTaskCountText,
    String? slaDaysText,
    String? nextReviewDateText,
    String? notes,
  }) {
    return CompanyOffboardingPackDraft(
      packName: packName ?? this.packName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      ownerName: ownerName ?? this.ownerName,
      managerRole: managerRole ?? this.managerRole,
      knowledgeTransferPlan:
          knowledgeTransferPlan ?? this.knowledgeTransferPlan,
      assetReturnChecklist: assetReturnChecklist ?? this.assetReturnChecklist,
      accessRevocationChecklist:
          accessRevocationChecklist ?? this.accessRevocationChecklist,
      finalPayrollChecklist:
          finalPayrollChecklist ?? this.finalPayrollChecklist,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      exitInterviewTemplate:
          exitInterviewTemplate ?? this.exitInterviewTemplate,
      requiredTaskCountText:
          requiredTaskCountText ?? this.requiredTaskCountText,
      slaDaysText: slaDaysText ?? this.slaDaysText,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      notes: notes ?? this.notes,
    );
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
